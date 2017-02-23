//
//  TabViewControllerDelegate.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 17/02/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Core

protocol TabViewControllerDelegate: class {
    
    var tabDetails: [Link] { get }
    
    func createTab()
    
    func select(tabAt index: Int)
    
    func remove(tabAt index: Int)
    
    func clearAllTabs()
}
