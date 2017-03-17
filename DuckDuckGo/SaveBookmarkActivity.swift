//
//  SaveBookmarksActivity.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 16/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import Core

class SaveBookmarkActivity: UIActivity {
    
    private lazy var groupData = GroupData()
    
    private var bookmark: Link?
    
    override var activityTitle: String? {
        return UserText.actionSaveBookmark
    }
    
    override var activityType: UIActivityType? {
        return .saveBookmarkInDuckDuckGo
    }
    
    override var activityImage: UIImage {
        return #imageLiteral(resourceName: "Bookmarks")
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        for item in activityItems {
            if item is URL {
                return true
            }
        }
        return false
    }
    
    override func prepare(withActivityItems activityItems: [Any]) {
        var url: URL?
        var title: String?
        for item in activityItems {
            if let item = item as? URL {
                url = item
            }
            if let item = item as? String {
                title = item
            }
        }
        if let title = title, let url = url {
            bookmark = Link(title: title, url: url)
        }
    }
    
    override func perform() {
        if let bookmark = bookmark {
            groupData.addQuickLink(link: bookmark)
            activityDidFinish(true)
        } else {
            activityDidFinish(false)
        }
    }
}

extension UIActivityType {
    public static let saveBookmarkInDuckDuckGo = UIActivityType("com.duckduckgo.save.bookmark")
}
