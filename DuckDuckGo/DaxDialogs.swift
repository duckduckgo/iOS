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
                                              cta: UserText.daxDialogBrowsingAfterSearchCTA,
                                              highlightAddressBar: false,
                                              pixelName: .daxDialogsSerp)
        
        static let withoutTrackers = BrowsingSpec(height: 260,
                                                  message: UserText.daxDialogBrowsingWithoutTrackers,
                                                  cta: UserText.daxDialogBrowsingWithoutTrackersCTA,
                                                  highlightAddressBar: false,
                                                  pixelName: .daxDialogsWithoutTrackers)
        
        static let siteIsMajorTracker = BrowsingSpec(height: 345,
                                                     message: UserText.daxDialogBrowsingSiteIsMajorTracker,
                                                     cta: UserText.daxDialogBrowsingSiteIsMajorTrackerCTA,
                                                     highlightAddressBar: false,
                                                     pixelName: .daxDialogsSiteIsMajor)
        
        static let siteOwnedByMajorTracker = BrowsingSpec(height: 365,
                                                          message: UserText.daxDialogBrowsingSiteOwnedByMajorTracker,
                                                          cta: UserText.daxDialogBrowsingSiteOwnedByMajorTrackerCTA,
                                                          highlightAddressBar: false,
                                                          pixelName: .daxDialogsSiteOwnedByMajor)
        
        static let withOneTracker = BrowsingSpec(height: 345,
                                                      message: UserText.daxDialogBrowsingWithOneTracker,
                                                      cta: UserText.daxDialogBrowsingWithOneTrackerCTA,
                                                      highlightAddressBar: true,
                                                      pixelName: .daxDialogsWithTrackers)
        
        static let withMutipleTrackers = BrowsingSpec(height: 345,
                                                               message: UserText.daxDialogBrowsingWithMultipleTrackers,
                                                               cta: UserText.daxDialogBrowsingWithMultipleTrackersCTA,
                                                               highlightAddressBar: true,
                                                               pixelName: .daxDialogsWithTrackers)


        let height: CGFloat
        let message: String
        let cta: String
        let highlightAddressBar: Bool
        let pixelName: PixelName
        
        func format(args: CVarArg...) -> BrowsingSpec {
            return BrowsingSpec(height: height,
                                message: String(format: message, arguments: args),
                                cta: cta,
                                highlightAddressBar: highlightAddressBar,
                                pixelName: pixelName)
        }
        
    }
    
    private let appUrls = AppUrls()
    private var settings: DaxDialogsSettings
    
    init(settings: DaxDialogsSettings = DefaultDaxDialogsSettings()) {
        self.settings = settings
    }
    
    private var browsingMessageSeen: Bool {
        return settings.browsingAfterSearchShown
            || settings.browsingWithTrackersShown
            || settings.browsingWithoutTrackersShown
            || settings.browsingMajorTrackingSiteShown
    }
    
    func dismiss() {
        settings.isDismissed = true
    }
    
    func primeForUse() {
        settings.isDismissed = false
    }
    
    var isEnabled: Bool {
        // skip dax dialogs in integration tests
        guard ProcessInfo.processInfo.environment["DAXDIALOGS"] != "false" else { return false }
        return !settings.isDismissed
    }
    
    func nextBrowsingMessage(siteRating: SiteRating) -> BrowsingSpec? {
        guard isEnabled else { return nil }
        guard let host = siteRating.domain else { return nil }
                
        if appUrls.isDuckDuckGoSearch(url: siteRating.url) {
            return searchMessage()
        }
        
        // won't be shown if owned by major tracker message has already been shown
        if isFacebookOrGoogle(siteRating.url) {
            return majorTrackerMessage(host)
        }
        
        // won't be shown if major tracker message has already been shown
        if let owner = isOwnedByFacebookOrGoogle(host) {
            return majorTrackerOwnerMessage(host, owner)
        }
        
        if let entities = entitiesBlocked(siteRating) {
            return trackersBlockedMessage(entities)
        }
        
        // only shown if first time on a non-ddg page and none of the non-ddg messages shown
        return noTrackersMessage()
    }
    
    func nextHomeScreenMessage() -> HomeScreenSpec? {
        guard isEnabled else { return nil }
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
        if !settings.browsingWithoutTrackersShown && !settings.browsingMajorTrackingSiteShown && !settings.browsingWithTrackersShown {
            settings.browsingWithoutTrackersShown = true
            return BrowsingSpec.withoutTrackers
        }
        return nil
    }

    func majorTrackerOwnerMessage(_ host: String, _ majorTrackerEntity: Entity) -> DaxDialogs.BrowsingSpec? {
        guard !settings.browsingMajorTrackingSiteShown else { return nil }
        guard let entityName = majorTrackerEntity.displayName,
            let entityPrevalence = majorTrackerEntity.prevalence else { return nil }
        settings.browsingMajorTrackingSiteShown = true
        settings.browsingWithoutTrackersShown = true
        return BrowsingSpec.siteOwnedByMajorTracker.format(args: host.dropPrefix(prefix: "www."),
                                                           entityName,
                                                           entityPrevalence)
    }
    
    private func majorTrackerMessage(_ host: String) -> DaxDialogs.BrowsingSpec? {
        guard !settings.browsingMajorTrackingSiteShown else { return nil }
        guard let entity = TrackerDataManager.shared.findEntity(forHost: host),
            let entityName = entity.displayName,
            let entityPrevalence = entity.prevalence else { return nil }
        settings.browsingMajorTrackingSiteShown = true
        settings.browsingWithoutTrackersShown = true
        return BrowsingSpec.siteIsMajorTracker.format(args: entityName, entityPrevalence)
    }
    
    private func searchMessage() -> BrowsingSpec? {
        guard !settings.browsingAfterSearchShown else { return nil }
        settings.browsingAfterSearchShown = true
        return BrowsingSpec.afterSearch
    }
    
    private func trackersBlockedMessage(_ entitiesBlocked: [Entity]) -> BrowsingSpec? {
        guard !settings.browsingWithTrackersShown else { return nil }

        switch entitiesBlocked.count {

        case 0:
            return nil
            
        case 1:
            settings.browsingWithTrackersShown = true
            return BrowsingSpec.withOneTracker.format(args: entitiesBlocked[0].displayName ?? "")
            
        default:
            settings.browsingWithTrackersShown = true
            return BrowsingSpec.withMutipleTrackers.format(args: entitiesBlocked.count - 2, entitiesBlocked[0].displayName ?? "", entitiesBlocked[1].displayName ?? "")
        }

    }
 
    private func entitiesBlocked(_ siteRating: SiteRating) -> [Entity]? {
        guard !siteRating.trackersBlocked.isEmpty else { return nil }
        let entities = Set<Entity>(siteRating.trackersBlocked.compactMap { $0.entity })
        return Array(entities).sorted(by: { $0.prevalence ?? 0.0 > $1.prevalence ?? 0.0 })
    }
    
    private func isFacebookOrGoogle(_ url: URL) -> Bool {
        return [ MajorTrackers.facebookDomain, MajorTrackers.googleDomain ].contains { domain in
            return url.isPart(ofDomain: domain)
        }
    }
    
    private func isOwnedByFacebookOrGoogle(_ host: String) -> Entity? {
        guard let entity = TrackerDataManager.shared.findEntity(forHost: host) else { return nil }
        return entity.domains?.contains(where: { MajorTrackers.domains.contains($0) }) ?? false ? entity : nil
    }
    
}
