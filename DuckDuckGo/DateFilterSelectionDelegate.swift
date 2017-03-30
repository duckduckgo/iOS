//
//  DateFilterSelectionDelegate.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 29/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation
import Core

protocol DateFilterSelectionDelegate: class {
    
    func currentDateFilterSelection() -> DateFilter
    
    func onDateFilterSelected(dateFilter: DateFilter)
    
}
