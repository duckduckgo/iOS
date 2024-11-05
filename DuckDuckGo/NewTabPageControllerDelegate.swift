//
//  NewTabPageControllerDelegate.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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

import Bookmarks
import Foundation

protocol NewTabPageControllerDelegate: AnyObject {
    func newTabPageDidOpenFavoriteURL(_ controller: NewTabPageViewController, url: URL)
    func newTabPageDidDeleteFavorite(_ controller: NewTabPageViewController, favorite: BookmarkEntity)
    func newTabPageDidEditFavorite(_ controller: NewTabPageViewController, favorite: BookmarkEntity)
    func newTabPageDidRequestFaviconsFetcherOnboarding(_ controller: NewTabPageViewController)
}

protocol NewTabPageControllerShortcutsDelegate: AnyObject {
    func newTabPageDidRequestDownloads(_ controller: NewTabPageViewController)
    func newTabPageDidRequestBookmarks(_ controller: NewTabPageViewController)
    func newTabPageDidRequestPasswords(_ controller: NewTabPageViewController)
    func newTabPageDidRequestAIChat(_ controller: NewTabPageViewController)
    func newTabPageDidRequestSettings(_ controller: NewTabPageViewController)
}
