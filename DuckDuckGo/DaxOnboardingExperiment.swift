//
//  DaxOnboardingExperiment.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 11/05/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import Foundation
import Core

class DaxOnboarding {
    
    func isActive() -> Bool {
        return DefaultVariantManager().isSupported(feature: .daxOnboarding)
    }
    
}
