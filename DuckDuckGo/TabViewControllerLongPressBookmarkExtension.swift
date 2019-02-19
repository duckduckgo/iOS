//
//  TabViewControllerLongPressBookmarkExtension.swift
//  DuckDuckGo
//
//  Created by BG on 2/15/19.
//  Copyright © 2019 DuckDuckGo. All rights reserved.
//

import Foundation
import Core

extension TabViewController {
    func promptSaveBookmarkAction() {
        
        if let link = link, !isError {
            let bookmarksManager = BookmarksManager()
            guard !bookmarksManager.contains(url: link.url) else {
                Logger.log(text: "promptSave already bookmarked")
                self.view.showBottomToast(UserText.webBookmarkAlreadySaved)
                return
            }
            
            Pixel.fire(pixel: .longPressTabBarBookmark)
            let saveCompletion: (Link) -> Void = { [weak self] updatedBookmark in
                bookmarksManager.save(bookmark: updatedBookmark)
                self?.view.showBottomToast(UserText.webSaveBookmarkDone)
            }
            let alert = EditBookmarkAlert.buildAlert (
                title: UserText.alertSaveBookmark,
                bookmark: link,
                saveCompletion: saveCompletion)
            self.present(alert, animated: true, completion: nil)
        } else {
            Logger.log(text: "Invalid bookmark link found on bookmark long press")
        }
    }
}
