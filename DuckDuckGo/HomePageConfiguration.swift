//
//  HomePageConfiguration.swift
//  DuckDuckGo
//
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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

class HomePageConfiguration {
    
    enum Component {
        case navigationBarSearch
        case centeredSearch
        case favorites
    }
    
    let variantManager: VariantManager
    let statisticsStore: StatisticsStore
    let bookmarksManager: BookmarksManager
    
    var components: [Component] {
        return [
//            .navigationBarSearch
            .centeredSearch,
            .favorites
        ]
    }
    
    init(variantManager: VariantManager = DefaultVariantManager(),
         statisticsStore: StatisticsStore = StatisticsUserDefaults(),
         bookmarksManager: BookmarksManager = BookmarksManager()) {
        self.variantManager = variantManager
        self.statisticsStore = statisticsStore
        self.bookmarksManager = bookmarksManager
    }
 
    func installNewUserFavorites() {
        guard statisticsStore.atb == nil else {
            Logger.log(text: "atb detected, not installing new user favorites")
            return
        }
        
        guard bookmarksManager.favoritesCount == 0 else {
            Logger.log(text: "favorites detected, not installing new user favorites")
            return
        }

        guard bookmarksManager.bookmarksCount == 0 else {
            Logger.log(text: "bookmarks detected, not installing new user favorites")
            return
        }

        print("***", #function)
        
        bookmarksManager.save(favorite: Link(title: "Privacy Crash Course", url: URL(string: "https://duckduckgo.com/newsletter")!))
        bookmarksManager.save(favorite: Link(title: "Wikipedia", url: URL(string: "https://wikipedia.org")!))
        bookmarksManager.save(favorite: Link(title: "Apple", url: URL(string: "https://apple.com")!))

    }
    
}
