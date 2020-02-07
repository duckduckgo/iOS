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

extension TabViewController {
    func promptSaveBookmarkAction() {
        
        if let link = link, !isError {
            let bookmarksManager = BookmarksManager()
            guard !bookmarksManager.contains(url: link.url) else {
                view.showBottomToast(UserText.webBookmarkAlreadySaved)
                return
            }
            
            let saveCompletion: (Link) -> Void = { [weak self] updatedBookmark in
                bookmarksManager.save(bookmark: updatedBookmark)
                self?.view.showBottomToast(UserText.webSaveBookmarkDone)
            }
            let alert = EditBookmarkAlert.buildAlert (
                title: UserText.alertSaveBookmark,
                bookmark: link,
                saveCompletion: saveCompletion)
            present(alert, animated: true, completion: nil)
        } else {
            os_log("Invalid bookmark link found on bookmark long press", log: generalLog, type: .debug)
        }
    }
}
