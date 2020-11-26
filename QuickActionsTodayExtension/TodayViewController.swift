//
//  TodayViewController.swift
//  QuickActionsTodayExtension
//
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    private let lightThemeTintColor = UIColor.black
    private let darkThemeTintColor = UIColor.white
    
    @IBOutlet var loupeIcon: UIImageView!
    @IBOutlet var searchLabel: UILabel!
    @IBOutlet var bookmarksButton: UIButton!
    @IBOutlet var clearDataButton: UIButton!
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateColors()
    }
    
    private func updateColors() {
        loupeIcon.tintColor = lightThemeTintColor
        searchLabel.textColor = lightThemeTintColor
        bookmarksButton.setTitleColor(lightThemeTintColor, for: .normal)
        clearDataButton.setTitleColor(lightThemeTintColor, for: .normal)
        
        if #available(iOSApplicationExtension 13.0, *) {
            if traitCollection.userInterfaceStyle == .light {
                updateImageColor(color: lightThemeTintColor, for: bookmarksButton)
                updateImageColor(color: lightThemeTintColor, for: clearDataButton)
            } else {
                loupeIcon.tintColor = darkThemeTintColor
                searchLabel.textColor = darkThemeTintColor
                bookmarksButton.setTitleColor(darkThemeTintColor, for: .normal)
                clearDataButton.setTitleColor(darkThemeTintColor, for: .normal)
                
                updateImageColor(color: darkThemeTintColor, for: bookmarksButton)
                updateImageColor(color: darkThemeTintColor, for: clearDataButton)
            }
        }
    }
    
    @available(iOSApplicationExtension 13.0, *)
    private func updateImageColor(color: UIColor, for button: UIButton) {
        let updatedImage = button.currentImage?.withTintColor(color)
        button.setImage(updatedImage, for: .normal)
        button.setImage(updatedImage, for: .selected)
    }

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
