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
import Common
import PrivacyDashboard

protocol EntityProviding {
    
    func entity(forHost host: String) -> Entity?
    
}

protocol NewTabDialogSpecProvider {
    func nextHomeScreenMessage() -> DaxDialogs.HomeScreenSpec?
    func nextHomeScreenMessageNew() -> DaxDialogs.HomeScreenSpec?
    func dismiss()
}

protocol ContextualOnboardingLogic {
    func setFireEducationMessageSeen()
}

extension ContentBlockerRulesManager: EntityProviding {
    
    func entity(forHost host: String) -> Entity? {
        currentMainRules?.trackerData.findEntity(forHost: host)
    }
    
}

final class DaxDialogs: NewTabDialogSpecProvider, ContextualOnboardingLogic {
    
    struct MajorTrackers {
        
        static let facebookDomain = "facebook.com"
        static let googleDomain = "google.com"
        
        static let domains = [facebookDomain, googleDomain]
        
    }
    
    struct HomeScreenSpec: Equatable {
        static let initial = HomeScreenSpec(message: UserText.daxDialogHomeInitial, accessibilityLabel: nil)
        static let subsequent = HomeScreenSpec(message: "", accessibilityLabel: nil)
        static let final = HomeScreenSpec(message: UserText.daxDialogHomeSubsequent, accessibilityLabel: nil)
        static let addFavorite = HomeScreenSpec(message: UserText.daxDialogHomeAddFavorite,
                                                accessibilityLabel: UserText.daxDialogHomeAddFavoriteAccessible)

        let message: String
        let accessibilityLabel: String?
    }
    
    func overrideShownFlagFor(_ spec: BrowsingSpec, flag: Bool) {
        switch spec.type {
        case .withMultipleTrackers, .withOneTracker:
            settings.browsingWithTrackersShown = flag
        case .afterSearch, .afterSearchWithWebsitesFollowUp:
            settings.browsingAfterSearchShown = flag
        case .withoutTrackers:
            settings.browsingWithoutTrackersShown = flag
        case .siteIsMajorTracker, .siteOwnedByMajorTracker:
            settings.browsingMajorTrackingSiteShown = flag
            settings.browsingWithoutTrackersShown = flag
        case .final:
            settings.browsingFinalDialogShown = flag
        }
    }
    
    struct BrowsingSpec: Equatable {
        // swiftlint:disable nesting

        enum SpecType {
            case afterSearch
            case afterSearchWithWebsitesFollowUp
            case withoutTrackers
            case siteIsMajorTracker
            case siteOwnedByMajorTracker
            case withOneTracker
            case withMultipleTrackers
            case final
        }
        // swiftlint:enable nesting

        private static func afterSearch(followUpWithWebsiteSearch: Bool) -> BrowsingSpec {
            let specType = followUpWithWebsiteSearch ? SpecType.afterSearchWithWebsitesFollowUp : SpecType.afterSearch
            return BrowsingSpec(
                message: UserText.daxDialogBrowsingAfterSearch,
                cta: UserText.daxDialogBrowsingAfterSearchCTA,
                highlightAddressBar: false,
                pixelName: .daxDialogsSerp,
                type: specType
            )
        }

        static let afterSearch = afterSearch(followUpWithWebsiteSearch: false)

        static let afterSearchWithWebsitesFollowUp = afterSearch(followUpWithWebsiteSearch: true)

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

        // TODO: Change pixel name
        static let final = BrowsingSpec(message: UserText.daxDialogHomeSubsequent, cta: "", highlightAddressBar: false, pixelName: .daxDialogsWithoutTrackersFollowUp, type: .final)

        let message: String
        let cta: String
        fileprivate(set) var highlightAddressBar: Bool
        let pixelName: Pixel.Event
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
        
        let displayedPixelName: Pixel.Event
        let confirmActionPixelName: Pixel.Event
        let cancelActionPixelName: Pixel.Event
    }

    private enum Constants {
        static let homeScreenMessagesSeenMaxCeiling = 2
    }

    public static let shared = DaxDialogs(entityProviding: ContentBlocking.shared.contentBlockingManager)

    private var settings: DaxDialogsSettings
    private var entityProviding: EntityProviding
    private let variantManager: VariantManager

    private var nextHomeScreenMessageOverride: HomeScreenSpec?
    
    // So we can avoid showing two dialogs for the same page
    private var lastURLDaxDialogReturnedFor: URL?

    /// Use singleton accessor, this is only accessible for tests
    init(settings: DaxDialogsSettings = DefaultDaxDialogsSettings(),
         entityProviding: EntityProviding,
         variantManager: VariantManager = DefaultVariantManager()) {
        self.settings = settings
        self.entityProviding = entityProviding
        self.variantManager = variantManager
    }

