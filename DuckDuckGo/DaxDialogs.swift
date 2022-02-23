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
import TrackerRadarKit
import BrowserServicesKit

// swiftlint:disable type_body_length

class DaxDialogs {
    
    struct MajorTrackers {
        
        static let facebookDomain = "facebook.com"
        static let googleDomain = "google.com"
        
        static let domains = [ Self.facebookDomain, Self.googleDomain ]
        
    }
    
    struct HomeScreenSpec: Equatable {
        static let initial = HomeScreenSpec(message: UserText.daxDialogHomeInitial, accessibilityLabel: nil)
        static let subsequent = HomeScreenSpec(message: UserText.daxDialogHomeSubsequent, accessibilityLabel: nil)
        static let addFavorite = HomeScreenSpec(message: UserText.daxDialogHomeAddFavorite,
                                                accessibilityLabel: UserText.daxDialogHomeAddFavoriteAccessible)

        let message: String
        let accessibilityLabel: String?
    }
    
    func overrideShownFlagFor(_ spec: BrowsingSpec, flag: Bool) {
        switch spec.type {
        case .withMultipleTrackers, .withOneTracker :
            settings.browsingWithTrackersShown = flag
        case .afterSearch:
            settings.browsingAfterSearchShown = flag
        case .withoutTrackers:
            settings.browsingWithoutTrackersShown = flag
        case .siteIsMajorTracker, .siteOwnedByMajorTracker:
            settings.browsingMajorTrackingSiteShown = flag
            settings.browsingWithoutTrackersShown = flag
         }
    }
    
    struct BrowsingSpec: Equatable {
        // swiftlint:disable nesting

        enum SpecType {
            case afterSearch
            case withoutTrackers
            case siteIsMajorTracker
            case siteOwnedByMajorTracker
            case withOneTracker
            case withMultipleTrackers
        }
        // swiftlint:enable nesting

        static let afterSearch = BrowsingSpec(message: UserText.daxDialogBrowsingAfterSearch,
                                              cta: UserText.daxDialogBrowsingAfterSearchCTA,
                                              highlightAddressBar: false,
                                              pixelName: .daxDialogsSerp, type: .afterSearch)
        
        static let withoutTrackers = BrowsingSpec(message: UserText.daxDialogBrowsingWithoutTrackers,
                                                  cta: UserText.daxDialogBrowsingWithoutTrackersCTA,
                                                  highlightAddressBar: false,
                                                  pixelName: .daxDialogsWithoutTrackers, type: .withoutTrackers)
        
        static let siteIsMajorTracker = BrowsingSpec(message: UserText.daxDialogBrowsingSiteIsMajorTracker,
                                                     cta: UserText.daxDialogBrowsingSiteIsMajorTrackerCTA,
                                                     highlightAddressBar: false,
                                                     pixelName: .daxDialogsSiteIsMajor, type: .siteIsMajorTracker)
        
        static let siteOwnedByMajorTracker = BrowsingSpec(message: UserText.daxDialogBrowsingSiteOwnedByMajorTracker,
                                                          cta: UserText.daxDialogBrowsingSiteOwnedByMajorTrackerCTA,
                                                          highlightAddressBar: false,
                                                          pixelName: .daxDialogsSiteOwnedByMajor, type: .siteOwnedByMajorTracker)
        
        static let withOneTracker = BrowsingSpec(message: UserText.daxDialogBrowsingWithOneTracker,
                                                 cta: UserText.daxDialogBrowsingWithOneTrackerCTA,
                                                 highlightAddressBar: true,
                                                 pixelName: .daxDialogsWithTrackers, type: .withOneTracker)
        
        static let withMultipleTrackers = BrowsingSpec(message: UserText.daxDialogBrowsingWithMultipleTrackers,
                                                      cta: UserText.daxDialogBrowsingWithMultipleTrackersCTA,
                                                      highlightAddressBar: true,
                                                      pixelName: .daxDialogsWithTrackers, type: .withMultipleTrackers)
        
        let message: String
        let cta: String
        let highlightAddressBar: Bool
        let pixelName: PixelName
        let type: SpecType
        
        func format(args: CVarArg...) -> BrowsingSpec {
            return BrowsingSpec(message: String(format: message, arguments: args),
                                cta: cta,
                                highlightAddressBar: highlightAddressBar,
                                pixelName: pixelName,
                                type: type)
        }
    }
    
    struct ActionSheetSpec: Equatable {
        static let fireButtonEducation = ActionSheetSpec(message: UserText.daxDialogFireButtonEducation,
                                                         confirmAction: UserText.daxDialogFireButtonEducationConfirmAction,
                                                         cancelAction: UserText.daxDialogFireButtonEducationCancelAction,
                                                         isConfirmActionDestructive: true,
                                                         displayedPixelName: .daxDialogsFireEducationShown,
                                                         confirmActionPixelName: .daxDialogsFireEducationConfirmed,
                                                         cancelActionPixelName: .daxDialogsFireEducationCancelled)
        
        let message: String
        let confirmAction: String
        let cancelAction: String
        let isConfirmActionDestructive: Bool
        
        let displayedPixelName: PixelName
        let confirmActionPixelName: PixelName
        let cancelActionPixelName: PixelName
    }

