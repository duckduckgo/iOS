//
//  TabViewControllerLongPressBookmarkExtension.swift
//  DuckDuckGo
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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

import Foundation
import Core
import os.log

#warning("still using bookmarks manager")
extension TabViewController {
    func saveAsBookmark(favorite: Bool) {
        
        guard let link = link, !isError else {
            os_log("Invalid bookmark link found on bookmark long press", log: generalLog, type: .debug)
            return
        }

        let bookmarksManager = BookmarksManager()
        bookmarksManager.contains(url: link.url) { contains in
            
            if contains {
                DispatchQueue.main.async {
                    ActionMessageView.present(message: UserText.webBookmarkAlreadySaved)
                }
            } else {
                if favorite {
                    bookmarksManager.saveNewFavorite(withTitle: link.title ?? "", url: link.url)
                    DispatchQueue.main.async {
                        ActionMessageView.present(message: UserText.webSaveFavoriteDone)
                    }
                } else {
                    bookmarksManager.saveNewBookmark(withTitle: link.title ?? "", url: link.url, parentID: nil)
                    DispatchQueue.main.async {
                        ActionMessageView.present(message: UserText.webSaveBookmarkDone)
                    }
                }
            }
            
        }
    }
}
