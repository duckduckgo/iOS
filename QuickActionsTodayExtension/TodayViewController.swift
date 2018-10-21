//
//  TodayViewController.swift
//  QuickActionsTodayExtension
//
//  Created by duckduckgo on 07/09/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import UIKit
import Core
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {

    @IBAction func onSearchTapped(_ sender: Any) {
        let url = URL(string: AppDeepLinks.newSearch)!
        extensionContext?.open(url, completionHandler: nil)
    }

    @IBAction func onBookmarksTapped(_ sender: Any) {
        let url = URL(string: AppDeepLinks.bookmarks)!
        extensionContext?.open(url, completionHandler: nil)
    }
    
    @IBAction func onFireTapped(_ sender: Any) {
        let url = URL(string: AppDeepLinks.fire)!
        extensionContext?.open(url, completionHandler: nil)
    }
  
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        completionHandler(NCUpdateResult.newData)
    }
    
}