    public static let shared = DaxDialogs()

    private let appUrls = AppUrls()
    private var settings: DaxDialogsSettings
    private var contentBlockingRulesManager: ContentBlockerRulesManager
    private let variantManager: VariantManager

    private var nextHomeScreenMessageOverride: HomeScreenSpec?

    /// Use singleton accessor, this is only accessible for tests
    init(settings: DaxDialogsSettings = DefaultDaxDialogsSettings(),
         contentBlockingRulesManager: ContentBlockerRulesManager = ContentBlocking.contentBlockingManager,
         variantManager: VariantManager = DefaultVariantManager()) {
        self.settings = settings
        self.contentBlockingRulesManager = contentBlockingRulesManager
        self.variantManager = variantManager
    }
    
    private var firstBrowsingMessageSeen: Bool {
        return settings.browsingAfterSearchShown
            || settings.browsingWithTrackersShown
            || settings.browsingWithoutTrackersShown
            || settings.browsingMajorTrackingSiteShown
    }
    
    private var nonDDGBrowsingMessageSeen: Bool {
        settings.browsingWithTrackersShown
        || settings.browsingWithoutTrackersShown
        || settings.browsingMajorTrackingSiteShown
    }
    
    private var fireButtonBrowsingMessageSeenOrExpired: Bool {
        return settings.fireButtonEducationShownOrExpired
    }
    
    var isEnabled: Bool {
        // skip dax dialogs in integration tests
        guard ProcessInfo.processInfo.environment["DAXDIALOGS"] != "false" else { return false }
        return !settings.isDismissed
    }

    var isAddFavoriteFlow: Bool {
        return nextHomeScreenMessageOverride == .addFavorite
    }
    
    var shouldShowFireButtonPulse: Bool {
        return nonDDGBrowsingMessageSeen && !fireButtonBrowsingMessageSeenOrExpired && isEnabled
    }

    func dismiss() {
        settings.isDismissed = true
    }
    
    func primeForUse() {
        settings.isDismissed = false
    }

    func enableAddFavoriteFlow() {
        nextHomeScreenMessageOverride = .addFavorite
        // Progress to next home screen message, but don't re-show the second dax dialog if it's already been shown
        settings.homeScreenMessagesSeen = max(settings.homeScreenMessagesSeen, 1)
    }

    func resumeRegularFlow() {
        nextHomeScreenMessageOverride = nil
    }
    
    private var fireButtonPulseTimer: Timer?
    private static let timeToFireButtonExpire: TimeInterval = 1 * 60 * 60
    
    func fireButtonPulseStarted() {
        if settings.fireButtonPulseDateShown == nil {
            settings.fireButtonPulseDateShown = Date()
        }
        if fireButtonPulseTimer == nil, let date = settings.fireButtonPulseDateShown {
            let timeSinceShown = Date().timeIntervalSince(date)
            let timerTime = DaxDialogs.timeToFireButtonExpire - timeSinceShown
            fireButtonPulseTimer = Timer(timeInterval: timerTime, repeats: false) { _ in
                self.settings.fireButtonEducationShownOrExpired = true
                ViewHighlighter.hideAll()
            }
            RunLoop.current.add(fireButtonPulseTimer!, forMode: RunLoop.Mode.common)
        }
    }
    
    func fireButtonPulseCancelled() {
        fireButtonPulseTimer?.invalidate()
        settings.fireButtonEducationShownOrExpired = true
    }
    
    func fireButtonEducationMessage() -> ActionSheetSpec? {
        guard shouldShowFireButtonPulse else { return nil }
        settings.fireButtonEducationShownOrExpired = true
        return ActionSheetSpec.fireButtonEducation
    }

    func nextBrowsingMessage(siteRating: SiteRating) -> BrowsingSpec? {
        guard isEnabled, nextHomeScreenMessageOverride == nil else { return nil }
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
        if nextHomeScreenMessageOverride != nil {
            return nextHomeScreenMessageOverride
        }

        guard isEnabled else { return nil }
        guard settings.homeScreenMessagesSeen < 2 else { return nil }
        
        if settings.homeScreenMessagesSeen == 0 {
            settings.homeScreenMessagesSeen += 1
            return .initial
        }
        
        if firstBrowsingMessageSeen {
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
        guard let currentTrackerData = contentBlockingRulesManager.currentTDSRules?.trackerData,
              let entity = currentTrackerData.findEntity(forHost: host),
            let entityName = entity.displayName else { return nil }
        settings.browsingMajorTrackingSiteShown = true
        settings.browsingWithoutTrackersShown = true
        return BrowsingSpec.siteIsMajorTracker.format(args: entityName, host)
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
            return BrowsingSpec.withMultipleTrackers.format(args: entitiesBlocked.count - 2,
                                                           entitiesBlocked[0].displayName ?? "",
                                                           entitiesBlocked[1].displayName ?? "")
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
        guard let currentTrackerData = contentBlockingRulesManager.currentTDSRules?.trackerData,
              let entity = currentTrackerData.findEntity(forHost: host) else { return nil }
        return entity.domains?.contains(where: { MajorTrackers.domains.contains($0) }) ?? false ? entity : nil
    }
}
// swiftlint:enable type_body_length
