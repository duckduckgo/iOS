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
import BrowserServicesKit

// swiftlint:disable file_length
// swiftlint:disable type_body_length

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
// swiftlint:enable type_body_length

    private static let ShowKeyboardOnLaunchThreshold = TimeInterval(20)
    
    private struct ShortcutKey {
        static let clipboard = "com.duckduckgo.mobile.ios.clipboard"
    }

    private var testing = false
    var appIsLaunching = false
    var overlayWindow: UIWindow?
    var window: UIWindow?

    private lazy var bookmarkStore: BookmarkStore = BookmarkUserDefaults()
    private lazy var privacyStore = PrivacyUserDefaults()
    private var autoClear: AutoClear?
    private var showKeyboardIfSettingOn = true
    private var lastBackgroundDate: Date?

    // MARK: lifecycle

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        #if targetEnvironment(simulator)
        if ProcessInfo.processInfo.environment["UITESTING"] == "true" {
            // Disable hardware keyboards.
            let setHardwareLayout = NSSelectorFromString("setHardwareLayout:")
            UITextInputMode.activeInputModes
                // Filter `UIKeyboardInputMode`s.
                .filter({ $0.responds(to: setHardwareLayout) })
                .forEach { $0.perform(setHardwareLayout, with: nil) }
        }
        #endif

        clearTmp()

        _ = UserAgentManager.shared
        testing = ProcessInfo().arguments.contains("testing")
        if testing {
            _ = UserAgentManager.shared
            Database.shared.loadStore { _ in }
            window?.rootViewController = UIStoryboard.init(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
            return true
        }

        DispatchQueue.global(qos: .background).async {
            ContentBlockerStringCache.removeLegacyData()
        }

        if !Database.shared.isDatabaseFileInitialized {
            let autofillStorage = EmailKeychainManager()
            autofillStorage.deleteAuthenticationState()
            autofillStorage.deleteWaitlistState()
        }
        
        Database.shared.loadStore(application: application) { context in
            DatabaseMigration.migrate(to: context)
        }
        
        BookmarksCoreDataStorage.shared.loadStoreAndCaches { context in
            BookmarksCoreDataStorageMigration.migrate(fromBookmarkStore: self.bookmarkStore, context: context)
        }
        
        HTTPSUpgrade.shared.loadDataAsync()
        
        // assign it here, because "did become active" is already too late and "viewWillAppear"
        // has already been called on the HomeViewController so won't show the home row CTA
        AtbAndVariantCleanup.cleanup()
        DefaultVariantManager().assignVariantIfNeeded { _ in
            // MARK: perform first time launch logic here
            DaxDialogs.shared.primeForUse()
        }

        if let main = mainViewController {
            autoClear = AutoClear(worker: main)
            autoClear?.applicationDidLaunch()
        }
        
        clearLegacyAllowedDomainCookies()

        // Task handler registration needs to happen before the end of `didFinishLaunching`, otherwise submitting a task can throw an exception.
        // Having both in `didBecomeActive` can sometimes cause the exception when running on a physical device, so registration happens here.
        AppConfigurationFetch.registerBackgroundRefreshTaskHandler()
        EmailWaitlist.shared.registerBackgroundRefreshTaskHandler()

        UNUserNotificationCenter.current().delegate = self
        
        window?.windowScene?.screenshotService?.delegate = self
        
        let manager = SecureVaultManager()
        manager.delegate = self
        let script = AutofillUserScript()
        let domain = "www.cnn.com"
        manager.autofillUserScript(script, didRequestStoreCredentialsForDomain: domain, username: "user", password: "password")

        manager.autofillUserScript(script, didRequestAccountsForDomain: domain) { thing in
            print(thing)
        }

        appIsLaunching = true
        return true
    }

    private func clearTmp() {
        let tmp = FileManager.default.temporaryDirectory
        do {
            try FileManager.default.removeItem(at: tmp)
        } catch {
            os_log("Failed to delete tmp dir")
        }
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

        mainViewController?.showBars()
        mainViewController?.didReturnFromBackground()
        
        if !privacyStore.authenticationEnabled {
            showKeyboardOnLaunch()
        }

        AppConfigurationFetch().start { newData in
            if newData {
                ContentBlockerRulesManager.shared.recompile()
            }
        }

        EmailWaitlist.shared.emailManager.fetchInviteCodeIfAvailable { result in
            switch result {
            case .success: EmailWaitlist.shared.sendInviteCodeAvailableNotification()
            case .failure: break
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
    
    private func shouldShowKeyboardOnLaunch() -> Bool {
        guard let date = lastBackgroundDate else { return true }
        return Date().timeIntervalSince(date) > AppDelegate.ShowKeyboardOnLaunchThreshold
    }

    private func showKeyboardOnLaunch() {
        guard KeyboardSettings().onAppLaunch && showKeyboardIfSettingOn && shouldShowKeyboardOnLaunch() else { return }
        self.mainViewController?.enterSearch()
        showKeyboardIfSettingOn = false
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
        ThemeManager.shared.updateUserInterfaceStyle()

        beginAuthentication()
        autoClear?.applicationWillMoveToForeground()
        showKeyboardIfSettingOn = true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        displayBlankSnapshotWindow()
        autoClear?.applicationDidEnterBackground()
        lastBackgroundDate = Date()
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
            mainViewController?.newTab(reuseExisting: true)
            if url.getParam(name: "w") != nil {
                Pixel.fire(pixel: .widgetNewSearch)
                mainViewController?.enterSearch()
            }
        } else if AppDeepLinks.isLaunchFavorite(url: url) {
            let query = AppDeepLinks.query(fromLaunchFavorite: url)
            mainViewController?.loadQueryInNewTab(query, reuseExisting: true)
            Pixel.fire(pixel: .widgetFavoriteLaunch)
        } else if AppDeepLinks.isQuickLink(url: url) {
            let query = AppDeepLinks.query(fromQuickLink: url)
            mainViewController?.loadQueryInNewTab(query, reuseExisting: true)
        } else if AppDeepLinks.isBookmarks(url: url) {
            mainViewController?.onBookmarksPressed()
        } else if AppDeepLinks.isFire(url: url) {
            if !privacyStore.authenticationEnabled {
                removeOverlay()
            }
            mainViewController?.onQuickFirePressed()
        } else if AppDeepLinks.isAddFavorite(url: url) {
            mainViewController?.startAddFavoriteFlow()
        } else {
            Pixel.fire(pixel: .defaultBrowserLaunch)
            mainViewController?.loadUrlInNewTab(url, reuseExisting: true)
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
        guard UIApplication.shared.backgroundRefreshStatus == .available else {
            return
        }

        // BackgroundTasks will automatically replace an existing task in the queue if one with the same identifier is queued, so we should only
        // schedule a task if there are none pending in order to avoid the config task getting perpetually replaced.
        BGTaskScheduler.shared.getPendingTaskRequests { tasks in
            let hasConfigurationTask = tasks.contains { $0.identifier == AppConfigurationFetch.Constants.backgroundProcessingTaskIdentifier }
            if !hasConfigurationTask {
                AppConfigurationFetch.scheduleBackgroundRefreshTask()
            }

            let hasWaitlistTask = tasks.contains { $0.identifier == EmailWaitlist.Constants.backgroundRefreshTaskIdentifier }
            if !hasWaitlistTask {
                EmailWaitlist.shared.scheduleBackgroundRefreshTask()
            }
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
        
        let overlay = BlankSnapshotViewController.loadFromStoryboard()
        overlay.delegate = self
        
        overlayWindow?.rootViewController = overlay
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
    
    private func tryToObtainOverlayWindow() {
        for window in UIApplication.shared.windows where window.rootViewController is BlankSnapshotViewController {
            overlayWindow = window
            return
        }
    }

    private func removeOverlay() {
        if overlayWindow == nil {
            tryToObtainOverlayWindow()
        }
        
        overlayWindow?.isHidden = true
        overlayWindow = nil
        window?.makeKeyAndVisible()
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

extension AppDelegate: BlankSnapshotViewRecoveringDelegate {
    
    func recoverFromPresenting(controller: BlankSnapshotViewController) {
        if overlayWindow == nil {
            tryToObtainOverlayWindow()
        }
        
        overlayWindow?.isHidden = true
        overlayWindow = nil
        window?.makeKeyAndVisible()
    }
    
}

extension AppDelegate: UIScreenshotServiceDelegate {
    func screenshotService(_ screenshotService: UIScreenshotService,
                           generatePDFRepresentationWithCompletion completionHandler: @escaping (Data?, Int, CGRect) -> Void) {
        guard #available(iOS 14.0, *), let webView = mainViewController?.currentTab?.webView else {
            completionHandler(nil, 0, .zero)
            return
        }

        let zoomScale = webView.scrollView.zoomScale

        // The PDF's coordinate space has its origin at the bottom left, so the view's origin.y needs to be converted
        let visibleBounds = CGRect(
            x: webView.scrollView.contentOffset.x / zoomScale,
            y: (webView.scrollView.contentSize.height - webView.scrollView.contentOffset.y - webView.bounds.height) / zoomScale,
            width: webView.bounds.width / zoomScale,
            height: webView.bounds.height / zoomScale
        )

        webView.createPDF { result in
            let data = try? result.get()
            completionHandler(data, 0, visibleBounds)
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if #available(iOS 14.0, *) {
            completionHandler(.banner)
        } else {
            completionHandler(.alert)
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            presentWaitlistSettingsModal()
        }

        completionHandler()
    }

    private func presentWaitlistSettingsModal() {
        guard let window = window, let rootViewController = window.rootViewController as? MainViewController else { return }

        rootViewController.clearNavigationStack()

        // Give the `clearNavigationStack` call time to complete.
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            rootViewController.performSegue(withIdentifier: "Settings", sender: nil)
            let navigationController = rootViewController.presentedViewController as? UINavigationController
            let waitlist = EmailWaitlistViewController.loadFromStoryboard()

            navigationController?.popToRootViewController(animated: false)
            navigationController?.pushViewController(waitlist, animated: true)
        }
    }

}

extension AppDelegate: SecureVaultManagerDelegate {
    
    func secureVaultManager(_: SecureVaultManager, promptUserToStoreCredentials credentials: SecureVaultModels.WebsiteCredentials) {

        // why does the secureVaultManagerDelegate do the actual factory making/saving?
        
        do {
            try SecureVaultFactory.default.makeVault().storeWebsiteCredentials(credentials)
        } catch {
            os_log("%: failed to store credentials %s", type: .error, #function, error.localizedDescription)
        }
    }

    func secureVaultManager(_: SecureVaultManager, didAutofill type: AutofillType, withObjectId objectId: Int64) {
        
    }

}
