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
import UserNotifications
import os.log
import Kingfisher
import WidgetKit
import BackgroundTasks

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    private struct ShortcutKey {
        static let clipboard = "com.duckduckgo.mobile.ios.clipboard"
    }
    
    static var shared: AppDelegate {
        // swiftlint:disable force_cast
        return UIApplication.shared.delegate as! AppDelegate
        // swiftlint:enable force_cast
    }
    
    private var testing = false
    var appIsLaunching = false
    var overlayWindow: UIWindow?
    var window: UIWindow?

    private lazy var bookmarkStore: BookmarkStore = BookmarkUserDefaults()
    private lazy var privacyStore = PrivacyUserDefaults()
    private var autoClear: AutoClear?
    private var showKeyboardIfSettingOn = true

    // MARK: lifecycle

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        testing = ProcessInfo().arguments.contains("testing")
        if testing {
            Database.shared.loadStore { _ in }
            window?.rootViewController = UIStoryboard.init(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
            return true
        }

        _ = UserAgentManager.shared

        DispatchQueue.global(qos: .background).async {
            ContentBlockerStringCache.removeLegacyData()
        }
        
        Database.shared.loadStore(application: application) { context in
            DatabaseMigration.migrate(to: context)
        }
        
        HTTPSUpgrade.shared.loadDataAsync()
        
        // assign it here, because "did become active" is already too late and "viewWillAppear"
        // has already been called on the HomeViewController so won't show the home row CTA
        AtbAndVariantCleanup.cleanup()
        DefaultVariantManager().assignVariantIfNeeded { _ in
            // MARK: perform first time launch logic here
            DaxDialogs().primeForUse()
        }

        if let main = mainViewController {
            autoClear = AutoClear(worker: main)
            autoClear?.applicationDidLaunch()
        }
        
        clearLegacyAllowedDomainCookies()

        if #available(iOS 13.0, *) {
            // Task handler registration needs to happen before the end of `didFinishLaunching`, otherwise submitting a task can throw an exception.
            // Having both in `didBecomeActive` can sometimes cause the exception when running on a physical device, so registration happens here.
            AppConfigurationFetch.registerBackgroundRefreshTaskHandler()
        }
        
        appIsLaunching = true
        return true
    }

    private func clearLegacyAllowedDomainCookies() {
        let domains = PreserveLogins.shared.legacyAllowedDomains
        guard !domains.isEmpty else { return }
        WebCacheManager.shared.removeCookies(forDomains: domains, completion: {
            os_log("Removed cookies for %d legacy allowed domains", domains.count)
            PreserveLogins.shared.clearLegacyAllowedDomains()
        })
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        guard !testing else { return }
        
        if !(overlayWindow?.rootViewController is AuthenticationViewController) {
            removeOverlay()
        }
        
        StatisticsLoader.shared.load {
            StatisticsLoader.shared.refreshAppRetentionAtb()
            self.fireAppLaunchPixel()
        }
        
        if appIsLaunching {
            appIsLaunching = false
            onApplicationLaunch(application)
        }
        
        if !privacyStore.authenticationEnabled {
            showKeyboardOnLaunch()
        }

        AppConfigurationFetch().start { newData in
            if newData {
                NotificationCenter.default.post(name: ContentBlockerProtectionChangedNotification.name, object: nil)
            }
        }
    }

    private func fireAppLaunchPixel() {

        if #available(iOS 14, *) {
            WidgetCenter.shared.getCurrentConfigurations { result in

                let paramKeys: [WidgetFamily: String] = [
                    .systemSmall: PixelParameters.widgetSmall,
                    .systemMedium: PixelParameters.widgetMedium,
                    .systemLarge: PixelParameters.widgetLarge
                ]

                switch result {
                case .failure(let error):
                    Pixel.fire(pixel: .appLaunch, withAdditionalParameters: [
                        PixelParameters.widgetError: "1",
                        PixelParameters.widgetErrorCode: "\((error as NSError).code)",
                        PixelParameters.widgetErrorDomain: (error as NSError).domain
                    ])

                case .success(let widgetInfo):
                    let params = widgetInfo.reduce([String: String]()) {
                        var result = $0
                        if let key = paramKeys[$1.family] {
                            result[key] = "1"
                        }
                        return result
                    }
                    Pixel.fire(pixel: .appLaunch, withAdditionalParameters: params)
                }

            }
        } else {
            Pixel.fire(pixel: .appLaunch, withAdditionalParameters: [PixelParameters.widgetUnavailable: "1"])
        }

    }

    private func showKeyboardOnLaunch() {
        guard KeyboardSettings().onAppLaunch && showKeyboardIfSettingOn else { return }
        self.mainViewController?.enterSearch()
        showKeyboardIfSettingOn = false
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        displayBlankSnapshotWindow()
    }
    
    private func onApplicationLaunch(_ application: UIApplication) {
        beginAuthentication()
        initialiseBackgroundFetch(application)
        applyAppearanceChanges()
    }
    
    private func applyAppearanceChanges() {
        UILabel.appearance(whenContainedInInstancesOf: [UIAlertController.self]).numberOfLines = 0
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        beginAuthentication()
        autoClear?.applicationWillMoveToForeground()
        showKeyboardIfSettingOn = true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        autoClear?.applicationDidEnterBackground()
    }

    func application(_ application: UIApplication,
                     performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Void) {
        handleShortCutItem(shortcutItem)
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        os_log("App launched with url %s", log: lifecycleLog, type: .debug, url.absoluteString)
        mainViewController?.clearNavigationStack()
        autoClear?.applicationWillMoveToForeground()
        showKeyboardIfSettingOn = false
        
        if AppDeepLinks.isNewSearch(url: url) {
            mainViewController?.newTab()
            if url.getParam(name: "w") != nil {
                Pixel.fire(pixel: .widgetNewSearch)
                mainViewController?.enterSearch()
            }
        } else if AppDeepLinks.isLaunchFavorite(url: url) {
            let query = AppDeepLinks.query(fromLaunchFavorite: url)
            mainViewController?.loadQueryInNewTab(query)
            Pixel.fire(pixel: .widgetFavoriteLaunch)
        } else if AppDeepLinks.isQuickLink(url: url) {
            let query = AppDeepLinks.query(fromQuickLink: url)
            mainViewController?.loadQueryInNewTab(query)
        } else if AppDeepLinks.isBookmarks(url: url) {
            mainViewController?.onBookmarksPressed()
        } else if AppDeepLinks.isFire(url: url) {
            if !privacyStore.authenticationEnabled {
                removeOverlay()
            }
            mainViewController?.onQuickFirePressed()
        } else {
            Pixel.fire(pixel: .defaultBrowserLaunch)
            mainViewController?.loadUrlInNewTab(url)
        }
        
        return true
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        os_log(#function, log: lifecycleLog, type: .debug)

        AppConfigurationFetch().start(isBackgroundFetch: true) { newData in
            completionHandler(newData ? .newData : .noData)
        }
    }

    func application(_ application: UIApplication, willContinueUserActivityWithType userActivityType: String) -> Bool {
        return true
    }

    // MARK: private

    private func initialiseBackgroundFetch(_ application: UIApplication) {
        if #available(iOS 13.0, *) {
            // BackgroundTasks will automatically replace an existing task in the queue if one with the same identifier is queued, so we should only
            // schedule a task if there are none pending in order to avoid the config task getting perpetually replaced.
            BGTaskScheduler.shared.getPendingTaskRequests { tasks in
                guard tasks.isEmpty else {
                    return
                }

                AppConfigurationFetch.scheduleBackgroundRefreshTask()
            }
        } else {
            application.setMinimumBackgroundFetchInterval(60 * 60 * 24)
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
        guard autoClear?.isClearingEnabled ?? false || privacyStore.authenticationEnabled else { return }
        
        overlayWindow = UIWindow(frame: frame)
        overlayWindow?.windowLevel = UIWindow.Level.alert
        overlayWindow?.rootViewController = BlankSnapshotViewController.loadFromStoryboard()
        overlayWindow?.makeKeyAndVisible()
        window?.isHidden = true
    }

    private func beginAuthentication() {
        
        guard privacyStore.authenticationEnabled else { return }

        removeOverlay()
        displayAuthenticationWindow()
        
        guard let controller = overlayWindow?.rootViewController as? AuthenticationViewController else {
            removeOverlay()
            return
        }
        
        controller.beginAuthentication { [weak self] in
            self?.removeOverlay()
            self?.showKeyboardOnLaunch()
        }
    }

    private func removeOverlay() {
        window?.makeKeyAndVisible()
        overlayWindow = nil
    }

    private func handleShortCutItem(_ shortcutItem: UIApplicationShortcutItem) {
        os_log("Handling shortcut item: %s", log: generalLog, type: .debug, shortcutItem.type)
        mainViewController?.clearNavigationStack()
        autoClear?.applicationWillMoveToForeground()
        if shortcutItem.type ==  ShortcutKey.clipboard, let query = UIPasteboard.general.string {
            mainViewController?.loadQueryInNewTab(query)
        }
    }

    private var mainViewController: MainViewController? {
        return window?.rootViewController as? MainViewController
    }
}
