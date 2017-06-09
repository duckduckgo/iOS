//
//  OmniBarDelegate.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 17/02/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

protocol OmniBarDelegate: class {
    
    func onOmniQueryUpdated(_ query: String)

    func onOmniQuerySubmitted(_ query: String)
            
    func onDismissButtonPressed()
    
    func onMenuPressed()
}
