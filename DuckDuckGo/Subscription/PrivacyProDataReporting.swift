//
//  PrivacyProDataReporting.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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
import BrowserServicesKit
import DDGSync

/// The additional parameters being collected only apply to a single promotion about a DuckDuckGo product.
/// The parameters are temporary, collected in aggregate, and anonymous.
enum PrivacyProPromoParameters: String, CaseIterable {
    case isReinstall
    case fireButtonUser = "fireButtonUsed"
    case syncUsed
    case fireproofingUsed
    case appOnboardingCompleted
    case emailEnabled
    case widgetAdded
    case frequentUser
    case longTermUser
    case autofillUser
    case validOpenTabsCount
    case searchUser

    /// Pick a randomized subset of parameters each time they are attached to a pixel
    static func randomizedSubset(excluding excludedParameters: [PrivacyProPromoParameters] = []) -> [PrivacyProPromoParameters] {
        let allParameters = Set(allCases).subtracting(Set(excludedParameters))
        return Array(allParameters.shuffled().prefix(Int(allCases.count * 2/3)))
    }
}

enum PrivacyProDataReportingUseCase {
    case messageID(String)
    case origin(String?)
    case debug
}

protocol PrivacyProDataReporting {
    func isReinstall() -> Bool
    func isFireButtonUser() -> Bool
    func isSyncUsed() -> Bool
    func isFireproofingUsed() -> Bool
    func isAppOnboardingCompleted() -> Bool
    func isEmailEnabled() -> Bool
    func isWidgetAdded() -> Bool
    func isFrequentUser() -> Bool
    func isLongTermUser() -> Bool
    func isAutofillUser() -> Bool
    func isValidOpenTabsCount() -> Bool
    func isSearchUser() -> Bool

    func injectSyncService(_ service: DDGSync)
    func injectTabsModel(_ model: TabsModel)
    func saveFireCount()
    func saveWidgetAdded() async
    func saveApplicationLastSessionEnded()
    func saveSearchCount()

    func randomizedParameters(for useCase: PrivacyProDataReportingUseCase) -> [String: String]
    func mergeRandomizedParameters(for useCase: PrivacyProDataReportingUseCase, with parameters: [String: String]) -> [String: String]
}

// swiftlint:disable identifier_name
final class PrivacyProDataReporter: PrivacyProDataReporting {
    enum Key {
        static let fireCountKey = "com.duckduckgo.ios.privacypropromo.FireCount"
        static let isWidgetAddedKey = "com.duckduckgo.ios.privacypropromo.WidgetAdded"
        static let applicationLastSessionEndedKey = "com.duckduckgo.ios.privacypropromo.ApplicationLastSessionEnded"
        static let searchCountKey = "com.duckduckgo.ios.privacypropromo.SearchCount"
    }

    enum Constants {
        static let includedOrigins = "origins"
    }

    private static let fireCountThreshold = 5
    private static let frequentUserThreshold = 2
    private static let longTermUserThreshold = 30
    private static let autofillUserThreshold = 10
    private static let openTabsCountThreshold = 3
    private static let searchCountThreshold = 50

    private lazy var includedOrigins = configurationManager
        .privacyConfig
        .settings(for: .additionalCampaignPixelParams)[Constants.includedOrigins] as? [String]

    private let configurationManager: PrivacyConfigurationManaging
    private let variantManager: VariantManager
    private let userDefaults: UserDefaults
    private let emailManager: EmailManager
    private let tutorialSettings: TutorialSettings
    private let appSettings: AppSettings
    private let statisticsStore: StatisticsStore
    private let featureFlagger: FeatureFlagger
    private let autofillCheck: () -> Bool
    private let secureVaultMaker: () -> (any AutofillSecureVault)?
    private var syncService: DDGSyncing?
    private var tabsModel: TabsModel?
    private let fireproofing: Fireproofing
    private let dateGenerator: () -> Date

    private var secureVault: (any AutofillSecureVault)?

    init(configurationManager: PrivacyConfigurationManaging = ContentBlocking.shared.privacyConfigurationManager,
         variantManager: VariantManager = DefaultVariantManager(),
         userDefaults: UserDefaults = .app,
         emailManager: EmailManager = EmailManager(),
         tutorialSettings: TutorialSettings = DefaultTutorialSettings(),
         appSettings: AppSettings = AppDependencyProvider.shared.appSettings,
         statisticsStore: StatisticsStore = StatisticsUserDefaults(),
         featureFlagger: FeatureFlagger = AppDependencyProvider.shared.featureFlagger,
         autofillCheck: @escaping () -> Bool = { AutofillSettingStatus.isAutofillEnabledInSettings },
         secureVaultMaker: @escaping () -> (any AutofillSecureVault)? = { try? AutofillSecureVaultFactory.makeVault(reporter: SecureVaultReporter()) },
         syncService: DDGSyncing? = nil,
         tabsModel: TabsModel? = nil,
         fireproofing: Fireproofing,
         dateGenerator: @escaping () -> Date = Date.init) {
        self.configurationManager = configurationManager
        self.variantManager = variantManager
        self.userDefaults = userDefaults
        self.emailManager = emailManager
        self.tutorialSettings = tutorialSettings
        self.appSettings = appSettings
        self.statisticsStore = statisticsStore
        self.featureFlagger = featureFlagger
        self.autofillCheck = autofillCheck
        self.secureVaultMaker = secureVaultMaker
        self.syncService = syncService
        self.tabsModel = tabsModel
        self.fireproofing = fireproofing
        self.dateGenerator = dateGenerator
    }

    func injectSyncService(_ service: DDGSync) {
        syncService = service
    }

