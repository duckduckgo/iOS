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
    
    private lazy var bookmarksManager = BookmarksManager()
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
    
    override var activityViewController: UIViewController? {
        guard let bookmark = bookmark else {
            activityDidFinish(false)
            return nil
        }
        
        let title = UserText.alertSaveBookmark
        let alert = EditBookmarkAlert.buildAlert (
            title: title,
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
