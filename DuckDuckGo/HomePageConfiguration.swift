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

    class Builder {

        var components = [Component]()

        func add(_ component: Component) {
            components.append(component)
        }

        func add(_ component: Component, enabled: Bool) {
            if enabled {
                components.append(component)
            }
        }

    }

    enum ConfigName: Int {

        func components() -> [Component] {
            let builder = Builder()

            let appSettings = AppUserDefaults()
            let includePrivacySection = appSettings.homePageFeaturePrivacyStats
            let includeFavorites = appSettings.homePageFeatureFavorites
            
            switch self {
            case .simple, .simpleAndFavorites:
                builder.add(.privacyProtection, enabled: includePrivacySection)
                builder.add(.navigationBarSearch)
                builder.add(.logo(withOffset: includePrivacySection), enabled: !includeFavorites)

            case .centerSearch, .centerSearchAndFavorites:
                builder.add(.centeredSearch(fixed: !includeFavorites))
                builder.add(.privacyProtection, enabled: includePrivacySection)
            }

            builder.add(.favorites(withHeader: includePrivacySection), enabled: includeFavorites)
            builder.add(.padding(withOffset: includePrivacySection), enabled: includeFavorites)

            return builder.components
        }
        
        case simple
        case simpleAndFavorites
        case centerSearch
        case centerSearchAndFavorites
        
    }
    
    enum Component: Equatable {
        case privacyProtection
        case logo(withOffset: Bool)
        case navigationBarSearch
        case centeredSearch(fixed: Bool)
        case favorites(withHeader: Bool)
        case padding(withOffset: Bool)
        case empty
    }
    
    let settings: AppSettings
    
    func components() -> [Component] {
        return settings.homePageConfig.components()
    }
    
    init(settings: AppSettings = AppUserDefaults()) {
        self.settings = settings
    }
    
}
