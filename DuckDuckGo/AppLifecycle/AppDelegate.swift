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

public extension NSNotification.Name {

    static let appDidEncounterUnrecoverableState = Notification.Name("com.duckduckgo.app.unrecoverable.state")

}

@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate {

    private let appStateMachine: AppStateMachine = AppStateMachine()

    var window: UIWindow?

    override init() {
        super.init()
        NotificationCenter.default.addObserver(forName: .databaseDidEncounterInsufficientDiskSpace,
                                               object: nil,
                                               queue: .main) { [weak self] _ in
            self?.application(UIApplication.shared, willTerminateWithReason: .insufficientDiskSpace)
        }
        NotificationCenter.default.addObserver(forName: .appDidEncounterUnrecoverableState,
                                               object: nil,
                                               queue: .main) { [weak self] _ in
            self?.application(UIApplication.shared, willTerminateWithReason: .unrecoverableState)
        }
    }

    /// See: `Launching.swift`
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let isTesting: Bool = ProcessInfo().arguments.contains("testing")
        appStateMachine.handle(.didFinishLaunching(isTesting: isTesting))
        return true
    }

    /// See: `Foreground.swift` -> `onTransition()`
    func applicationDidBecomeActive(_ application: UIApplication) {
        appStateMachine.handle(.didBecomeActive)
    }

    /// See: `Foreground.swift` -> `willLeave()`
    func applicationWillResignActive(_ application: UIApplication) {
        appStateMachine.handle(.willResignActive)
    }

    /// See: `Background.swift` -> `willLeave()`
    func applicationWillEnterForeground(_ application: UIApplication) {
        appStateMachine.handle(.willEnterForeground)
    }

    /// See: `Background.swift` -> `onTransition()`
    func applicationDidEnterBackground(_ application: UIApplication) {
        appStateMachine.handle(.didEnterBackground)
    }

    /// See: `Terminating.swift`
    /// **Note** This is *not* the system function `applicationWillTerminate(_:)`, and it is *not* called by the system.
    /// This is used to handle force crashes due to unrecoverable errors (e.g., low disk space) and display an alert beforehand.
    func application(_ application: UIApplication, willTerminateWithReason terminationReason: UIApplication.TerminationReason) {
        appStateMachine.handle(.willTerminate(terminationReason))
    }

    /// See: `Foreground.swift` -> `handleShortcutItem(_:)`
    func application(_ application: UIApplication,
                     performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Void) {
        appStateMachine.handle(.handleShortcutItem(shortcutItem))
    }

    /// See: `Foreground.swift` -> `openURL(_:)`
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

    // MARK: - Debug
    /// These are public to allow access via Debug menu. Otherwise they shouldn't be called from outside.
    /// Avoid abusing this pattern. Inject dependencies where needed instead of relying on global access.
    var debugPrivacyProDataReporter: PrivacyProDataReporting? {
        (appStateMachine.currentState as? Foreground)?.appDependencies.reportingService.privacyProDataReporter
    }

    func debugRefreshRemoteMessages() {
        if let remoteMessagingService = (appStateMachine.currentState as? Foreground)?.appDependencies.remoteMessagingService {
            remoteMessagingService.refreshRemoteMessages()
        }
    }

}
