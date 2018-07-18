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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    private struct ShortcutKey {
        static let search = "com.duckduckgo.mobile.ios.newsearch"
        static let clipboard = "com.duckduckgo.mobile.ios.clipboard"
    }

    private var testing = false
    private var appIsLaunching = false
    var authWindow: UIWindow?
    var window: UIWindow?

    private lazy var bookmarkStore: BookmarkUserDefaults = BookmarkUserDefaults()

    // MARK: lifecycle

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        testing = ProcessInfo().arguments.contains("testing")
        if testing {
            window?.rootViewController = UIStoryboard.init(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        }

        // assign it here, because "did become active" is already too late and "viewWillAppear"
        // has already been called on the HomeViewController so won't show the home row CTA
        AtbAndVariantCleanup.cleanup()
        DefaultVariantManager().assignVariantIfNeeded()

        appIsLaunching = true
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        guard !testing else { return }

        Pixel.fire(pixel: .appLaunch)
        startMigration(application: application)
        StatisticsLoader.shared.load()
        startOnboardingFlowIfNotSeenBefore()
        if appIsLaunching {
            appIsLaunching = false
            BlockerListsLoader().start(completion: nil)
            displayAuthenticationWindow()
            beginAuthentication()
            initialiseBackgroundFetch(application)
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        beginAuthentication()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        displayAuthenticationWindow()
    }

    func application(_ application: UIApplication,
                     performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Void) {
        handleShortCutItem(shortcutItem)
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        Logger.log(text: "App launched with url \(url.absoluteString)")
        clearNavigationStack()
        if AppDeepLinks.isQuickLink(url: url) {
            let query = AppDeepLinks.query(fromQuickLink: url)
            mainViewController?.loadQueryInNewTab(query)
        }
        return true
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        Logger.log(items: #function)

        BlockerListsLoader().start { newData in
            completionHandler(newData ? .newData : .noData)
        }

    }

    // MARK: private

    private func initialiseBackgroundFetch(_ application: UIApplication) {
        application.setMinimumBackgroundFetchInterval(60 * 60 * 24)
    }

    private func displayAuthenticationWindow() {
        let privacyStore = PrivacyUserDefaults()
        guard authWindow == nil, let frame = window?.frame, privacyStore.authenticationEnabled else { return }
        authWindow = UIWindow(frame: frame)
        authWindow?.rootViewController = AuthenticationViewController.loadFromStoryboard()
        authWindow?.makeKeyAndVisible()
        window?.isHidden = true
    }

    private func beginAuthentication() {
        guard let controller = authWindow?.rootViewController as? AuthenticationViewController else { return }
        controller.beginAuthentication { [weak self] in
            self?.completeAuthentication()
        }
    }

    private func completeAuthentication() {
        window?.makeKeyAndVisible()
        authWindow = nil
    }

    private func startOnboardingFlowIfNotSeenBefore() {
        guard let main = mainViewController else { return }
        let settings = TutorialSettings()
        if !settings.hasSeenOnboarding {
            main.showOnboarding()
        }
    }

    private func startMigration(application: UIApplication) {
        // This should happen so fast that it's complete by the time the user finishes onboarding.  
        Migration().start { occurred, storiesMigrated, bookmarksMigrated in
            Logger.log(items: "Migration completed", occurred, storiesMigrated, bookmarksMigrated)
            if occurred {
                DispatchQueue.main.async {
                    application.shortcutItems = []
                }
            }
        }
    }

    private func handleShortCutItem(_ shortcutItem: UIApplicationShortcutItem) {
        Logger.log(text: "Handling shortcut item: \(shortcutItem.type)")
        clearNavigationStack()
        if shortcutItem.type ==  ShortcutKey.search {
            mainViewController?.launchNewSearch()
        }
        if shortcutItem.type ==  ShortcutKey.clipboard, let query = UIPasteboard.general.string {
            mainViewController?.loadQueryInNewTab(query)
        }
    }

    private var mainViewController: MainViewController? {
        return window?.rootViewController as? MainViewController
    }

    private func clearNavigationStack() {
        if let presented = mainViewController?.presentedViewController {
            presented.dismiss(animated: false) { [weak self] in
                self?.clearNavigationStack()
            }
        }
    }
}
