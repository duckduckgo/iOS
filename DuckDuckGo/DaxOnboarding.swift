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
    
    struct HomeScreenSpec: Equatable {
        // swiftlint:disable line_length
        static let initial = HomeScreenSpec(height: 235, message: "Next, try visiting one of your favorite sites!\n\nI’ll block trackers so they can’t spy on you. I’ll also upgrade the security of your connection if possible. 🔒")
        
        static let subsequent = HomeScreenSpec(height: 210, message: "You’ve got this!\n\nRemember: every time you browse with me a creepy ad loses its wings. 👍")
        // swiftlint:enable line_length

        let height: CGFloat
        let message: String
        
    }
    
    struct BrowsingSpec: Equatable {

        // swiftlint:disable line_length
        static let afterSearch = BrowsingSpec(height: 250, message: "Your DuckDuckGo searches are anonymous and I never store your search history.  Ever. 🙌", cta: "Phew!")
        
        static let withoutTrackers = BrowsingSpec(height: 340, message: "As you tap and scroll, I'll block pesky trackers.\nGo head - keep browsing!", cta: "Got It")
        
        static let siteIsMajorTracker = BrowsingSpec(height: 340, message: "Heads up! %0@ is a major tracking network.\nTheir trackers lurk on about %1d% of top sites 😱 but don't worry!<br>I'll block %0@ from seeing your activity on those sites.", cta: "Got It")
        
        static let siteOwnedByMajorTracker = BrowsingSpec(height: 340, message: "Heads up! %0@ is owned by %1@.<br>%1@'s trackers lurk on about %2d% of top websites 😱 but don't worry!<br>I'll block %1@ from seeing your activity on those sites.", cta: "Got It")
        
        static let withOneMajorTrackersAndMultipleOthers = BrowsingSpec(height: 340, message: "*%0@* and *%1d others* were trying to track you here.\n\nI blocked them!\n\n☝️ You can check the URL bar to see who is trying to track you when you visit a new site.", cta: "High Five!")
        
        static let withTwoMajorTrackersAndMultipleOthers = BrowsingSpec(height: 340, message: "*%0@, %1@* and *%2d others* were trying to track you here.\n\nI blocked them!\n\n☝️ You can check the URL bar to see who is trying to track you when you visit a new site.", cta: "High Five!")

        static let withOneMajorTracker = BrowsingSpec(height: 340, message: "*%0@* was trying to track you here.\n\nI blocked them!\n\n☝️ You can check the URL bar to see who is trying to track you when you visit a new site.", cta: "High Five!")

        static let withTwoMajorTrackers = BrowsingSpec(height: 340, message: "*%0@ and %1@* were trying to track you here.\n\nI blocked them!\n\n☝️ You can check the URL bar to see who is trying to track you when you visit a new site.", cta: "High Five!")

        // swiftlint:enable line_length

        let height: CGFloat
        let message: String
        let cta: String
        
        func format(args: CVarArg...) -> BrowsingSpec {
            return BrowsingSpec(height: height, message: String(format: message, arguments: args), cta: cta)
        }
        
    }
    
    private var appUrls = AppUrls()

    private var isDismissed = false
    
    private var homeScreenMessagesSeen = 0
    
    private var browsingAfterSearchShown = false
    private var browsingWithTrackersShown = false
    private var browsingWithoutTrackersShown = false
    private var browsingMajorTrackingSiteShown = false
    private var browsingOwnedByMajorTrackingSiteShown = false
    
    private var browsingMessageSeen: Bool {
        return browsingAfterSearchShown
            || browsingWithTrackersShown
            || browsingWithoutTrackersShown
            || browsingMajorTrackingSiteShown
            || browsingOwnedByMajorTrackingSiteShown
    }
    
    func dismiss() {
        self.isDismissed = true
    }
    
    func nextBrowsingMessage(siteRating: SiteRating) -> BrowsingSpec? {
        guard !isDismissed else { return nil }
                
        if appUrls.isDuckDuckGoSearch(url: siteRating.url) {
            if !browsingAfterSearchShown {
                browsingAfterSearchShown = true
                return BrowsingSpec.afterSearch
            }
            return nil
        }
        
        if let entity = TrackerDataManager.shared.findEntity(forHost: siteRating.domain ?? "") {
            
            
        }
        
        if siteRating.isMajorTrackerNetwork {
            if !browsingMajorTrackingSiteShown {
                browsingMajorTrackingSiteShown = true
                return BrowsingSpec.siteIsMajorTracker
            }
            return nil
        }
        
        if siteRating.trackersBlocked.isEmpty {
            if !browsingWithoutTrackersShown {
                browsingWithoutTrackersShown = true
                return BrowsingSpec.withoutTrackers
            }
            return nil
        }
        
        return nil
    }
    
    /// Get the next home screen message.
    ///
    /// Returns a tuple containing the height of the dialog and the message or nil if there's nothing left to show or the flow has been disabled
    func nextHomeScreenMessage() -> HomeScreenSpec? {
        guard !isDismissed else { return nil }
        guard homeScreenMessagesSeen < 2 else { return nil }
        
        if homeScreenMessagesSeen == 0 {
            homeScreenMessagesSeen += 1
            return .initial
        }
        
        if browsingMessageSeen {
            homeScreenMessagesSeen += 1
            return .subsequent
        }
        
        return nil
    }
    
}
