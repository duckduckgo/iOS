//
//  PrivacyProDataReporter.swift
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

enum PrivacyProPromoParameters: String, CaseIterable {
    case isReinstall = "isReinstall"
    case fireButtonUser = "fireButtonUsed"
    case syncUsed = "syncUsed"
    case fireproofingUsed = "fireproofingUsed"
    case appOnboardingCompleted = "appOnboardingCompleted"
    case emailEnabled = "emailEnabled"
    case widgetAdded = "widgetAdded"
    case frequentUser = "frequentUser"
    case longTermUser = "longTermUser"
    case autofillUser = "autofillUser"
    case validOpenTabsCount = "validOpenTabsCount"
    case searchUser = "searchUser"

    static func randomizedSubset() -> [PrivacyProPromoParameters] {
        Array(allCases.shuffled().prefix(4))
    }
}

protocol PrivacyProDataReporting {
    func isReinstall() -> Bool
    func isFireButtonUser() -> Bool
    func isSyncUsed() -> Bool
    func isFireproofingUsed() -> Bool
    func isAppOnboardingCompleted() -> Bool
    func isEmailEnabled() -> Bool
    func isWidgetAdded() async -> Bool
    func isFrequentUser() -> Bool
    func isLongTermUser() -> Bool
    func isAutofillUser() -> Bool
    func isValidOpenTabsCount() -> Bool
    func isSearchUser() -> Bool
}

final class DefaultPrivacyProDataReporter: PrivacyProDataReporting {
    enum Key {
        static let fireCountKey = "com.duckduckgo.ios.privacypropromo.FireCount"
        static let isFireproofingUsedKey = "com.duckduckgo.ios.privacypropromo.FireproofingUsed"
        static let applicationLastActiveDateKey = "com.duckduckgo.ios.privacypropromo.ApplicationLastActiveDate"
        static let searchCountKey = "com.duckduckgo.ios.privacypropromo.SearchCount"
    }

    enum UseCase {
        case messageID(String)
        case origin(String?)
    }

    public static let shared = DefaultPrivacyProDataReporter()

    public static let eligibleMessageIDs: [String] = []
    public static let eligibleOrigins: [String] = []

    private static let fireCountThreshold = 5
    private static let frequentUserThreshold = 2
    private static let longTermUserThreshold = 30
    private static let autofillUserThreshold = 5
    private static let openTabsCountThreshold = 3
    private static let searchCountThreshold = 50

    private let variantManager: VariantManager
    private let userDefaults: UserDefaults
    private let emailManager: EmailManager
    private let tutorialSettings: TutorialSettings
    private let appSettings: AppSettings
    private let statisticsStore: StatisticsStore
    private let secureVault: (any AutofillSecureVault)?
    private var syncService: DDGSyncing?
    private let dateGenerator: () -> Date

    init(variantManager: VariantManager = DefaultVariantManager(),
         userDefaults: UserDefaults = .app,
         emailManager: EmailManager = EmailManager(),
         tutorialSettings: TutorialSettings = DefaultTutorialSettings(),
         appSettings: AppSettings = AppDependencyProvider.shared.appSettings,
         statisticsStore: StatisticsStore = StatisticsUserDefaults(),
         secureVault: (any AutofillSecureVault)? = try? AutofillSecureVaultFactory.makeVault(reporter: SecureVaultReporter()),
         syncService: DDGSyncing? = nil,
         dateGenerator: @escaping () -> Date = Date.init) {
        self.variantManager = variantManager
        self.userDefaults = userDefaults
        self.emailManager = emailManager
        self.tutorialSettings = tutorialSettings
        self.appSettings = appSettings
        self.statisticsStore = statisticsStore
        self.secureVault = secureVault
        self.syncService = syncService
        self.dateGenerator = dateGenerator
    }

    func injectSyncService(_ service: DDGSync) {
        syncService = service
    }

    func additionalParameters(for useCase: UseCase) async -> [String: String] {
        switch useCase {
        case .messageID(let messageID):
            guard Self.eligibleMessageIDs.contains(messageID) else { return [:] }
        case .origin(let origin):
            guard let origin, Self.eligibleOrigins.contains(origin) else { return [:] }
        }

        var additionalParameters = [String: String]()

        let randomizedParameters = PrivacyProPromoParameters.randomizedSubset()
        for parameter in randomizedParameters {
            let value: Bool
            switch parameter {
            case .isReinstall: value = isReinstall()
            case .fireButtonUser: value = isFireButtonUser()
            case .syncUsed: value = isSyncUsed()
            case .fireproofingUsed: value = isFireproofingUsed()
            case .appOnboardingCompleted: value = isAppOnboardingCompleted()
            case .emailEnabled: value = isEmailEnabled()
            case .widgetAdded: value = await isWidgetAdded()
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

    // MARK: - Additional parameters

    func isReinstall() -> Bool {
        variantManager.currentVariant?.name == VariantIOS.returningUser.name
    }

    func isFireButtonUser() -> Bool {
        fireCount > Self.fireCountThreshold
    }

    func isSyncUsed() -> Bool {
        guard let syncService else {
            preconditionFailure("syncService must be non-nil")
        }
        return syncService.authState != .inactive
    }

    func isFireproofingUsed() -> Bool {
        userDefaults.bool(forKey: Key.isFireproofingUsedKey, defaultValue: false)
    }

    func isAppOnboardingCompleted() -> Bool {
        tutorialSettings.hasSeenOnboarding
    }

    func isEmailEnabled() -> Bool {
        emailManager.isSignedIn
    }

    func isWidgetAdded() async -> Bool {
        await appSettings.isWidgetInstalled()
    }

    func isFrequentUser() -> Bool {
        guard let lastActiveDate,
              let daysSinceLastActive = Calendar.current.numberOfDaysBetween(lastActiveDate, and: dateGenerator()) else {
            return false
        }
        return daysSinceLastActive < Self.frequentUserThreshold
    }

    func isLongTermUser() -> Bool {
        guard let installDate = statisticsStore.installDate,
              let daysSinceInstall = Calendar.current.numberOfDaysBetween(installDate, and: dateGenerator()) else {
            return false
        }
        return daysSinceInstall > Self.longTermUserThreshold
    }

    func isAutofillUser() -> Bool {
        guard let accounts = try? secureVault?.accounts() else { return false }
        return accounts.count > Self.autofillUserThreshold
    }

    func isValidOpenTabsCount() -> Bool {
        guard let tabsCount = TabsModel.get()?.count else { return false }
        return tabsCount > Self.openTabsCountThreshold
    }

    func isSearchUser() -> Bool {
        searchCount > Self.searchCountThreshold
    }

    func saveFireproofingUsed() {
        guard isFireproofingUsed() else { return }
        userDefaults.set(true, forKey: Key.isFireproofingUsedKey)
    }

    func saveApplicationLastActiveDate() {
        userDefaults.set(dateGenerator(), forKey: Key.applicationLastActiveDateKey)
    }
    
    func saveFireCount() {
        userDefaults.set(fireCount + 1, forKey: Key.fireCountKey)
    }

    func saveSearchCount() {
        userDefaults.set(searchCount + 1, forKey: Key.searchCountKey)
    }

    // MARK: - Private

    private var fireCount: Int {
        userDefaults.object(forKey: Key.fireCountKey) as? Int ?? 0
    }

    private var lastActiveDate: Date? {
        userDefaults.object(forKey: Key.applicationLastActiveDateKey) as? Date ?? nil
    }

    private var searchCount: Int {
        userDefaults.object(forKey: Key.searchCountKey) as? Int ?? 0
    }
}
