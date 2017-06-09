//
//  HomeControllerDelegate.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 01/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

protocol HomeControllerDelegate: class {
    
    func homeControllerDidActivateOmniBar(homeController: HomeViewController)
    
    func homeControllerDidDeactivateOmniBar(homeController: HomeViewController)

    func homeController(_ homeController: HomeViewController, didRequestUrl url: URL)

    func homeController(_ homeController: HomeViewController, didRequestQuery query: String)
}
