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

        func components(withVariantManger variantManger: VariantManager = DefaultVariantManager()) -> [Component] {
            let builder = Builder()

            let includePrivacySection = true // variantManger.isSupported(feature: .privacyOnHomeScreen)
            
            switch self {
            case .simple:
                builder.add(.privacyProtection, enabled: includePrivacySection)
                builder.add(.navigationBarSearch)
                builder.add(.logo(withOffset: includePrivacySection))

            case .simpleAndFavorites:
                builder.add(.privacyProtection, enabled: includePrivacySection)
                builder.add(.navigationBarSearch)
                builder.add(.favorites(withHeader: includePrivacySection))
                builder.add(.padding(withOffset: includePrivacySection))

            case .centerSearch:
                builder.add(.centeredSearch(fixed: true))
                builder.add(.privacyProtection, enabled: includePrivacySection)
                builder.add(.empty)

            case .centerSearchAndFavorites:
                builder.add(.centeredSearch(fixed: false))
                builder.add(.privacyProtection, enabled: includePrivacySection)
                builder.add(.favorites(withHeader: includePrivacySection))
                builder.add(.padding(withOffset: includePrivacySection))

            }

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
    
    func components(withVariantManger variantManger: VariantManager = DefaultVariantManager()) -> [Component] {
        return settings.homePageConfig.components(withVariantManger: variantManger)
    }
    
    init(settings: AppSettings = AppUserDefaults()) {
        self.settings = settings
    }
    
}
