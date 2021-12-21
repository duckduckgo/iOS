//
//  SaveBookmarkActivity.swift
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

    private let bookmarksManager: BookmarksManager
    private var bookmarkURL: URL?
    
    private weak var controller: TabViewController?
    private var isFavorite: Bool
    
    private var activityViewControllerAccessed = false

    init(controller: TabViewController, isFavorite: Bool = false, bookmarksManager: BookmarksManager = BookmarksManager()) {
        self.bookmarksManager = bookmarksManager
        self.controller = controller
        self.isFavorite = isFavorite
        super.init()
    }

    override var activityTitle: String? {
        return isFavorite ? UserText.actionSaveFavorite : UserText.actionSaveBookmark
    }

    override var activityType: UIActivity.ActivityType? {
        return isFavorite ? .saveFavoriteInDuckDuckGo : .saveBookmarkInDuckDuckGo
    }

    override var activityImage: UIImage {
        return (isFavorite ? UIImage(named: "sharesheet-favorite") : UIImage(named: "sharesheet-bookmark")) ?? #imageLiteral(resourceName: "LogoShare")
    }

    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return activityItems.contains(where: { $0 is URL })
    }

    override func prepare(withActivityItems activityItems: [Any]) {
        bookmarkURL = activityItems.first(where: { $0 is URL }) as? URL
    }

    override var activityViewController: UIViewController? {
        guard !activityViewControllerAccessed else { return nil }
        activityViewControllerAccessed = true

        guard let bookmarkURL = bookmarkURL else {
            activityDidFinish(true)
            return nil
        }

        bookmarksManager.contains(url: bookmarkURL) { contains in
            if contains {
                DispatchQueue.main.async {
                    ActionMessageView.present(message: UserText.webBookmarkAlreadySaved)
                    self.activityDidFinish(true)
                }
            } else {
                let linkForTitle: Link
                if let link = self.controller?.link, link.url == bookmarkURL {
                    linkForTitle = link
                } else {
                    linkForTitle = Link(title: nil, url: bookmarkURL)
                }
                let title = linkForTitle.displayTitle ?? bookmarkURL.absoluteString
                if self.isFavorite {
                    self.bookmarksManager.saveNewFavorite(withTitle: title, url: bookmarkURL)
                    DispatchQueue.main.async {
                        ActionMessageView.present(message: UserText.webSaveFavoriteDone)
                        self.activityDidFinish(true)
                    }
                } else {
                    self.bookmarksManager.saveNewBookmark(withTitle: title, url: bookmarkURL, parentID: nil)
                    DispatchQueue.main.async {
                        ActionMessageView.present(message: UserText.webSaveBookmarkDone)
                        self.activityDidFinish(true)
                    }
                }
            }
        }
        return nil
    }
}

extension UIActivity.ActivityType {
    public static let saveBookmarkInDuckDuckGo = UIActivity.ActivityType("com.duckduckgo.save.bookmark")
    public static let saveFavoriteInDuckDuckGo = UIActivity.ActivityType("com.duckduckgo.save.favorite")
}
