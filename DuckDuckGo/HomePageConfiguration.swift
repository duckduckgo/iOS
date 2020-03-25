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
    
    enum ConfigName: Int {

        case simple
        case centerSearch
        case centerSearchAndFavorites

    }
    
    enum Component: Equatable {
        case navigationBarSearch(fixed: Bool)
        case centeredSearch(fixed: Bool)
        case extraContent
        case favorites
        case padding
    }
    
    let settings: HomePageSettings
    
    func components(bookmarksManager: BookmarksManager = BookmarksManager()) -> [Component] {
        let fixed = !settings.favorites || bookmarksManager.favoritesCount == 0

        var components = [Component]()
        switch settings.layout {
        case .navigationBar:
            if fixed {
                components.append(.extraContent)
                components.append(.navigationBarSearch(fixed: fixed))
            } else {
                components.append(.navigationBarSearch(fixed: fixed))
                components.append(.extraContent)
            }

        case .centered:
            components.append(.centeredSearch(fixed: fixed))
            components.append(.extraContent)
        }

        if settings.favorites {
            components.append(.favorites)
            if settings.layout == .centered {
                components.append(.padding)
            }
        }

        return components
    }
    
    init(settings: HomePageSettings = DefaultHomePageSettings()) {
        self.settings = settings
    }
    
}