    func injectTabsModel(_ model: TabsModel) {
        tabsModel = model
    }

    /// Collect a randomized subset of parameters iff the Privacy Pro impression/conversion pixels
    /// or the Origin Attribution subscription pixel are being fired
    func randomizedParameters(for useCase: PrivacyProDataReportingUseCase) -> [String: String] {
        switch useCase {
        case .messageID(let messageID):
            guard let includedOrigins, includedOrigins.contains(messageID) else { return [:] }
        case .origin(let origin):
            guard let includedOrigins, let origin, includedOrigins.contains(origin) else { return [:] }
        case .debug:
            break
        }

        var additionalParameters = [String: String]()

        /// Exclude certain parameters in case the dependencies aren't ready by the time the pixel is fired
        var excludedParameters = [PrivacyProPromoParameters]()
        if syncService == nil {
            excludedParameters.append(.syncUsed)
        }
        if tabsModel == nil {
            excludedParameters.append(.validOpenTabsCount)
        }

        let randomizedParameters = PrivacyProPromoParameters.randomizedSubset(excluding: excludedParameters)
        for parameter in randomizedParameters {
            let value: Bool
            switch parameter {
            case .isReinstall: value = isReinstall()
            case .fireButtonUser: value = isFireButtonUser()
            case .syncUsed: value = isSyncUsed()
            case .fireproofingUsed: value = isFireproofingUsed()
            case .appOnboardingCompleted: value = isAppOnboardingCompleted()
            case .emailEnabled: value = isEmailEnabled()
            case .widgetAdded: value = isWidgetAdded()
            case .frequentUser: value = isFrequentUser()
            case .longTermUser: value = isLongTermUser()
            case .autofillUser: value = isAutofillUser()
            case .validOpenTabsCount: value = isValidOpenTabsCount()
            case .searchUser: value = isSearchUser()
            }
            additionalParameters[parameter.rawValue] = String(value)
        }

        return additionalParameters
    }

    func mergeRandomizedParameters(for useCase: PrivacyProDataReportingUseCase,
                                   with parameters: [String: String]) -> [String: String] {
        randomizedParameters(for: useCase).merging(parameters) { $1 }
    }

    func isReinstall() -> Bool {
        _variantName == VariantIOS.returningUser.name
    }

    func isFireButtonUser() -> Bool {
        _fireCount > Self.fireCountThreshold
    }

    func isSyncUsed() -> Bool {
        _syncAuthState != .inactive
    }

    func isFireproofingUsed() -> Bool {
        _fireproofedDomainsCount > 0
    }

    func isAppOnboardingCompleted() -> Bool {
        tutorialSettings.hasSeenOnboarding
    }

    func isEmailEnabled() -> Bool {
        emailManager.isSignedIn
    }

    func isWidgetAdded() -> Bool {
        userDefaults.bool(forKey: Key.isWidgetAddedKey, defaultValue: false)
    }

    func isFrequentUser() -> Bool {
        let now = dateGenerator()
        guard let _lastSessionEnded,
              let daysSinceLastSession = Calendar.current.numberOfDaysBetween(_lastSessionEnded, and: now) else {
            return false
        }
        return daysSinceLastSession < Self.frequentUserThreshold
    }

    func isLongTermUser() -> Bool {
        guard let _installDate,
              let daysSinceInstall = Calendar.current.numberOfDaysBetween(_installDate, and: dateGenerator()) else {
            return false
        }
        return daysSinceInstall > Self.longTermUserThreshold
    }

    func isAutofillUser() -> Bool {
        _accountsCount > Self.autofillUserThreshold
    }

    func isValidOpenTabsCount() -> Bool {
         _tabsCount > Self.openTabsCountThreshold
    }

    func isSearchUser() -> Bool {
        _searchCount > Self.searchCountThreshold
    }

    func saveWidgetAdded() async {
        let isInstalled = await appSettings.isWidgetInstalled()
        if isInstalled != isWidgetAdded() {
            userDefaults.set(isInstalled, forKey: Key.isWidgetAddedKey)
        }
    }

    func saveApplicationLastSessionEnded() {
        userDefaults.set(dateGenerator(), forKey: Key.applicationLastSessionEndedKey)
    }
    
    func saveFireCount() {
        userDefaults.set(_fireCount + 1, forKey: Key.fireCountKey)
    }

    func saveSearchCount() {
        userDefaults.set(_searchCount + 1, forKey: Key.searchCountKey)
    }

    var _syncAuthState: SyncAuthState {
        guard let syncService else {
            preconditionFailure("syncService must be non-nil")
        }
        return syncService.authState
    }

    var _variantName: String? {
        variantManager.currentVariant?.name
    }

    var _fireCount: Int {
        userDefaults.object(forKey: Key.fireCountKey) as? Int ?? 0
    }

    var _fireproofedDomainsCount: Int {
        fireproofing.allowedDomains.count
    }

    var _lastSessionEnded: Date? {
        userDefaults.object(forKey: Key.applicationLastSessionEndedKey) as? Date ?? nil
    }

    var _installDate: Date? {
        statisticsStore.installDate
    }

    var _accountsCount: Int {
        if featureFlagger.isFeatureOn(.autofillCredentialInjecting) && autofillCheck() {
            if secureVault == nil {
                secureVault = secureVaultMaker()
            }
            return (try? secureVault?.accountsCount()) ?? 0
        }
        return 0
    }

    var _tabsCount: Int {
        guard let tabsModel else {
            preconditionFailure("tabsModel must be non-nil")
        }

        return tabsModel.count
    }

    var _searchCount: Int {
        userDefaults.object(forKey: Key.searchCountKey) as? Int ?? 0
    }
}
// swiftlint:enable identifier_name
