//
//  HomeTabDelegate.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 01/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

protocol HomeTabDelegate: class {

    func activateOmniBar()
    
    func deactivateOmniBar()
    
    func loadNewWebUrl(url: URL)

    func loadNewWebQuery(query: String)
    
    func launchTabsSwitcher()
}
