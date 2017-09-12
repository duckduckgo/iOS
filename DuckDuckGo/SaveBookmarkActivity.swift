//
//  SaveBookmarksActivity.swift
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

class SaveBookmarkActivity: UIActivity {
    
    private lazy var bookmarksManager: BookmarksManager = BookmarksManager()
    private var bookmark: Link?
    
    override var activityTitle: String? {
        return UserText.actionSaveBookmark
    }
    
    override var activityType: UIActivityType? {
        return .saveBookmarkInDuckDuckGo
    }
    
    override var activityImage: UIImage {
        return #imageLiteral(resourceName: "LogoShare")
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        for item in activityItems {
            if item is Link {
                return true
            }
        }
        return false
    }
    
    override func prepare(withActivityItems activityItems: [Any]) {
        for item in activityItems {
            if let link = item as? Link {
                bookmark = link
                return
            }
        }
    }
    
    override var activityViewController: UIViewController? {
        guard let bookmark = bookmark else {
            activityDidFinish(false)
            return nil
        }
        
        let alert = EditBookmarkAlert.buildAlert (
            title: UserText.alertSaveBookmark,
            bookmark: bookmark,
            saveCompletion: { [weak self] (updatedBookmark) in self?.onDone(updatedBookmark: updatedBookmark) },
            cancelCompletion: { [weak self] in self?.onCancel() }
        )
        return alert
    }
    
    private func onDone(updatedBookmark: Link) {
        bookmarksManager.save(bookmark: updatedBookmark)
        activityDidFinish(true)
    }
    
    private func onCancel() {
        activityDidFinish(true)
    }
}

extension UIActivityType {
    public static let saveBookmarkInDuckDuckGo = UIActivityType("com.duckduckgo.save.bookmark")
}
