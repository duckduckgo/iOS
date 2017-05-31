//
//  SearchFilterStore.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 29/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

public protocol SearchFilterStore {
    
    var safeSearchEnabled: Bool { get set }
    var regionFilter: String? { get set }
    var dateFilter: String? { get set }

}
