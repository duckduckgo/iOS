//
//  ContentBlockerConfigurationStore.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 17/05/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

public protocol ContentBlockerConfigurationStore {
    
    var blockAdvertisers: Bool { get set }
    var blockAnalytics: Bool { get set }
    var blockSocial: Bool { get set }
    
}
