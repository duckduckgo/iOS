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
    
    var components: [Component] {
        guard let currentVariant = variantManager.currentVariant,
                currentVariant.features.contains(.homeScreen) else {
            return [ .navigationBarSearch ]
        }
        
        return [
            .centeredSearch,
            .favorites
        ]
    }
    
    init(variantManager: VariantManager = DefaultVariantManager()) {
        self.variantManager = variantManager
    }
 
    static func installNewUserFavorites(statisticsStore: StatisticsStore = StatisticsUserDefaults(),
                                        bookmarksManager: BookmarksManager = BookmarksManager(),
                                        variantManager: VariantManager = DefaultVariantManager()) {
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
        
        guard let currentVariant = variantManager.currentVariant else {
            Logger.log(text: "no current variant, not installing new user favorites")
            return
        }

        if currentVariant.features.contains(FeatureName.singleFavorite) {
            bookmarksManager.save(favorite: Link(title: "Twitter", url: URL(string: "https://twitter.com")!))
        }
        
        if currentVariant.features.contains(FeatureName.additionalFavorites) {
            bookmarksManager.save(favorite: Link(title: "Spread Privacy", url: URL(string: "https://spreadprivacy.com")!))
            bookmarksManager.save(favorite: Link(title: "Quora", url:
                URL(string: "https://www.quora.com/Why-should-I-use-DuckDuckGo-instead-of-Google/answer/Gabriel-Weinberg")!))

            for i in 0 ..< 20 {
                bookmarksManager.save(favorite: Link(title: "Domain \(i)", url: URL(string: "https://domain\(i).com")!))
            }
            
        }

    }
    
    static func configureOmniBar(_ omniBar: OmniBar, variantManager: VariantManager = DefaultVariantManager()) {
        guard let currentVariant = variantManager.currentVariant else {
            Logger.log(text: "no current variant, not configuring omnibar")
            return
        }
        
        guard currentVariant.features.contains(.homeScreen) else {
            Logger.log(text: "no home screen in variant, not configuring omnibar")
            return
        }

        omniBar.useCancellableState()
    }
    
}
