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
        // swiftlint:disable line_length
        static let visitSiteDialog = HomeScreenSpec(height: 235, message: "Next, try visiting one of your favorite sites!\n\nI’ll block trackers so they can’t spy on you. I’ll also upgrade the security of your connection if possible. 🔒")
        
        static let youveGotThisDialog = HomeScreenSpec(height: 210, message: "You’ve got this!\n\nRemember: every time you browse with me a creepy ad loses its wings. 👍")
        // swiftlint:enable line_length

        let height: CGFloat
        let message: String
        
    }
    
    struct BrowsingSpec {

        // swiftlint:disable line_length
        static let firstTimeSerp = BrowsingSpec(height: 250, message: "Your DuckDuckGo searches are anonymous and I never store your search history.  Ever. 🙌", cta: "Phew!")
        static let firstTimeWithTrackers = BrowsingSpec(height: 340, message: "*Google, Amazon* and *3 others* were trying to track you here.\n\nI blocked them!\n\n☝️ You can check the URL bar to see who is trying to track you when you visit a new site.", cta: "High Five!")
        // swiftlint:enable line_length

        let height: CGFloat
        let message: String
        let cta: String
        
    }
    
    let variantManager: VariantManager
    
    var isActive: Bool {
        return variantManager.isSupported(feature: .daxOnboarding)
    }

    var isDismissed = false

    init(variantManager: VariantManager = DefaultVariantManager()) {
        self.variantManager = variantManager
    }
    
    func nextBrowsingMessage() -> BrowsingSpec? {
        return .firstTimeWithTrackers
    }
    
    /// Get the next home screen message.
    ///
    /// Returns a tuple containing the height of the dialog and the message or nil if there's nothing left to show or the flow has been disabled
    func nextHomeScreenMessage() -> HomeScreenSpec? {
//        let specs: [HomeScreenSpec?] = [
//            nil, .visitSiteDialog, .youveGotThisDialog
//        ]
//        return specs.shuffled().first!
        return .visitSiteDialog
    }
    
}
