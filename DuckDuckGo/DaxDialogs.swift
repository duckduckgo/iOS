//
//  DaxDialogs.swift
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import Core

class DaxDialogs {
    
    struct MajorTrackers {
        
        static let facebookDomain = "facebook.com"
        static let googleDomain = "google.com"
        
        static let domains = [ Self.facebookDomain, Self.googleDomain ]
        
    }
    
    struct HomeScreenSpec: Equatable {

        static let initial = HomeScreenSpec(height: 235, message: UserText.daxDialogHomeInitial)
        static let subsequent = HomeScreenSpec(height: 210, message: UserText.daxDialogHomeSubsequent)

        let height: CGFloat
        let message: String
        
    }
    
    struct BrowsingSpec: Equatable {

        static let afterSearch = BrowsingSpec(height: 250,
                                              message: UserText.daxDialogBrowsingAfterSearch,
                                              cta: UserText.daxDialogBrowsingAfterSearchCTA)
        
        static let withoutTrackers = BrowsingSpec(height: 340,
                                                  message: UserText.daxDialogBrowsingWithoutTrackers,
                                                  cta: UserText.daxDialogBrowsingWithoutTrackersCTA)
        
        static let siteIsMajorTracker = BrowsingSpec(height: 340,
                                                     message: UserText.daxDialogBrowsingSiteIsMajorTracker,
                                                     cta: UserText.daxDialogBrowsingSiteIsMajorTrackerCTA)
        
        static let siteOwnedByMajorTracker = BrowsingSpec(height: 340,
                                                          message: UserText.daxDialogBrowsingSiteOwnedByMajorTracker,
                                                          cta: UserText.daxDialogBrowsingSiteOwnedByMajorTrackerCTA)
        
        static let withOneMajorTracker = BrowsingSpec(height: 340,
                                                      message: UserText.daxDialogBrowsingOneMajorTracker,
                                                      cta: UserText.daxDialogBrowsingOneMajorTrackerCTA)

        static let withOneMajorTrackerAndOthers = BrowsingSpec(height: 340,
                                                               message: UserText.daxDialogBrowsingOneMajorTrackerWithOthers,
                                                               cta: UserText.daxDialogBrowsingOneMajorTrackerWithOthersCTA)
        
        static let withTwoMajorTrackers = BrowsingSpec(height: 340,
                                                       message: UserText.daxDialogBrowsingTwoMajorTrackers,
                                                       cta: UserText.daxDialogBrowsingTwoMajorTrackers)
        
        static let withTwoMajorTrackersAndOthers = BrowsingSpec(height: 340,
                                                               message: UserText.daxDialogBrowsingTwoMajorTrackersWithOthers,
                                                               cta: UserText.daxDialogBrowsingTwoMajorTrackersWithOthersCTA)

        let height: CGFloat
        let message: String
        let cta: String
        
        func format(args: CVarArg...) -> BrowsingSpec {
            return BrowsingSpec(height: height, message: String(format: message, arguments: args), cta: cta)
        }
        
    }
    
    private let appUrls = AppUrls()
    private var settings: DaxOnboardingSettings
    
    init(settings: DaxOnboardingSettings = DefaultDaxOnboardingSettings()) {
        self.settings = settings
    }
    
    private var browsingMessageSeen: Bool {
        return settings.browsingAfterSearchShown
            || settings.browsingWithTrackersShown
            || settings.browsingWithoutTrackersShown
            || settings.browsingMajorTrackingSiteShown
            || settings.browsingOwnedByMajorTrackingSiteShown
    }
    
    func dismiss() {
        settings.isDismissed = true
    }
    
    func nextBrowsingMessage(siteRating: SiteRating) -> BrowsingSpec? {
        guard let host = siteRating.domain else { return nil }
        guard !settings.isDismissed else { return nil }
                
        if appUrls.isDuckDuckGoSearch(url: siteRating.url) {
            return searchMessage()
        }
        
        if isMajorTracker(host) {
            return majorTrackerMessage()
        }
        
        if let owner = majorTrackerOwnerOf(host) {
            return majorTrackerOwnerMessage(host, owner)
        }
        
        if siteRating.trackersBlocked.isEmpty {
            return noTrackersMessage()
        }
        
        if let trackersBlocked = trackersBlocked(siteRating) {
            return trackersBlockedMessage(trackersBlocked)
        }
        
        return nil
    }
    
