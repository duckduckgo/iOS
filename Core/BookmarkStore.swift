//
//  BookmarkStore.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 29/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

public protocol BookmarkStore {
    var bookmarks: [Link]? { get set }
    func addBookmark(_ bookmark: Link)
    func updateFavicon(_ favicon: URL, forBookmarksWithUrl: URL)
}
