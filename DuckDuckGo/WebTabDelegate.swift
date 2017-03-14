//
//  WebTabDelegate.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 02/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import WebKit

protocol WebTabDelegate: class {
    
    func webTab(_ webTab: WebTabViewController, didRequestNewTabForUrl url: URL)
    
    func webTabLoadingStateDidChange(webTab: WebTabViewController)
}
