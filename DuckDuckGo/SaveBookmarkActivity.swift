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
        return #imageLiteral(resourceName: "LogoShare")
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        for item in activityItems {
            if item is URL {
                return true
            }
        }
        return false
    }
    
    override func prepare(withActivityItems items: [Any]) {
        var favicon: URL? = nil
        guard items.count >= 2, let title = items[0] as? String, let url = items[1] as? URL else { return }
        if items.count == 3, let icon = items[2] as? URL {
            favicon = icon
        }
        bookmark = Link(title: title, url: url, favicon: favicon)
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