    /// Get the next home screen message.
    ///
    /// Returns a tuple containing the height of the dialog and the message or nil if there's nothing left to show or the flow has been disabled
    func nextHomeScreenMessage() -> HomeScreenSpec? {
        guard !settings.isDismissed else { return nil }
        guard settings.homeScreenMessagesSeen < 2 else { return nil }
        
        if settings.homeScreenMessagesSeen == 0 {
            settings.homeScreenMessagesSeen += 1
            return .initial
        }
        
        if browsingMessageSeen {
            settings.homeScreenMessagesSeen += 1
            return .subsequent
        }
        
        return nil
    }
    
    private func noTrackersMessage() -> DaxDialogs.BrowsingSpec? {
        if !settings.browsingWithoutTrackersShown {
            settings.browsingWithoutTrackersShown = true
            return BrowsingSpec.withoutTrackers
        }
        return nil
    }

    func majorTrackerOwnerMessage(_ host: String, _ majorTrackerEntity: Entity) -> DaxDialogs.BrowsingSpec? {
        guard !settings.browsingOwnedByMajorTrackingSiteShown else { return nil }
        settings.browsingOwnedByMajorTrackingSiteShown = true
        return BrowsingSpec.siteOwnedByMajorTracker.format(args: host.dropPrefix(prefix: "www."),
                                                           majorTrackerEntity.displayName ?? "",
                                                           majorTrackerEntity.prevalence ?? 0.0)
    }
    
    private func majorTrackerMessage() -> DaxDialogs.BrowsingSpec? {
        guard !settings.browsingMajorTrackingSiteShown else { return nil }
        settings.browsingMajorTrackingSiteShown = true
        return BrowsingSpec.siteIsMajorTracker
    }
    
    private func searchMessage() -> BrowsingSpec? {
        guard !settings.browsingAfterSearchShown else { return nil }
        settings.browsingAfterSearchShown = true
        return BrowsingSpec.afterSearch
    }
    
    private func trackersBlockedMessage(_ trackersBlocked: (major: [Entity], other: [Entity])) -> BrowsingSpec? {
        guard !settings.browsingWithTrackersShown else { return nil }
        settings.browsingWithTrackersShown = true

        switch trackersBlocked {
            
        case let x where x.major.count == 1 && x.other.count == 0:
            return BrowsingSpec.withOneMajorTracker.format(args: x.major[0].displayName ?? "")

        case let x where x.major.count == 1 && x.other.count > 0:
            return BrowsingSpec.withOneMajorTrackerAndOthers.format(args: x.major[0].displayName ?? "", x.other.count)

        case let x where x.major.count == 2 && x.other.count == 0:
            return BrowsingSpec.withTwoMajorTrackers.format(args: x.major[0].displayName ?? "", x.major[1].displayName ?? "")

        case let x where x.major.count == 2 && x.other.count > 0:
            return BrowsingSpec.withTwoMajorTrackersAndOthers.format(args: x.major[0].displayName ?? "", x.major[1].displayName ?? "", x.other.count)

        default: return nil
        }

    }
 
    private func trackersBlocked(_ siteRating: SiteRating) -> (major: [Entity], other: [Entity])? {
        guard !siteRating.trackersBlocked.isEmpty else { return nil }

        var major = Set<Entity>()
        var other = Set<Entity>()
        
        siteRating.trackersBlocked.forEach {
            guard let entity = $0.entity else { return }
            if entity.domains?.contains(MajorTrackers.facebookDomain) ?? false {
                major.insert(entity)
            } else if entity.domains?.contains(MajorTrackers.googleDomain) ?? false {
                major.insert(entity)
            } else {
                other.insert(entity)
            }
        }
        
        return (Array(major).sorted(by: { $0.prevalence ?? 0.0 > $1.prevalence ?? 0.0 }), Array(other))
    }
    
    private func isMajorTracker(_ host: String) -> Bool {
        return [ MajorTrackers.facebookDomain, MajorTrackers.googleDomain ].contains { domain in
            return domain == host || host.hasSuffix("." + domain)
        }
    }
    
    private func majorTrackerOwnerOf(_ host: String) -> Entity? {
        guard let entity = TrackerDataManager.shared.findEntity(forHost: host) else { return nil }
        return entity.domains?.contains(where: { MajorTrackers.domains.contains($0) }) ?? false ? entity : nil
    }
    
}
