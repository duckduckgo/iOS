//
//  TabSwitcherDelegate.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 17/02/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Core

protocol TabSwitcherDelegate: class {
    
    var tabDetails: [Link] { get }
    
    func tabSwitcherDidRequestNewTab(tabSwitcher: TabSwitcherViewController)
    
    func tabSwitcher(_ tabSwitcher: TabSwitcherViewController, didSelectTabAt index: Int)
    
    func tabSwitcher(_ tabSwitcher: TabSwitcherViewController, didRemoveTabAt index: Int)
    
    func tabSwitcherDidRequestClearAll(tabSwitcher: TabSwitcherViewController)
}
