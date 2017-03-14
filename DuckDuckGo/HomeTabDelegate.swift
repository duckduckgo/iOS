//
//  HomeTabDelegate.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 01/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

protocol HomeTabDelegate: class {

    func homeTabDidActivateOmniBar(homeTab: HomeTabViewController)
    
    func homeTabDidDeactivateOmniBar(homeTab: HomeTabViewController)

    func homeTabDidRequestTabsSwitcher(homeTab: HomeTabViewController)

    func homeTab(_ homeTab: HomeTabViewController, didRequestUrl url: URL)

    func homeTab(_ homeTab: HomeTabViewController, didRequestQuery query: String)
}
