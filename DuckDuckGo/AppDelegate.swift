//
//  AppDelegate.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 18/01/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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
    
    private var groupData = GroupData()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if let shortcutItem = launchOptions?[.shortcutItem] {
            handleShortCutItem(shortcutItem as! UIApplicationShortcutItem)
        }
        return true
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
            homeViewController()?.loadBrowserQuery(query: query)
        }
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        Logger.log(text: "App launched with url \(url.absoluteString)")
        clearNavigationStack()
        if AppUrls.isLaunch(url: url) {
            return true
        }
        if AppUrls.isQuickLink(url: url), let link = quickLink(from: url) {
            loadQuickLink(link: link)
        }
        return true
    }
    
    private func quickLink(from url: URL) -> Link? {
        guard let links = groupData.quickLinks,
            let host = url.host,
            let index = Int(host),
            index < links.count else {
                return nil
        }
        return links[index]
    }
    
    private func loadQuickLink(link: Link) {
        homeViewController()?.loadBrowserUrl(url: link.url)
    }
    
    private func homeViewController() -> HomeViewController? {
        return UIApplication.shared.keyWindow?.rootViewController?.childViewControllers.first as? HomeViewController
    }
    
    private func clearNavigationStack() {
        if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
            navigationController.popToRootViewController(animated: false)
        }
    }
}

