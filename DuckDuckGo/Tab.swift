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

    var omniBar: OmniBar { get }
    
    var link: Link { get }
    
    var name: String? { get }
    
    var url: URL? { get }
    
    var canGoBack: Bool { get }
    
    var canGoForward: Bool { get }
        
    func load(query: String)
    
    func load(url: URL)
    
    func refreshOmniText()
    
    func goBack()
    
    func goForward()

    func clear()
}

extension Tab {
    
    var link: Link {
        return Link(title: name ?? "", url: url ?? URL(string: "-")!)
    }
    
    func load(query: String) {
        guard let url = AppUrls.url(forQuery: query) else {
            return
        }
        load(url: url)
    }
}
