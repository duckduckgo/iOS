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

protocol ContentBlockerRulesManagerProtocol: AnyObject {
    var updatesPublisher: AnyPublisher<ContentBlockerRulesManager.UpdateEvent, Never> { get }
    var currentRules: [ContentBlockerRulesManager.Rules] { get }
}
extension ContentBlockerRulesManager: ContentBlockerRulesManagerProtocol {}

extension ContentBlockerRulesIdentifier.Difference {
    static let notification = ContentBlockerRulesIdentifier.Difference(rawValue: 1 << 8)
}

public final class ContentBlockingUpdating {
    fileprivate static let shared = ContentBlockingUpdating()

    private typealias Update = ContentBlockerRulesManager.UpdateEvent
    private struct BufferedValue {
        let rulesUpdate: Update
        let sourceProvider: ScriptSourceProviding

        init(rulesUpdate: Update, sourceProvider: ScriptSourceProviding) {
            self.rulesUpdate = rulesUpdate
            self.sourceProvider = sourceProvider
        }
    }

    @Published private var bufferedValue: BufferedValue?
    private var cancellable: AnyCancellable?

    private(set) var userContentBlockingAssets: AnyPublisher<UserContentController.ContentBlockingAssets, Never>!

    init(contentBlockerRulesManager: ContentBlockerRulesManagerProtocol = ContentBlocking.shared.contentBlockingManager,
         privacyConfigurationManager: PrivacyConfigurationManager = ContentBlocking.shared.privacyConfigurationManager) {

        let makeValue: (Update) -> BufferedValue = { rulesUpdate in
            let sourceProvider = DefaultScriptSourceProvider(privacyConfigurationManager: privacyConfigurationManager,
                                                             contentBlockingManager: contentBlockerRulesManager)
            return BufferedValue(rulesUpdate: rulesUpdate, sourceProvider: sourceProvider)
        }

        let transform: (Update, Notification) -> Update = { update, notification in
            var update = update
            update.changes[notification.name.rawValue] = .notification
            return update
        }

        let nc = NotificationCenter.default

        // 1. Collect updates from ContentBlockerRulesManager and generate UserScripts based on its output
        cancellable = contentBlockerRulesManager.updatesPublisher
            // regenerate UserScripts on:
            // prefs changes notifications
            .combineLatest(nc.publisher(for: PreserveLogins.Notifications.loginDetectionStateChanged), transform)
            .combineLatest(nc.publisher(for: AppUserDefaults.Notifications.doNotSellStatusChange), transform)
            .combineLatest(nc.publisher(for: AppUserDefaults.Notifications.autofillEnabledChange), transform)
            .combineLatest(nc.publisher(for: AppUserDefaults.Notifications.textSizeChange), transform)
            .combineLatest(nc.publisher(for: AppUserDefaults.Notifications.didVerifyInternalUser), transform)
            .combineLatest(nc.publisher(for: StorageCacheProvider.didUpdateStorageCacheNotification)
                .receive(on: DispatchQueue.main), transform)
            // gpcEnabled preference updated
        // TODO: on ContentBlocking.onStoreChanged
        // TODO: On privacy security preferences update
//            .combineLatest(privacySecurityPreferences.$gpcEnabled)
            // drop gpcEnabled value: $0.1
            // DefaultScriptSourceProvider instance should be created once per rules/config change and fed into UserScripts initialization
            .map(makeValue)
            .assign(to: \.bufferedValue, on: self) // buffer latest update value // TODO: onWeaklyHeld

        // 2. Publish ContentBlockingAssets(Rules+Scripts) for WKUserContentController per subscription
        self.userContentBlockingAssets = $bufferedValue
            .compactMap { $0 } // drop initial nil
            .map { value in
                UserContentController.ContentBlockingAssets(contentRuleLists: value.rulesUpdate.rules
                                                                .reduce(into: [String: WKContentRuleList](), { result, rules in
                                                                    result[rules.name] = rules.rulesList
                                                                }),
                                                            userScripts: UserScripts(with: value.sourceProvider),
                                                            updateEvent: value.rulesUpdate)
            }
            .eraseToAnyPublisher()

    }

}