    private var isNewOnboarding: Bool {
        variantManager.isSupported(feature: .newOnboardingIntro)
    }

    private var firstBrowsingMessageSeen: Bool {
        return settings.browsingAfterSearchShown
            || settings.browsingWithTrackersShown
            || settings.browsingWithoutTrackersShown
            || settings.browsingMajorTrackingSiteShown
    }

    private var firstSearchSeenButNoSiteVisited: Bool {
        return settings.browsingAfterSearchShown
            && !settings.browsingWithTrackersShown
            && !settings.browsingWithoutTrackersShown
            && !settings.browsingMajorTrackingSiteShown
    }

    private var nonDDGBrowsingMessageSeen: Bool {
        settings.browsingWithTrackersShown
        || settings.browsingWithoutTrackersShown
        || settings.browsingMajorTrackingSiteShown
    }

    private var finalDaxDialogSeen: Bool {
        settings.browsingFinalDialogShown
    }

    private var visitedSiteAndFireButtonSeen: Bool {
        fireButtonBrowsingMessageSeenOrExpired &&
        firstBrowsingMessageSeen
    }

    private var shouldDisplayFinalContextualBrowsingDialog: Bool {
        !finalDaxDialogSeen &&
        visitedSiteAndFireButtonSeen
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

    func isStillOnboarding() -> Bool {
        if isNewOnboarding {
            if peekNextHomeScreenMessageExperiment() != nil {
                return true
            }
        } else if peekNextHomeScreenMessage() != nil {
            return true
        }
        return false
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
    
    func clearHeldURLData() {
        lastURLDaxDialogReturnedFor = nil
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

    func setFireEducationMessageSeen() {
        guard isNewOnboarding else { return }
        settings.fireButtonEducationShownOrExpired = true
    }

    func nextBrowsingMessageIfShouldShow(for privacyInfo: PrivacyInfo) -> BrowsingSpec? {
        guard privacyInfo.url != lastURLDaxDialogReturnedFor else { return nil }
        
        let message = if isNewOnboarding {
            nextBrowsingMessageExperiment(privacyInfo: privacyInfo)
        } else {
            nextBrowsingMessage(privacyInfo: privacyInfo)
        }

        if message != nil {
            lastURLDaxDialogReturnedFor = privacyInfo.url
        }
        
        return message
    }

    private func nextBrowsingMessage(privacyInfo: PrivacyInfo) -> BrowsingSpec? {
        guard isEnabled, nextHomeScreenMessageOverride == nil else { return nil }
        guard let host = privacyInfo.domain else { return nil }
        
        if privacyInfo.url.isDuckDuckGoSearch {
            return searchMessage()
        }

        // won't be shown if owned by major tracker message has already been shown
        if isFacebookOrGoogle(privacyInfo.url) {
            return majorTrackerMessage(host)
        }
        
        // won't be shown if major tracker message has already been shown
        if let owner = isOwnedByFacebookOrGoogle(host) {
            return majorTrackerOwnerMessage(host, owner)
        }
        
        if let entityNames = blockedEntityNames(privacyInfo.trackerInfo) {
            return trackersBlockedMessage(entityNames)
        }
        
        // only shown if first time on a non-ddg page and none of the non-ddg messages shown
        return noTrackersMessage()
    }

    private func nextBrowsingMessageExperiment(privacyInfo: PrivacyInfo) -> BrowsingSpec? {
        guard isEnabled, nextHomeScreenMessageOverride == nil else { return nil }
        guard let host = privacyInfo.domain else { return nil }

        // If the user visited a website and saw the fire dialog
        if shouldDisplayFinalContextualBrowsingDialog {
            return finalMessage()
        }

        if privacyInfo.url.isDuckDuckGoSearch {
            // If user already visited a site, show after search dialog but don't follow up by suggesting to visit a site.
            // Otherwise show after search dialog and follow up by suggesting to visit a site.
            if nonDDGBrowsingMessageSeen {
                return searchMessage()
            } else {
                return searchMessageWithWebsitesFollowUp()
            }
        }

        // won't be shown if owned by major tracker message has already been shown
        if isFacebookOrGoogle(privacyInfo.url) {
            return majorTrackerMessage(host)
        }

        // won't be shown if major tracker message has already been shown
        if let owner = isOwnedByFacebookOrGoogle(host) {
            return majorTrackerOwnerMessage(host, owner)
        }

        if let entityNames = blockedEntityNames(privacyInfo.trackerInfo) {
            return trackersBlockedMessage(entityNames)
        }

        // only shown if first time on a non-ddg page and none of the non-ddg messages shown
        return noTrackersMessage()
    }

    func nextHomeScreenMessage() -> HomeScreenSpec? {
        guard let homeScreenSpec = peekNextHomeScreenMessage() else { return nil }

        if homeScreenSpec != nextHomeScreenMessageOverride {
            settings.homeScreenMessagesSeen += 1
        }

        return homeScreenSpec
    }

    func nextHomeScreenMessageNew() -> HomeScreenSpec? {
        guard let homeScreenSpec = peekNextHomeScreenMessageExperiment() else { return nil }
        return homeScreenSpec
    }

    private func peekNextHomeScreenMessage() -> HomeScreenSpec? {
        if nextHomeScreenMessageOverride != nil {
            return nextHomeScreenMessageOverride
        }

        guard isEnabled else { return nil }
        guard settings.homeScreenMessagesSeen < Constants.homeScreenMessagesSeenMaxCeiling else { return nil }

        if settings.homeScreenMessagesSeen == 0 {
            return .initial
        }

        if firstBrowsingMessageSeen {
            return .final
        }

        return nil
    }

    private func peekNextHomeScreenMessageExperiment() -> HomeScreenSpec? {
        if nextHomeScreenMessageOverride != nil {
            return nextHomeScreenMessageOverride
        }
        guard isEnabled else { return nil }

        if !settings.browsingAfterSearchShown {
            return .initial
        }

        if firstSearchSeenButNoSiteVisited {
            return .subsequent
        }

        if firstBrowsingMessageSeen && !finalDaxDialogSeen  {
            // Ensure we don't show the final dialog again in context when the user sees it and vice-versa.
            settings.browsingFinalDialogShown = true
            return .final
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
        return BrowsingSpec.siteOwnedByMajorTracker.format(args: host.droppingWwwPrefix(),
                                                           entityName,
                                                           entityPrevalence)
    }
    
    private func majorTrackerMessage(_ host: String) -> DaxDialogs.BrowsingSpec? {
        guard !settings.browsingMajorTrackingSiteShown else { return nil }
        guard let entityName = entityProviding.entity(forHost: host)?.displayName else { return nil }
        settings.browsingMajorTrackingSiteShown = true
        settings.browsingWithoutTrackersShown = true
        return BrowsingSpec.siteIsMajorTracker.format(args: entityName, host)
    }
    
    private func searchMessage() -> BrowsingSpec? {
        guard !settings.browsingAfterSearchShown else { return nil }
        settings.browsingAfterSearchShown = true
        return BrowsingSpec.afterSearch
    }

    private func searchMessageWithWebsitesFollowUp() -> BrowsingSpec? {
        guard !settings.browsingAfterSearchShown else { return nil }
        settings.browsingAfterSearchShown = true
        return BrowsingSpec.afterSearchWithWebsitesFollowUp
    }

    private func finalMessage() -> BrowsingSpec? {
        guard !finalDaxDialogSeen else { return nil }
        settings.browsingFinalDialogShown = true
        return BrowsingSpec.final
    }

    private func trackersBlockedMessage(_ entitiesBlocked: [String]) -> BrowsingSpec? {
        guard !settings.browsingWithTrackersShown else { return nil }

        var spec: BrowsingSpec?
        switch entitiesBlocked.count {

        case 0:
            spec = nil

        case 1:
            settings.browsingWithTrackersShown = true
            spec = BrowsingSpec.withOneTracker.format(args: entitiesBlocked[0])

        default:
            settings.browsingWithTrackersShown = true
            spec = BrowsingSpec.withMultipleTrackers.format(args: entitiesBlocked.count - 2,
                                                           entitiesBlocked[0],
                                                           entitiesBlocked[1])
        }
        // New Contextual onboarding doesn't highlight the address bar. This checks prevents to cancel the lottie animation.
        if isNewOnboarding {
            spec?.highlightAddressBar = false
        }
        return spec
    }
 
    private func blockedEntityNames(_ trackerInfo: TrackerInfo) -> [String]? {
        guard !trackerInfo.trackersBlocked.isEmpty else { return nil }
        
        return trackerInfo.trackersBlocked.removingDuplicates { $0.entityName }
            .sorted(by: { $0.prevalence ?? 0.0 > $1.prevalence ?? 0.0 })
            .compactMap { $0.entityName }
    }
    
    private func isFacebookOrGoogle(_ url: URL) -> Bool {
        return [ MajorTrackers.facebookDomain, MajorTrackers.googleDomain ].contains { domain in
            return url.isPart(ofDomain: domain)
        }
    }
    
    private func isOwnedByFacebookOrGoogle(_ host: String) -> Entity? {
        guard let entity = entityProviding.entity(forHost: host) else { return nil }
        return entity.domains?.contains(where: { MajorTrackers.domains.contains($0) }) ?? false ? entity : nil
    }
}
