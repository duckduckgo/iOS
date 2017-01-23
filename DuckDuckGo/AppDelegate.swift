//
//  AppDelegate.swift
//  Browser
//
//  Created by Sean Reilly on 2017.01.03.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import Foundation

let DDGSettingRecordHistory = "history"
let DDGSettingQuackOnRefresh = "quack"
let DDGSettingRegion = "region"
let DDGSettingAutocomplete = "autocomplete"
let DDGSettingSuppressBangTooltip = "suppress_bang_tooltip"
let DDGSettingStoriesReadabilityMode = "readability_mode"
let DDGSettingHomeView = "home_view"


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var searchController: DDGSearchController?
  
  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    self.save()
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    self.save()
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    //self.searchController.checkAndRefreshSettings()
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    self.save()
    self.clearCacheAndCookies()
  }


  func handleShortCutItem(_ shortcutItem: UIApplicationShortcutItem) {
    print("handleShortCutItem: \(shortcutItem.type)")
    switch shortcutItem.type {
    case "com.duckduckgo.mobile.ios.search":
      self.searchController?.loadQueryOrURL(shortcutItem.localizedTitle)
    case "com.duckduckgo.mobile.ios.newSearch":
      self.searchController?.clearAddressBar()
    }
  }
  
  func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
    self.handleShortCutItem(shortcutItem)
  }
  
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
    application.statusBarStyle = .lightContent
    URLProtocol.registerClass(DDGURLProtocol.self)
    NSSetUncaughtExceptionHandler { exception in print("CRASH: \(exception)") }
    
//    //Set the global URL cache to SDURLCache, which caches to disk
//    SDURLCache *urlCache = [[SDURLCache alloc] initWithMemoryCapacity:1024*1024*2 // 2MB mem cache
//    diskCapacity:1024*1024*10 // 10MB disk cache
//    diskPath:[SDURLCache defaultCachePath]];
//    [NSURLCache setSharedURLCache:urlCache];
  
  // possible re-enable this audio session, which was used to allow the playing of podcasts and media in the background.  I'm not sure it's necessary anymore.
//    //Audio session
//  AVAudioSession *audioSession = [AVAudioSession sharedInstance];
//  BOOL ok;
//  NSError *error = nil;
//  ok = [audioSession setActive:NO error:&error];
//  if (!ok)
//  NSLog(@"%s audioSession setActive:NO error=%@", __PRETTY_FUNCTION__, error);
//  
//  ok = [audioSession setCategory:AVAudioSessionCategoryPlayback
//  withOptions:AVAudioSessionCategoryOptionMixWithOthers
//  error:&error];
//  if (!ok)
//  NSLog(@"%s setCategoryError=%@", __PRETTY_FUNCTION__, error);
//  
//  //Active your audio session.
//  ok = [audioSession setActive:YES error:&error];
//  if(!ok) NSLog(@"%s audioSession setActive:YES error=%@", __PRETTY_FUNCTION__, error);

    self.searchController = DDGSearchController()
    self.searchController?.pushContentViewController(DDGDuckViewController(searchController:self.searchController!), animated: false)
    
    self.window?.backgroundColor = UIColor.duckSearchBarBackground()
    self.window?.rootViewController = self.searchController
    self.window?.makeKeyAndVisible()
    
    self.updateShortcuts()
    
    if let shortcutItem = launchOptions?[.shortcutItem] {
      self.handleShortCutItem(shortcutItem as! UIApplicationShortcutItem)
    }
    
    return true
  }
  
  func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
    // NOTE: remove this!  we should handle any incoming URL
    if(url.scheme?.lowercased() != "duckduckgo") {
      return false
    }
    
    // Let's see what the query is.
    var query : String?
    for param in (url.query?.components(separatedBy: "&"))! {
      let paramComps = param.components(separatedBy: "=")
      if paramComps.count>1 && paramComps[0].lowercased()=="q" {
        query = paramComps[1].removingPercentEncoding
      }
    }
  
    if let queryString = query {
      self.searchController?.loadQueryOrURL(queryString)
    } else {
      self.searchController?.prepareForUserInput()
    }
    
    return true
  }
  
  
  func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
    guard let url = userActivity.webpageURL else {
      return false
    }
    
    var query : String?
    if url.scheme?.lowercased()=="duckduckgo" {
      if let queryString = url.query {
        for param in queryString.components(separatedBy: "&") {
          let pair = param.components(separatedBy: "=")
          if pair.count > 1 && pair[0].lowercased() == "q" {
            query = pair[1].removingPercentEncoding
          }
        }
      }
    } else {
      query = DDGUtility.extractQuery(fromDDGURL: url)
    }
    
    if let queryString = query {
      self.searchController?.loadQueryOrURL(queryString)
    } else {
      self.searchController?.loadQueryOrURL(url.absoluteString)
    }
    
    return true
  }


  // update the 3D/force-touch home screen shortcuts
  func updateShortcuts() {
    let app = UIApplication.shared
    var shortcuts:[UIApplicationShortcutItem] = []
    
    let searchIcon = UIApplicationShortcutIcon.init(templateImageName: "Tab-Search")
    //let faveIcon = UIApplicationShortcutIcon.init(templateImageName: "Tab-Favorites")
    
    shortcuts.append(UIApplicationShortcutItem(type: "com.duckduckgo.mobile.ios.search",
                                               localizedTitle: "Open Clipboard",
                                               localizedSubtitle: "Open URL or search DuckDuckGo for the contents of your clipboard",
                                               icon: searchIcon,
                                               userInfo: nil))
    app.shortcutItems = shortcuts
  }
  
  func save() {
    // nothing to save for now
  }
  
  func clearCacheAndCookies() {
    var identifier : UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    UIApplication.shared.beginBackgroundTask(withName: "DuckDuckGo Cleanup", expirationHandler: {
      identifier = UIBackgroundTaskInvalid;
    })
    
    URLCache.shared.removeAllCachedResponses()
    let storage = HTTPCookieStorage.shared
    if let cookies = storage.cookies {
      for cookie in cookies {
        storage.deleteCookie(cookie)
      }
    }
    UserDefaults.standard.synchronize()
    UIApplication.shared.endBackgroundTask(identifier)
  }

}

