//
//  WebLoadingDelegate.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 02/02/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

public protocol WebLoadingDelegate: class {
    
    func webpageDidStartLoading()
    
    func webpageDidFinishLoading()
}
