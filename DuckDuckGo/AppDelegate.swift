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

    private var appIsLaunching = false
    var authWindow: UIWindow?
    var window: UIWindow?
    
    private lazy var bookmarkStore = BookmarkUserDefaults()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        appIsLaunching = true
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        startMigration()
        StatisticsLoader.shared.load()
        TrackerLoader.shared.updateTrackers()
        
        var tutorialSettings = TutorialSettings()
        if !tutorialSettings.hasSeenOnboarding {
            startOnboardingFlow()
        }

        if appIsLaunching {
            appIsLaunching = false
            displayAuthenticationWindow()
            beginAuthentication()
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        beginAuthentication()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        displayAuthenticationWindow()
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
        controller.beginAuthentication() { [weak self] in
            self?.completeAuthentication()
        }
    }
    
    private func completeAuthentication() {
        window?.makeKeyAndVisible()
        authWindow = nil
    }
    
    private func startMigration() {
        // This should happen so fast that it's complete by the time the user finishes onboarding.  
        //  On subsequent calls there won't be anything to do anyway so will finish pretty much instantly.
        Migration().start { storiesMigrated, bookmarksMigrated in
            Logger.log(items: "Migration completed", storiesMigrated, bookmarksMigrated)
        }
    }
    
    private func startOnboardingFlow() {
        guard let main = mainViewController else { return }
        let onboardingController = OnboardingViewController.loadFromStoryboard()
        onboardingController.modalTransitionStyle = .flipHorizontal
        main.present(onboardingController, animated: false) {
            var settings = TutorialSettings()
            settings.hasSeenOnboarding = true
        }
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        handleShortCutItem(shortcutItem)
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
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        Logger.log(text: "App launched with url \(url.absoluteString)")
        clearNavigationStack()
        if AppDeepLinks.isQuickLink(url: url) {
            let query = AppDeepLinks.query(fromQuickLink: url)
            mainViewController?.loadQueryInNewTab(query)
        }
        return true
    }
    
    private var rootViewController: UINavigationController? {
        return window?.rootViewController as? UINavigationController
    }
    
    private var mainViewController: MainViewController? {
        return rootViewController?.childViewControllers.first as? MainViewController
    }
    
    private func clearNavigationStack() {
        rootViewController?.topViewController?.dismiss(animated: false) {
            self.rootViewController?.popToRootViewController(animated: false)
        }
    }
}

