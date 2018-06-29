//
//  BookmarkUserDefaults.swift
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


import Foundation

public class BookmarkUserDefaults: BookmarkStore {

    public struct Constants {
        public static let groupName = "group.com.duckduckgo.bookmarks"
    }
    
    private struct Keys {
        static let bookmarkKey = "com.duckduckgo.bookmarks.bookmarkKey"
    }

    private let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults = UserDefaults(suiteName: Constants.groupName)!) {
        self.userDefaults = userDefaults
    }
    
    public var bookmarks: [Link]? {
        get {
            if let data = userDefaults.data(forKey: Keys.bookmarkKey) {
                return NSKeyedUnarchiver.unarchiveObject(with: data) as? [Link]
            }
            return nil
        }
        set(newBookmarks) {
            if let newBookmarks = newBookmarks {
                let data = NSKeyedArchiver.archivedData(withRootObject: newBookmarks)
                userDefaults.set(data, forKey: Keys.bookmarkKey)
            }
        }
    }
    
    public func addBookmark(_ bookmark: Link) {
        var newBookmarks = bookmarks ?? [Link]()
        newBookmarks.append(bookmark)
        bookmarks = newBookmarks
    }
    
}
