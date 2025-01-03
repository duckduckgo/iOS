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

enum AppBehavior: String {

    case old
    case new

}

protocol DDGApp {

    var privacyProDataReporter: PrivacyProDataReporting? { get }
    
    func initialize()
    func refreshRemoteMessages()

}

@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate {

    static let ShowKeyboardOnLaunchThreshold = TimeInterval(20)
    struct ShortcutKey {
        static let clipboard = "com.duckduckgo.mobile.ios.clipboard"
        static let passwords = "com.duckduckgo.mobile.ios.passwords"
        static let openVPNSettings = "com.duckduckgo.mobile.ios.vpn.open-settings"
    }

    var window: UIWindow?

    var privacyProDataReporter: PrivacyProDataReporting? {
        realDelegate.privacyProDataReporter
    }

    func forceOldAppDelegate() {
        BoolFileMarker(name: .forceOldAppDelegate)?.mark()
    }

    private let appBehavior: AppBehavior = {
        BoolFileMarker(name: .forceOldAppDelegate)?.isPresent == true ? .old : .new
    }()

    private lazy var realDelegate: UIApplicationDelegate & DDGApp = {
        if appBehavior == .old {
            return OldAppDelegate(with: self)
        } else {
            return NewAppDelegate()
        }
    }()

    override init() {
        super.init()
        realDelegate.initialize()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        realDelegate.application?(application, didFinishLaunchingWithOptions: launchOptions) ?? false
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        realDelegate.applicationDidBecomeActive?(application)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        realDelegate.applicationWillResignActive?(application)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        realDelegate.applicationWillEnterForeground?(application)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        realDelegate.applicationDidEnterBackground?(application)
    }

    func application(_ application: UIApplication,
                     performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Void) {
        realDelegate.application?(application, performActionFor: shortcutItem, completionHandler: completionHandler)
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        realDelegate.application?(app, open: url, options: options) ?? false
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
        return true
    }

    /// It's public in order to allow refreshing on demand via Debug menu. Otherwise it shouldn't be called from outside.
    func refreshRemoteMessages() {
        realDelegate.refreshRemoteMessages()
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
        }

        if nsError.userInfo["NSSQLiteErrorDomain"] as? Int == 13 {
            return true
        }
        
        return false
    }

}

private extension BoolFileMarker.Name {

    static let forceOldAppDelegate = BoolFileMarker.Name(rawValue: "force-old-app-delegate")

}
