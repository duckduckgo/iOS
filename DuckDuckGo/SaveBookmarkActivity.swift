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
    
    private var isFavorite: Bool
    
    init(isFavorite: Bool = false) {
        self.isFavorite = isFavorite
        super.init()
    }

    override var activityTitle: String? {
        return isFavorite ? UserText.actionSaveBookmark : UserText.actionSaveFavorite
    }

    override var activityType: UIActivity.ActivityType? {
        return isFavorite ? .saveFavoriteInDuckDuckGo : .saveBookmarkInDuckDuckGo
    }

    override var activityImage: UIImage {
        return (isFavorite ? UIImage(named: "sharesheet-bookmark") : UIImage(named: "sharesheet-favorite")) ?? #imageLiteral(resourceName: "LogoShare")
    }

    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return activityItems.contains(where: { $0 is Link })
    }

    override func prepare(withActivityItems activityItems: [Any]) {
        bookmark = activityItems.first(where: { $0 is Link }) as? Link
    }

    override var activityViewController: UIViewController? {
        guard let bookmark = bookmark else {
            activityDidFinish(false)
            return nil
        }

        if isFavorite {
            bookmarksManager.save(favorite: bookmark)
            // TODO notification to say bookmark saved
        } else {
            bookmarksManager.save(bookmark: bookmark)
            // TODO notification to say bookmark saved
        }
        activityDidFinish(true)
        return nil
    }

    private func onCancel() {
        activityDidFinish(true)
    }
}

extension UIActivity.ActivityType {
    public static let saveBookmarkInDuckDuckGo = UIActivity.ActivityType("com.duckduckgo.save.bookmark")
    public static let saveFavoriteInDuckDuckGo = UIActivity.ActivityType("com.duckduckgo.save.favorite")
}
