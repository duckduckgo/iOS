//
//  HomeTabDelegate.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 01/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

protocol HomeTabDelegate: class {
    
    func loadNewWebQuery(query: String)
    
    func loadNewWebUrl(url: URL)
    
    func launchTabsSwitcher()
}
