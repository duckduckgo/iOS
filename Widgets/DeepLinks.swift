//
//  DeepLinks.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 02/09/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import Core

struct DeepLinks {

    static let newSearch = URL(string: AppDeepLinks.newSearch + "?w=1")!

    static func createFavoriteLauncher(forUrl url: URL) -> URL {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.scheme = String(AppDeepLinks.launchFavorite.dropLast(3))
        return components?.url ?? url
    }

}
