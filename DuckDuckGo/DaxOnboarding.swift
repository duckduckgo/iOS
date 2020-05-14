//
//  DaxOnboarding.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 11/05/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import Foundation
import Core

class DaxOnboarding {
    
    struct HomeScreenSpec {
        
        static let visitSiteDialog = HomeScreenSpec(height: 305, message: "Next, try visiting one of your favorite sites!\n\nI’ll block trackers so they can’t spy on you. I’ll also upgrade the security of your connection if possible. 🔒")
        
        static let youveGotThisDialog = HomeScreenSpec(height: 280, message: "You’ve got this!\n\nRemember: every time you browse with me a creepy ad loses its wings. 👍")
        
        let height: CGFloat
        let message: String
        
    }
    
    let variantManager: VariantManager
    
    var isActive: Bool {
        return variantManager.isSupported(feature: .daxOnboarding)
    }

    init(variantManager: VariantManager = DefaultVariantManager()) {
        self.variantManager = variantManager
    }
    
    /// Get the next home screen message.
    ///
    /// Returns a tuple containing the height of the dialog and the message or nil if there's nothing left to show or the flow has been disabled
    func nextHomeScreenMessage() -> HomeScreenSpec? {
        let specs: [HomeScreenSpec?] = [
            nil, .visitSiteDialog, .youveGotThisDialog
        ]
        return specs.shuffled().first!
    }
    
}
