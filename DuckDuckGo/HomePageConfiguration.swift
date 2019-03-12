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

        var components: [Component] {
            switch self {
            case .simple:
                return [ .navigationBarSearch ]
                
            case .centerSearch:
                return [ .fixedCenteredSearch ]
                
            case .centerSearchAndFavorites:
                return [ .centeredSearch, .favorites ]
            }
            
        }
        
        case simple
        case centerSearch
        case centerSearchAndFavorites
        
    }
    
    enum Component {
        case navigationBarSearch
        case centeredSearch
        case fixedCenteredSearch
        case favorites
    }
    
    let settings: AppSettings
    
    var components: [Component] {
        return settings.homePage.components
    }
    
    init(settings: AppSettings = AppUserDefaults()) {
        self.settings = settings
    }
    
}
