//
//  HomeScreenSettings.swift
//  DuckDuckGo
//
//  Created by Christopher Brind on 19/02/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import Core

struct HomePageSettings {

    enum Layout: Int, Codable {

        case navigationBar
        case centered

    }

    @UserDefaultsWrapper(key: .layout, defaultValue: .navigationBar)
    var layout: Layout

    @UserDefaultsWrapper(key: .favorites, defaultValue: true)
    var favorites: Bool

    // XXX test
    mutating func migrate() {
        let appSettings = AppUserDefaults()
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
