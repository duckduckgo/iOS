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
        static let clipboard = "com.duckduckgo.mobile.ios.clipboard"
    }
    
    private var testing = false
    private var appIsLaunching = false
    var overlayWindow: UIWindow?
    var window: UIWindow?

    private lazy var bookmarkStore: BookmarkStore = BookmarkUserDefaults()
    private lazy var privacyStore = PrivacyUserDefaults()
    private var autoClear: AutoClear?

    // MARK: lifecycle

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        testing = ProcessInfo().arguments.contains("testing")
        if testing {
            window?.rootViewController = UIStoryboard.init(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        }

        HTTPSUpgrade.shared.loadDataAsync()
        
        // assign it here, because "did become active" is already too late and "viewWillAppear"
        // has already been called on the HomeViewController so won't show the home row CTA
        AtbAndVariantCleanup.cleanup()
        DefaultVariantManager().assignVariantIfNeeded()
        HomePageConfiguration.installNewUserFavorites()
        
        if !testing {
            autoClear = AutoClear(worker: mainViewController!)
            autoClear?.applicationDidLaunch()
        }

        appIsLaunching = true
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        guard !testing else { return }
        
        Pixel.fire(pixel: .appLaunch)
        StatisticsLoader.shared.load()
        startOnboardingFlowIfNotSeenBefore()
        
        if appIsLaunching {
            appIsLaunching = false
            onApplicationLaunch(application)
        }
    }
    
    private func onApplicationLaunch(_ application: UIApplication) {
       
        if privacyStore.authenticationEnabled {
            displayAuthenticationWindow()
            beginAuthentication()
        }
        
        AppConfigurationFetch().start(completion: nil)
        initialiseBackgroundFetch(application)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        if privacyStore.authenticationEnabled {
            beginAuthentication()
        } else {
            removeOverlay()
        }
        autoClear?.applicationWillMoveToForeground()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        displayOverlay()
        autoClear?.applicationDidEnterBackground()
    }

    func application(_ application: UIApplication,
                     performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Void) {
        handleShortCutItem(shortcutItem)
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        Logger.log(text: "App launched with url \(url.absoluteString)")
        clearNavigationStack()
        autoClear?.applicationWillMoveToForeground()
        
        if AppDeepLinks.isNewSearch(url: url) {
            mainViewController?.launchNewSearch()
        } else if AppDeepLinks.isQuickLink(url: url) {
            let query = AppDeepLinks.query(fromQuickLink: url)
            mainViewController?.loadQueryInNewTab(query)
        } else if AppDeepLinks.isBookmarks(url: url) {
            mainViewController?.onBookmarksPressed()
        } else if AppDeepLinks.isFire(url: url) {
            mainViewController?.onQuickFirePressed()
        }
        return true
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        Logger.log(items: #function)

        AppConfigurationFetch().start { newData in
            completionHandler(newData ? .newData : .noData)
        }
    }

    // MARK: private

    private func initialiseBackgroundFetch(_ application: UIApplication) {
        application.setMinimumBackgroundFetchInterval(60 * 60 * 24)
    }
    
    private func displayOverlay() {
        if privacyStore.authenticationEnabled {
            displayAuthenticationWindow()
        } else {
            displayBlankSnapshotWindow()
        }
    }

    private func displayAuthenticationWindow() {
        guard overlayWindow == nil, let frame = window?.frame else { return }
        overlayWindow = UIWindow(frame: frame)
        overlayWindow?.windowLevel = UIWindow.Level.alert
        overlayWindow?.rootViewController = AuthenticationViewController.loadFromStoryboard()
        overlayWindow?.makeKeyAndVisible()
        window?.isHidden = true
    }
    
    private func displayBlankSnapshotWindow() {
        guard overlayWindow == nil, let frame = window?.frame else { return }
        guard autoClear?.isClearingEnabled ?? false else { return }
        
        overlayWindow = UIWindow(frame: frame)
        overlayWindow?.windowLevel = UIWindow.Level.alert
        overlayWindow?.rootViewController = BlankSnapshotViewController.loadFromStoryboard()
        overlayWindow?.makeKeyAndVisible()
        window?.isHidden = true
    }

    private func beginAuthentication() {
        guard let controller = overlayWindow?.rootViewController as? AuthenticationViewController else {
            removeOverlay()
            return
        }
        controller.beginAuthentication { [weak self] in
            self?.removeOverlay()
        }
    }

    private func removeOverlay() {
        window?.makeKeyAndVisible()
        overlayWindow = nil
    }

    private func startOnboardingFlowIfNotSeenBefore() {
        guard let main = mainViewController else { return }
        let settings = TutorialSettings()
        if !settings.hasSeenOnboarding {
            main.showOnboarding()
        }
    }

    private func handleShortCutItem(_ shortcutItem: UIApplicationShortcutItem) {
        Logger.log(text: "Handling shortcut item: \(shortcutItem.type)")
        clearNavigationStack()
        autoClear?.applicationWillMoveToForeground()
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
