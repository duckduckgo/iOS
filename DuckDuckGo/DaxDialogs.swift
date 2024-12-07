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
    func nextHomeScreenMessageNew() -> DaxDialogs.HomeScreenSpec?
    func dismiss()
}

protocol ContextualOnboardingLogic {
    var isShowingFireDialog: Bool { get }
    var shouldShowPrivacyButtonPulse: Bool { get }
    var isShowingSearchSuggestions: Bool { get }
    var isShowingSitesSuggestions: Bool { get }
    var isShowingAddToDockDialog: Bool { get }

    func setSearchMessageSeen()
    func setFireEducationMessageSeen()
    func clearedBrowserData()
    func setFinalOnboardingDialogSeen()
    func setPrivacyButtonPulseSeen()
    func setDaxDialogDismiss()

    func enableAddFavoriteFlow()
}

extension ContentBlockerRulesManager: EntityProviding {
    
    func entity(forHost host: String) -> Entity? {
        currentMainRules?.trackerData.findParentEntityOrFallback(forHost: host)
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
        case .afterSearch:
            settings.browsingAfterSearchShown = flag
        case .visitWebsite:
            break
        case .withoutTrackers:
            settings.browsingWithoutTrackersShown = flag
        case .siteIsMajorTracker, .siteOwnedByMajorTracker:
            settings.browsingMajorTrackingSiteShown = flag
            settings.browsingWithoutTrackersShown = flag
        case .fire:
            settings.fireMessageExperimentShown = flag
        case .final:
            settings.browsingFinalDialogShown = flag
        }
    }
    
    struct BrowsingSpec: Equatable {
        // swiftlint:disable nesting

        enum SpecType: String {
            case afterSearch
            case visitWebsite
            case withoutTrackers
            case siteIsMajorTracker
            case siteOwnedByMajorTracker
            case withOneTracker
            case withMultipleTrackers
            case fire
            case final
        }
        // swiftlint:enable nesting

        static let afterSearch = BrowsingSpec(message: UserText.daxDialogBrowsingAfterSearch,
                                              cta: UserText.daxDialogBrowsingAfterSearchCTA,
                                              highlightAddressBar: false,
                                              pixelName: .daxDialogsSerpUnique,
                                              type: .afterSearch)

        // Message and CTA empty on purpose as for this case we use only pixelName and type
        static let visitWebsite = BrowsingSpec(message: "", cta: "", highlightAddressBar: false, pixelName: .onboardingContextualTryVisitSiteUnique, type: .visitWebsite)

        static let withoutTrackers = BrowsingSpec(message: UserText.daxDialogBrowsingWithoutTrackers,
                                                  cta: UserText.daxDialogBrowsingWithoutTrackersCTA,
                                                  highlightAddressBar: false,
                                                  pixelName: .daxDialogsWithoutTrackersUnique, type: .withoutTrackers)

        static let siteIsMajorTracker = BrowsingSpec(message: UserText.daxDialogBrowsingSiteIsMajorTracker,
                                                     cta: UserText.daxDialogBrowsingSiteIsMajorTrackerCTA,
                                                     highlightAddressBar: false,
                                                     pixelName: .daxDialogsSiteIsMajorUnique, type: .siteIsMajorTracker)

        static let siteOwnedByMajorTracker = BrowsingSpec(message: UserText.daxDialogBrowsingSiteOwnedByMajorTracker,
                                                          cta: UserText.daxDialogBrowsingSiteOwnedByMajorTrackerCTA,
                                                          highlightAddressBar: false,
                                                          pixelName: .daxDialogsSiteOwnedByMajorUnique, type: .siteOwnedByMajorTracker)

        static let withOneTracker = BrowsingSpec(message: UserText.Onboarding.ContextualOnboarding.daxDialogBrowsingWithOneTracker,
                                                 cta: UserText.daxDialogBrowsingWithOneTrackerCTA,
                                                 highlightAddressBar: false,
                                                 pixelName: .daxDialogsWithTrackersUnique, type: .withOneTracker)

        static let withMultipleTrackers = BrowsingSpec(message: UserText.Onboarding.ContextualOnboarding.daxDialogBrowsingWithMultipleTrackers,
                                                      cta: UserText.daxDialogBrowsingWithMultipleTrackersCTA,
                                                      highlightAddressBar: false,
                                                      pixelName: .daxDialogsWithTrackersUnique, type: .withMultipleTrackers)

        // Message and CTA empty on purpose as for this case we use only pixelName and type
        static let fire = BrowsingSpec(message: "", cta: "", highlightAddressBar: false, pixelName: .daxDialogsFireEducationShownUnique, type: .fire)

        static let final = BrowsingSpec(message: UserText.daxDialogHomeSubsequent, cta: "", highlightAddressBar: false, pixelName: .daxDialogsEndOfJourneyTabUnique, type: .final)

        let message: String
        let cta: String
        fileprivate(set) var highlightAddressBar: Bool
        let pixelName: Pixel.Event
        let type: SpecType
        
        func format(args: CVarArg...) -> BrowsingSpec {
            format(message: message, args: args)
        }

        func format(message: String, args: CVarArg...) -> BrowsingSpec {
            withUpdatedMessage(String(format: message, arguments: args))
        }

        func withUpdatedMessage(_ message: String) -> BrowsingSpec {
            BrowsingSpec(
                message: message,
                cta: cta,
                highlightAddressBar: highlightAddressBar,
                pixelName: pixelName,
                type: type
            )
        }
    }
    
    struct ActionSheetSpec: Equatable {
        static let fireButtonEducation = ActionSheetSpec(message: UserText.daxDialogFireButtonEducation,
                                                         confirmAction: UserText.daxDialogFireButtonEducationConfirmAction,
                                                         cancelAction: UserText.daxDialogFireButtonEducationCancelAction,
                                                         isConfirmActionDestructive: true,
                                                         displayedPixelName: .daxDialogsFireEducationShownUnique,
                                                         confirmActionPixelName: .daxDialogsFireEducationConfirmedUnique,
                                                         cancelActionPixelName: .daxDialogsFireEducationCancelledUnique)

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
    private let addToDockManager: OnboardingAddToDockManaging

    private var nextHomeScreenMessageOverride: HomeScreenSpec?
    
    // So we can avoid showing two dialogs for the same page
    private var lastURLDaxDialogReturnedFor: URL?

    private var currentHomeSpec: HomeScreenSpec?

    /// Use singleton accessor, this is only accessible for tests
    init(settings: DaxDialogsSettings = DefaultDaxDialogsSettings(),
         entityProviding: EntityProviding,
         variantManager: VariantManager = DefaultVariantManager(),
         onboardingManager: OnboardingAddToDockManaging = OnboardingManager()
    ) {
        self.settings = settings
        self.entityProviding = entityProviding
        self.variantManager = variantManager
        self.addToDockManager = onboardingManager
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
        settings.fireMessageExperimentShown &&
        firstBrowsingMessageSeen
    }

    private var shouldDisplayFinalContextualBrowsingDialog: Bool {
        !finalDaxDialogSeen &&
        visitedSiteAndFireButtonSeen
    }

    var isShowingSearchSuggestions: Bool {
        return currentHomeSpec == .initial
    }

    var isShowingSitesSuggestions: Bool {
        return lastShownDaxDialogType.flatMap(BrowsingSpec.SpecType.init(rawValue:)) == .visitWebsite || currentHomeSpec == .subsequent
    }

    var isShowingAddToDockDialog: Bool {
        return currentHomeSpec == .final && addToDockManager.addToDockEnabledState == .contextual
    }

    var isEnabled: Bool {
        // skip dax dialogs in integration tests
        guard ProcessInfo.processInfo.environment["DAXDIALOGS"] != "false" else { return false }
        return !settings.isDismissed
    }

    var isShowingFireDialog: Bool {
        guard let lastShownDaxDialogType else { return false }
        return BrowsingSpec.SpecType(rawValue: lastShownDaxDialogType) == .fire
    }

    var isAddFavoriteFlow: Bool {
        return nextHomeScreenMessageOverride == .addFavorite
    }
    
    var shouldShowFireButtonPulse: Bool {
        // Show fire the user hasn't seen the fire education dialog or the fire button has not animated before.
        nonDDGBrowsingMessageSeen && (!settings.fireMessageExperimentShown && settings.fireButtonPulseDateShown == nil) && isEnabled
    }

    var shouldShowPrivacyButtonPulse: Bool {
        return settings.browsingWithTrackersShown && !settings.privacyButtonPulseShown && fireButtonPulseTimer == nil && isEnabled
    }

    func isStillOnboarding() -> Bool {
        if peekNextHomeScreenMessageExperiment() != nil {
            return true
        }
        return false
    }

    func dismiss() {
        settings.isDismissed = true
        // Reset last shown dialog as we don't have to show it anymore.
        clearOnboardingBrowsingData()
    }
    
    func primeForUse() {
        settings.isDismissed = false
    }

    func enableAddFavoriteFlow() {
        nextHomeScreenMessageOverride = .addFavorite
    }

    func resumeRegularFlow() {
        nextHomeScreenMessageOverride = nil
    }
    
    func clearHeldURLData() {
        lastURLDaxDialogReturnedFor = nil
    }
    
    private var fireButtonPulseTimer: Timer?
    private static let timeToFireButtonExpire: TimeInterval = 1 * 60 * 60
    
    private var lastVisitedOnboardingWebsiteURLPath: String? {
        return settings.lastVisitedOnboardingWebsiteURLPath
    }

    private func saveLastVisitedOnboardingWebsite(url: URL?) {
        guard let url = url else { return }
        settings.lastVisitedOnboardingWebsiteURLPath = url.absoluteString
    }

    private func removeLastVisitedOnboardingWebsite() {
        settings.lastVisitedOnboardingWebsiteURLPath = nil
    }

    private var lastShownDaxDialogType: String? {
        return settings.lastShownContextualOnboardingDialogType
    }

    private var shouldShowNetworkTrackerDialog: Bool {
        !settings.browsingMajorTrackingSiteShown && !settings.browsingWithTrackersShown
    }

    private func saveLastShownDaxDialog(specType: BrowsingSpec.SpecType) {
        settings.lastShownContextualOnboardingDialogType = specType.rawValue
    }

    private func removeLastShownDaxDialog() {
        settings.lastShownContextualOnboardingDialogType = nil
    }

    private func lastShownDaxDialog(privacyInfo: PrivacyInfo) -> BrowsingSpec? {
        guard let dialogType = lastShownDaxDialogType else { return  nil }
        switch dialogType {
        case BrowsingSpec.SpecType.afterSearch.rawValue:
            return BrowsingSpec.afterSearch
        case BrowsingSpec.SpecType.visitWebsite.rawValue:
            return .visitWebsite
        case BrowsingSpec.SpecType.withoutTrackers.rawValue:
            return BrowsingSpec.withoutTrackers
        case BrowsingSpec.SpecType.siteIsMajorTracker.rawValue:
            guard let host = privacyInfo.domain else { return nil }
            return majorTrackerMessage(host, isReloadingDialog: true)
        case BrowsingSpec.SpecType.siteOwnedByMajorTracker.rawValue:
            guard let host = privacyInfo.domain, let owner = isOwnedByFacebookOrGoogle(host) else { return nil }
            return majorTrackerOwnerMessage(host, owner, isReloadingDialog: true)
        case BrowsingSpec.SpecType.withOneTracker.rawValue, BrowsingSpec.SpecType.withMultipleTrackers.rawValue:
            guard let entityNames = blockedEntityNames(privacyInfo.trackerInfo) else { return nil }
            return trackersBlockedMessage(entityNames, isReloadingDialog: true)
        case BrowsingSpec.SpecType.fire.rawValue:
            return .fire
        case BrowsingSpec.SpecType.final.rawValue:
            return nil
        default: return nil
        }
    }

    func fireButtonPulseStarted() {
        ViewHighlighter.dismissPrivacyIconPulseAnimation()
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

    func setSearchMessageSeen() {
        saveLastShownDaxDialog(specType: .visitWebsite)
    }

    func setFireEducationMessageSeen() {
        // Set also privacy button pulse seen as we don't have to show anymore if we saw the fire educational message.
        settings.privacyButtonPulseShown = true
        settings.fireMessageExperimentShown = true
        saveLastShownDaxDialog(specType: .fire)
    }

    func clearedBrowserData() {
        setDaxDialogDismiss()
    }

    func setPrivacyButtonPulseSeen() {
        settings.privacyButtonPulseShown = true
    }

    func setDaxDialogDismiss() {
        clearOnboardingBrowsingData()
    }

    func setFinalOnboardingDialogSeen() {
        settings.browsingFinalDialogShown = true
    }

    func nextBrowsingMessageIfShouldShow(for privacyInfo: PrivacyInfo) -> BrowsingSpec? {

        let message = nextBrowsingMessageExperiment(privacyInfo: privacyInfo)
        if message != nil {
            lastURLDaxDialogReturnedFor = privacyInfo.url
        }
        
        return message
    }

    private func nextBrowsingMessageExperiment(privacyInfo: PrivacyInfo) -> BrowsingSpec? {

        func hasTrackers(host: String) -> Bool {
            isFacebookOrGoogle(privacyInfo.url) || isOwnedByFacebookOrGoogle(host) != nil || blockedEntityNames(privacyInfo.trackerInfo) != nil
        }

        // Reset current home spec when navigating
        currentHomeSpec = nil

        guard isEnabled, nextHomeScreenMessageOverride == nil else { return nil }

        if let lastVisitedOnboardingWebsiteURLPath,
            compareUrls(url1: URL(string: lastVisitedOnboardingWebsiteURLPath), url2: privacyInfo.url) {
            return lastShownDaxDialog(privacyInfo: privacyInfo)
        }

        guard let host = privacyInfo.domain else { return nil }

        var spec: BrowsingSpec?

        if privacyInfo.url.isDuckDuckGoSearch && !settings.browsingAfterSearchShown {
            spec = searchMessage()
        } else if isFacebookOrGoogle(privacyInfo.url) && shouldShowNetworkTrackerDialog {
            // won't be shown if owned by major tracker message has already been shown
            spec = majorTrackerMessage(host, isReloadingDialog: false)
        } else if let owner = isOwnedByFacebookOrGoogle(host), shouldShowNetworkTrackerDialog {
            // won't be shown if major tracker message has already been shown
            spec = majorTrackerOwnerMessage(host, owner, isReloadingDialog: false)
        } else if let entityNames = blockedEntityNames(privacyInfo.trackerInfo), !settings.browsingWithTrackersShown {
            spec = trackersBlockedMessage(entityNames, isReloadingDialog: false)
        } else if !settings.browsingWithoutTrackersShown && !privacyInfo.url.isDuckDuckGoSearch && !hasTrackers(host: host) {
            // if non duck duck go search and no trackers found and no tracker message already shown, show no trackers message
            spec = noTrackersMessage()
        } else if shouldDisplayFinalContextualBrowsingDialog {
            // If the user visited a website and saw the fire dialog
            spec = finalMessage()
        }

        if let spec {
            saveLastShownDaxDialog(specType: spec.type)
            saveLastVisitedOnboardingWebsite(url: privacyInfo.url)
        } else {
            clearOnboardingBrowsingData()
        }

        return spec
    }

    func nextHomeScreenMessageNew() -> HomeScreenSpec? {
        // Reset the last browsing information when opening a new tab so loading the previous website won't show again the Dax dialog
        clearedBrowserData()

        guard let homeScreenSpec = peekNextHomeScreenMessageExperiment() else {
            currentHomeSpec = nil
            return nil
        }
        currentHomeSpec = homeScreenSpec
        return homeScreenSpec
    }

    private func peekNextHomeScreenMessageExperiment() -> HomeScreenSpec? {
        if nextHomeScreenMessageOverride != nil {
            return nextHomeScreenMessageOverride
        }

        guard isEnabled else { return nil }

        // If the user has already seen the end of journey dialog we don't want to show any other NTP Dax dialog.
        guard !finalDaxDialogSeen else { return nil }

        // Check final first as if we skip anonymous searches we don't want to show this.
        if settings.fireMessageExperimentShown {
            return .final
        }

        if !settings.browsingAfterSearchShown {
            return .initial
        }

        if firstSearchSeenButNoSiteVisited {
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

    func majorTrackerOwnerMessage(_ host: String, _ majorTrackerEntity: Entity, isReloadingDialog: Bool) -> DaxDialogs.BrowsingSpec? {
        if !isReloadingDialog && settings.browsingMajorTrackingSiteShown { return nil }
        
        guard let entityName = majorTrackerEntity.displayName,
            let entityPrevalence = majorTrackerEntity.prevalence else { return nil }
        settings.browsingMajorTrackingSiteShown = true
        settings.browsingWithoutTrackersShown = true
        return BrowsingSpec.siteOwnedByMajorTracker.format(args: host.droppingWwwPrefix(),
                                                           entityName,
                                                           entityPrevalence)
    }
    
    private func majorTrackerMessage(_ host: String, isReloadingDialog: Bool) -> DaxDialogs.BrowsingSpec? {
        if !isReloadingDialog && settings.browsingMajorTrackingSiteShown { return nil }

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

    private func finalMessage() -> BrowsingSpec? {
        guard !finalDaxDialogSeen else { return nil }
        return BrowsingSpec.final
    }

    private func trackersBlockedMessage(_ entitiesBlocked: [String], isReloadingDialog: Bool) -> BrowsingSpec? {
        if !isReloadingDialog && settings.browsingWithTrackersShown { return nil }

        var spec: BrowsingSpec?
        switch entitiesBlocked.count {

        case 0:
            spec = nil

        case 1:
            settings.browsingWithTrackersShown = true
            let args = entitiesBlocked[0]
            spec = BrowsingSpec.withOneTracker.format(message: UserText.Onboarding.ContextualOnboarding.daxDialogBrowsingWithOneTracker, args: args)

        default:
            settings.browsingWithTrackersShown = true
            let args: [CVarArg] = [entitiesBlocked.count - 2, entitiesBlocked[0], entitiesBlocked[1]]
            spec = BrowsingSpec.withMultipleTrackers.format(message: UserText.Onboarding.ContextualOnboarding.daxDialogBrowsingWithMultipleTrackers, args: args)
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

    private func compareUrls(url1: URL?, url2: URL?) -> Bool {
        guard let url1, let url2 else { return false }

        if url1 == url2 {
            return true
        }

        return url1.isSameDuckDuckGoSearchURL(other: url2)
    }

    private func clearOnboardingBrowsingData() {
        removeLastShownDaxDialog()
        removeLastVisitedOnboardingWebsite()
        currentHomeSpec = nil
    }
}

extension URL {

    func isSameDuckDuckGoSearchURL(other: URL?) -> Bool {
        guard let other else { return false }

        guard isDuckDuckGoSearch && other.isDuckDuckGoSearch else { return false }

        // Extract 'q' parameter from both URLs
        let queryValue1 = URLComponents(url: self, resolvingAgainstBaseURL: false)?.queryItems?.first(where: { $0.name == "q" })?.value
        let queryValue2 = URLComponents(url: other, resolvingAgainstBaseURL: false)?.queryItems?.first(where: { $0.name == "q" })?.value

        let normalizedQuery1 = queryValue1?
            .replacingOccurrences(of: "+", with: " ")
            .replacingOccurrences(of: "%20", with: " ")
        let normalizedQuery2 = queryValue2?
            .replacingOccurrences(of: "+", with: " ")
            .replacingOccurrences(of: "%20", with: " ")
        
        return normalizedQuery1 == normalizedQuery2
    }
}

private extension ViewHighlighter {

    static func dismissPrivacyIconPulseAnimation() {
        guard ViewHighlighter.highlightedViews.contains(where: { $0.view is PrivacyIconView }) else { return }
        ViewHighlighter.hideAll()
    }

}
