//
//  AppDelegate.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

import UIKit
import Core

@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate {

    static let ShowKeyboardOnLaunchThreshold = TimeInterval(20)
    struct ShortcutKey {
        static let clipboard = "com.duckduckgo.mobile.ios.clipboard"
        static let passwords = "com.duckduckgo.mobile.ios.passwords"
        static let openVPNSettings = "com.duckduckgo.mobile.ios.vpn.open-settings"
    }

    private let appStateMachine: AppStateMachine = AppStateMachine()

    var window: UIWindow?

    /// See: Launching.swift
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let isTesting: Bool = ProcessInfo().arguments.contains("testing")
        appStateMachine.handle(.didFinishLaunching(application, isTesting: isTesting))
        return true
    }

    /// See: Foreground.swift
    func applicationDidBecomeActive(_ application: UIApplication) {
        appStateMachine.handle(.didBecomeActive)
    }

    /// See: Suspending.swift
    func applicationWillResignActive(_ application: UIApplication) {
        appStateMachine.handle(.willResignActive)
    }

    /// See: Resuming.swift
    func applicationWillEnterForeground(_ application: UIApplication) {
        appStateMachine.handle(.willEnterForeground)
    }

    /// See: Background.swift
    func applicationDidEnterBackground(_ application: UIApplication) {
        appStateMachine.handle(.didEnterBackground)
    }

    func application(_ application: UIApplication,
                     performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Void) {
        appStateMachine.handle(.handleShortcutItem(shortcutItem))
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        appStateMachine.handle(.openURL(url))
        return true
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        Logger.lifecycle.debug(#function)

        AppConfigurationFetch().start(isBackgroundFetch: true) { result in
            switch result {
            case .noData:
                completionHandler(.noData)
            case .assetsUpdated:
                completionHandler(.newData)
            }
        }
    }

    func application(_ application: UIApplication, willContinueUserActivityWithType userActivityType: String) -> Bool {
        true
    }

    var privacyProDataReporter: PrivacyProDataReporting? {
        (appStateMachine.currentState as? Foreground)?.appDependencies.privacyProDataReporter // just for now, we have to get rid of this anti pattern
    }

    /// It's public in order to allow refreshing on demand via Debug menu. Otherwise it shouldn't be called from outside.
    /// we have to get rid of this anti pattern
    func refreshRemoteMessages() {
        Task {
            if let remoteMessagingClient = (appStateMachine.currentState as? Foreground)?.appDependencies.remoteMessagingClient {
                try? await remoteMessagingClient.fetchAndProcess(using: remoteMessagingClient.store)
            }
        }
    }

}

extension DataStoreWarmup.ApplicationState {

    init(with state: UIApplication.State) {
        switch state {
        case .inactive:
            self = .inactive
        case .active:
            self = .active
        case .background:
            self = .background
        @unknown default:
            self = .unknown
        }
    }
}

extension Error {

    var isDiskFull: Bool {
        let nsError = self as NSError
        if let underlyingError = nsError.userInfo["NSUnderlyingError"] as? NSError, underlyingError.code == 13 {
            return true
        } else if nsError.userInfo["NSSQLiteErrorDomain"] as? Int == 13 {
            return true
        }
        return false
    }

}
