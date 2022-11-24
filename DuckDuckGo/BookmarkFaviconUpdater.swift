//
//  BookmarkFaviconUpdater.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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

import Core
import Persistence
import Bookmarks
import CoreData

protocol TabNotifying {
    func didUpdateFavicon()
}

extension Tab: TabNotifying {}

protocol FaviconProviding {

    func loadFavicon(forDomain domain: String, fromURL url: URL?, intoCache cacheType: Favicons.CacheType, completion: ((UIImage?) -> Void)?)
    func replaceBookmarksFavicon(forDomain domain: String?, withImage: UIImage)

}

extension Favicons: FaviconProviding {

    func loadFavicon(forDomain domain: String, fromURL url: URL?, intoCache cacheType: CacheType, completion: ((UIImage?) -> Void)?) {
        self.loadFavicon(forDomain: domain, fromURL: url, intoCache: cacheType, fromCache: nil, completion: completion)
    }

}

class BookmarkFaviconUpdater: NSObject, FaviconUserScriptDelegate {

    let context: NSManagedObjectContext
    let tab: TabNotifying
    let favicons: FaviconProviding

    init(bookmarksDatabase: CoreDataDatabase, tab: TabNotifying, favicons: FaviconProviding) {
        self.context = bookmarksDatabase.makeContext(concurrencyType: .mainQueueConcurrencyType)
        self.tab = tab
        self.favicons = favicons
    }

    func faviconUserScript(_ script: FaviconUserScript, didRequestUpdateFaviconForHost host: String, withUrl url: URL?) {
        assert(Thread.isMainThread)

        favicons.loadFavicon(forDomain: host, fromURL: url, intoCache: .tabs) { [weak self] image in
            guard let self = self else { return }
            self.tab.didUpdateFavicon()

            guard self.bookmarkExists(for: host),
                  let image = image else { return }

            self.favicons.replaceBookmarksFavicon(forDomain: host, withImage: image)
        }

    }

    private func bookmarkExists(for domain: String) -> Bool {
        let domainPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
            NSPredicate(format: "%K BEGINSWITH[c] %@", #keyPath(BookmarkEntity.url), "http://\(domain)"),
            NSPredicate(format: "%K BEGINSWITH[c] %@", #keyPath(BookmarkEntity.url), "https://\(domain)"),
            NSPredicate(format: "%K BEGINSWITH[c] %@", #keyPath(BookmarkEntity.url), "http://www.\(domain)"),
            NSPredicate(format: "%K BEGINSWITH[c] %@", #keyPath(BookmarkEntity.url), "https://www.\(domain)")
        ])

        let notFolderPredicate = NSPredicate(format: "%K = NO", #keyPath(BookmarkEntity.isFolder))

        let request = BookmarkEntity.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            notFolderPredicate,
            domainPredicate
        ])
        let result = (try? context.count(for: request)) ?? 0 > 0
        return result
    }

}
