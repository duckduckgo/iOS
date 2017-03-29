//
//  RegionSelectionDelegate.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 29/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation
import Core

protocol RegionSelectionDelegate: class {
    
    func currentRegionSelection() -> RegionFilter

    func onRegionSelected(region: RegionFilter)
}
