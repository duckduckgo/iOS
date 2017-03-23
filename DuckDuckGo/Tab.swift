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

    var link: Link { get }
    
    var name: String? { get }
    
    var url: URL? { get }
    
    var favicon: URL? { get }
    
    var omniBarStyle: OmniBar.Style { get }
    
    var showsUrlInOmniBar: Bool { get }

    var canGoBack: Bool { get }
    
    var canGoForward: Bool { get }
        
    func omniBarWasDismissed()
    
    func load(url: URL)
    
    func goBack()
    
    func goForward()

    func reload()
    
    func dismiss()
    
    func destroy()
}

extension Tab {
    var link: Link {
        return Link(title: name ?? "", url: url ?? URL(string: "-")!, favicon: favicon)
    }
}
