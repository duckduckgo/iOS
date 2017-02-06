//
//  AppDelegate.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 18/01/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit

let DDGSettingRegion = "region"
let DDGSettingAutocomplete = "autocomplete"
let DDGSettingSuppressBangTooltip = "suppress_bang_tooltip"
let DDGSettingStoriesReadabilityMode = "readability_mode"


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var duckController: DDGSearchController?

  
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
      application.statusBarStyle = .lightContent
      
      NSSetUncaughtExceptionHandler { exception in print("CRASH: \(exception)") }
      
      self.updateShortcuts()
      
      if let shortcutItem = launchOptions?[.shortcutItem] {
        self.handleShortCutItem(shortcutItem as! UIApplicationShortcutItem)
      }
      
      return true
    }
  
  
  func handleShortCutItem(_ shortcutItem: UIApplicationShortcutItem) {
    print("handleShortCutItem: \(shortcutItem.type)")
    switch shortcutItem.type {
    case "com.duckduckgo.mobile.ios.search":
      self.duckController?.loadQueryOrURL(shortcutItem.localizedTitle)
    case "com.duckduckgo.mobile.ios.searchclipboard":
      if let pasteboardString = UIPasteboard.general.string {
        self.duckController?.loadQueryOrURL(pasteboardString)
      } else {
        self.duckController?.clearAddressBar()
      }
    case "com.duckduckgo.mobile.ios.newSearch":
      self.duckController?.clearAddressBar()
    default:
      break
    }
  }
  

  // update the 3D/force-touch home screen shortcuts
  func updateShortcuts() {
    let app = UIApplication.shared
    var shortcuts:[UIApplicationShortcutItem] = []
    
    let searchIcon = UIApplicationShortcutIcon.init(templateImageName: "Tab-Search")
    //let faveIcon = UIApplicationShortcutIcon.init(templateImageName: "Tab-Favorites")
    
    shortcuts.append(UIApplicationShortcutItem(type: "com.duckduckgo.mobile.ios.searchclipboard",
                                               localizedTitle: "Open Clipboard",
                                               localizedSubtitle: "Open URL or search DuckDuckGo for the contents of your clipboard",
                                               icon: searchIcon,
                                               userInfo: nil))
    app.shortcutItems = shortcuts
  }
  

}

