//
//  ContentBlockingUpdating.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import BrowserServicesKit
import Core
import Combine
import WebKit

extension ContentBlocking {
    var contentBlockingUpdating: ContentBlockingUpdating { .shared }
}

protocol ContentBlockerRulesManagerProtocol: CompiledRuleListsSource {
    var updatesPublisher: AnyPublisher<ContentBlockerRulesManager.UpdateEvent, Never> { get }
}
extension ContentBlockerRulesManager: ContentBlockerRulesManagerProtocol {}

extension ContentBlockerRulesIdentifier.Difference {
    static let notification = ContentBlockerRulesIdentifier.Difference(rawValue: 1 << 8)
}

public final class ContentBlockingUpdating {
    fileprivate static let shared = ContentBlockingUpdating()

    private typealias Update = ContentBlockerRulesManager.UpdateEvent
    struct NewContent: UserContentControllerNewContent {
        let rulesUpdate: ContentBlockerRulesManager.UpdateEvent
        let sourceProvider: ScriptSourceProviding
        var makeUserScripts: @MainActor (ScriptSourceProviding) -> UserScripts {
            { sourceProvider in
                UserScripts(with: sourceProvider)
            }
        }
    }

    @Published private var bufferedValue: NewContent?
    private var cancellable: AnyCancellable?

    private(set) var userContentBlockingAssets: AnyPublisher<NewContent, Never>!

    init(appSettings: AppSettings = AppDependencyProvider.shared.appSettings,
         contentBlockerRulesManager: ContentBlockerRulesManagerProtocol = ContentBlocking.shared.contentBlockingManager,
         privacyConfigurationManager: PrivacyConfigurationManaging = ContentBlocking.shared.privacyConfigurationManager) {

        let makeValue: (Update) -> NewContent = { rulesUpdate in
            let sourceProvider = DefaultScriptSourceProvider(appSettings: appSettings,
                                                             privacyConfigurationManager: privacyConfigurationManager,
                                                             contentBlockingManager: contentBlockerRulesManager)
            return NewContent(rulesUpdate: rulesUpdate, sourceProvider: sourceProvider)
        }

        func onNotificationWithInitial(_ name: Notification.Name) -> AnyPublisher<Notification, Never> {
            return NotificationCenter.default.publisher(for: name)
                .prepend([Notification(name: .init(rawValue: "initial"))])
                .eraseToAnyPublisher()
        }

        func combine(_ update: Update, _ notification: Notification) -> Update {
            var changes = update.changes
            changes[notification.name.rawValue] = .notification
            return Update(rules: update.rules, changes: changes, completionTokens: update.completionTokens)
        }

        // 1. Collect updates from ContentBlockerRulesManager and generate UserScripts based on its output
        cancellable = contentBlockerRulesManager.updatesPublisher
            // regenerate UserScripts on:
            // prefs changes notifications with initially published value for combineLatest to work.
            // Not all of these will trigger Tab reload,
            // refer TabViewController.swift:2116 for the list of notifications triggering reload
            .combineLatest(onNotificationWithInitial(PreserveLogins.Notifications.loginDetectionStateChanged), combine)
            .combineLatest(onNotificationWithInitial(AppUserDefaults.Notifications.doNotSellStatusChange), combine)
            .combineLatest(onNotificationWithInitial(AppUserDefaults.Notifications.autofillEnabledChange), combine)
            .combineLatest(onNotificationWithInitial(AppUserDefaults.Notifications.textSizeChange), combine)
            .combineLatest(onNotificationWithInitial(AppUserDefaults.Notifications.didVerifyInternalUser), combine)
            .combineLatest(onNotificationWithInitial(ConfigurationManager.didUpdateTrackerDependencies)
                .receive(on: DispatchQueue.main), combine)
            // DefaultScriptSourceProvider instance should be created once per rules/config change and fed into UserScripts initialization
            .map(makeValue)
            .assign(to: \.bufferedValue, onWeaklyHeld: self) // buffer latest update value

        // 2. Publish ContentBlockingAssets(Rules+Scripts) for WKUserContentController per subscription
        self.userContentBlockingAssets = $bufferedValue
            .compactMap { $0 } // drop initial nil
            .eraseToAnyPublisher()

    }

}
