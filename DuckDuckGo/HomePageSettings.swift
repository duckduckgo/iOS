//
//  HomePageSettings.swift
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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

enum HomePageLayout: Int {

    case navigationBar
    case centered

}

protocol HomePageSettings {
    
    var layout: HomePageLayout { get set }
 
    var favorites: Bool { get set }

    func migrate(from appSettigs: inout AppSettings)
    
}

class DefaultHomePageSettings: HomePageSettings {

    @UserDefaultsWrapper(key: .layout, defaultValue: HomePageLayout.navigationBar.rawValue)
    var layoutRaw: Int
    
    var layout: HomePageLayout {
        get {
            return HomePageLayout(rawValue: layoutRaw) ?? .navigationBar
        }
        
        set {
            layoutRaw = newValue.rawValue
        }
    }

    @UserDefaultsWrapper(key: .favorites, defaultValue: true)
    var favorites: Bool

    func migrate(from appSettings: inout AppSettings) {
        guard let homePage = appSettings.homePage else { return }

        switch homePage {
        case .centerSearch:
            self.layout = .centered
            self.favorites = false

        case .centerSearchAndFavorites:
            self.layout = .centered
            self.favorites = true

        case .simple:
            self.layout = .navigationBar
            self.favorites = false
        }

        appSettings.homePage = nil
    }

}
