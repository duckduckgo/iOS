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

    private lazy var bookmarksManager: BookmarksManager = BookmarksManager()
    private var bookmark: Link?
    
    private weak var controller: UIViewController?
    private var isFavorite: Bool
    
    private var activityViewControllerAccessed = false

    init(controller: UIViewController, isFavorite: Bool = false) {
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
        return activityItems.contains(where: { $0 is Link })
    }

    override func prepare(withActivityItems activityItems: [Any]) {
        bookmark = activityItems.first(where: { $0 is Link }) as? Link
    }

    override var activityViewController: UIViewController? {
        guard !activityViewControllerAccessed else { return nil }
        activityViewControllerAccessed = true

        guard let bookmark = bookmark else {
            activityDidFinish(true)
            return nil
        }

        bookmarksManager.contains(url: bookmark.url) { contains in
            if contains {
                DispatchQueue.main.async {
                    ActionMessageView.present(message: UserText.webBookmarkAlreadySaved)
                    self.activityDidFinish(true)
                }
            } else {
                if self.isFavorite {
                    self.bookmarksManager.saveNewFavorite(withTitle: bookmark.title ?? "", url: bookmark.url)
                    DispatchQueue.main.async {
                        ActionMessageView.present(message: UserText.webSaveFavoriteDone)
                        self.activityDidFinish(true)
                    }
                } else {
                    self.bookmarksManager.saveNewBookmark(withTitle: bookmark.title ?? "", url: bookmark.url, parentID: nil)
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
