//
//  OmniBarDelegate.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 17/02/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

protocol OmniBarDelegate: class {
    
    func onOmniQuerySubmitted(_ query: String)
    
    func onLeftButtonPressed()
    
    func onRightButtonPressed()
}
