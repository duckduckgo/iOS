//
//  Tab.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 01/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation
import Core

protocol Tab: class {
    
    var link: Link? { get }
    
    var canGoBack: Bool { get }
    
    var canGoForward: Bool { get }
    
    var contentBlockerMonitor: ContentBlockerMonitor { get }
    
    func omniBarWasDismissed()
    
    func launchBrowsingMenu()
    
    func launchContentBlockerPopover()
    
    func load(url: URL)
    
    func goBack()
    
    func goForward()
    
    func reload()
    
    func dismiss()
    
    func destroy()
}
