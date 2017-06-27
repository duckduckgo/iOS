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
    
    var window: UIWindow?
    
    private lazy var bookmarkStore = BookmarkUserDefaults()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if let shortcutItem = launchOptions?[.shortcutItem] {
            handleShortCutItem(shortcutItem as! UIApplicationShortcutItem)
        }
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        startOnboardingFlowIfNotSeenBefore()
    }
    
    private func startOnboardingFlowIfNotSeenBefore() {
        var settings = TutorialSettings()
        if !settings.hasSeenOnboarding {
            startOnboardingFlow()
            settings.hasSeenOnboarding = true
        }
    }
    
    private func startOnboardingFlow() {
        guard let root = mainViewController() else { return }
        let onboardingController = OnboardingViewController.loadFromStoryboard()
        onboardingController.modalTransitionStyle = .flipHorizontal
        root.present(onboardingController, animated: false, completion: nil)
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        handleShortCutItem(shortcutItem)
    }
    
    private func handleShortCutItem(_ shortcutItem: UIApplicationShortcutItem) {
        Logger.log(text: "Handling shortcut item: \(shortcutItem.type)")
        if shortcutItem.type ==  ShortcutKey.search {
            clearNavigationStack()
        }
        if shortcutItem.type ==  ShortcutKey.clipboard, let query = UIPasteboard.general.string {
            mainViewController()?.loadQueryInNewTab(query)
        }
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        Logger.log(text: "App launched with url \(url.absoluteString)")
        clearNavigationStack()
        if AppDeepLinks.isLaunch(url: url) {
            return true
        }
        if AppDeepLinks.isQuickLink(url: url), let link = quickLink(from: url) {
            loadQuickLink(link: link)
        }
        return true
    }
    
    private func quickLink(from url: URL) -> Link? {
        guard let links = bookmarkStore.bookmarks else { return nil }
        guard let host = url.host else { return nil }
        guard let index = Int(host) else { return nil }
        guard index < links.count else { return nil }
        return links[index]
    }
    
    private func loadQuickLink(link: Link) {
        mainViewController()?.loadUrlInNewTab(link.url)
    }
    
    private func mainViewController() -> MainViewController? {
        return UIApplication.shared.keyWindow?.rootViewController?.childViewControllers.first as? MainViewController
    }
    
    private func clearNavigationStack() {
        if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
            navigationController.popToRootViewController(animated: false)
        }
    }
}

