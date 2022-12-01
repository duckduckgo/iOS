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
import Bookmarks
import WidgetKit

extension TabViewController {
    func saveAsBookmark(favorite: Bool, viewModel: MenuBookmarksInteracting) {
        guard let link = link, !isError else {
            assertionFailure()
            return
        }

        if favorite && nil == viewModel.favorite(for: link.url) {
            viewModel.createOrToggleFavorite(title: link.displayTitle, url: link.url)
            WidgetCenter.shared.reloadAllTimelines()
            
            DispatchQueue.main.async {
                ActionMessageView.present(message: UserText.webSaveFavoriteDone)
            }
        } else if nil == viewModel.bookmark(for: link.url) {
            viewModel.createBookmark(title: link.displayTitle, url: link.url)
            DispatchQueue.main.async {
                ActionMessageView.present(message: UserText.webSaveBookmarkDone)
            }
        } else {
            DispatchQueue.main.async {
                ActionMessageView.present(message: UserText.webBookmarkAlreadySaved)
            }
        }
    }
}
