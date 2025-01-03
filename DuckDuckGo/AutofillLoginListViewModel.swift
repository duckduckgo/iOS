//
//  AutofillLoginListViewModel.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
import BrowserServicesKit
import Common
import UIKit
import Combine
import Core
import DDGSync
import PrivacyDashboard
import os.log

internal enum EnableAutofillRows: Int, CaseIterable {
    case toggleAutofill
    case resetNeverPromptWebsites
}

final class AutofillLoginListViewModel: ObservableObject {
    
    enum ViewState {
        case authLocked
        case noAuthAvailable
        case empty
        case showItems
        case searching
        case searchingNoResults
    }

    struct UserInfoKeys {
        static let tabUid = "com.duckduckgo.autofill.tab-uid"
    }

    let authenticator = AutofillLoginListAuthenticator(reason: UserText.autofillLoginListAuthenticationReason,
                                                       cancelTitle: UserText.autofillLoginListAuthenticationCancelButton)
    var isSearching: Bool = false
    var isEditing: Bool = false {
        didSet {
            sections = makeSections(with: accounts)
        }
    }
    var authenticationNotRequired = false
    var isCancelingSearch = false
    var isAuthenticating = false

    @Published private var accounts = [SecureVaultModels.WebsiteAccount]()
    private var accountsToSuggest = [SecureVaultModels.WebsiteAccount]()
    private var cancellables: Set<AnyCancellable> = []
    private var appSettings: AppSettings
    private let tld: TLD
    private var currentTabUrl: URL?
    private var currentTabUid: String?
    private let secureVault: (any AutofillSecureVault)?
    private let autofillNeverPromptWebsitesManager: AutofillNeverPromptWebsitesManager
    private let privacyConfig: PrivacyConfiguration
    private let keyValueStore: KeyValueStoringDictionaryRepresentable
    private var cachedDeletedCredentials: SecureVaultModels.WebsiteCredentials?
    private let autofillDomainNameUrlMatcher = AutofillDomainNameUrlMatcher()
    private let autofillDomainNameUrlSort = AutofillDomainNameUrlSort()
    private let syncService: DDGSyncing
    private let locale: Locale
    private var showBreakageReporter: Bool = false

    private lazy var reporterDateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()

    private lazy var breakageReportIntervalDays = {
        let settings = privacyConfig.settings(for: .autofillBreakageReporter)
        return settings["monitorIntervalDays"] as? Int ?? 42
    }()

    private lazy var credentialIdentityStoreManager: AutofillCredentialIdentityStoreManaging = AutofillCredentialIdentityStoreManager(vault: secureVault,
                                                                                                                                      reporter: SecureVaultReporter(),
                                                                                                                                      tld: tld)

    private lazy var syncPromoManager: SyncPromoManaging = SyncPromoManager(syncService: syncService)

    private lazy var autofillSurveyManager: AutofillSurveyManaging = AutofillSurveyManager()

    internal lazy var breakageReporter = BrokenSiteReporter(pixelHandler: { [weak self] _ in
        if let currentTabUid = self?.currentTabUid {
            NotificationCenter.default.post(name: .autofillFailureReport, object: self, userInfo: [UserInfoKeys.tabUid: currentTabUid])
        }
        self?.updateData()
        self?.showBreakageReporter = false
    }, keyValueStoring: keyValueStore, storageConfiguration: .autofillConfig)

    @Published private(set) var viewState: AutofillLoginListViewModel.ViewState = .authLocked
    @Published private(set) var sections = [AutofillLoginListSectionType]() {
        didSet {
            updateViewState()
        }
    }

    var hasAccountsSaved: Bool {
        return !accounts.isEmpty
    }

    var accountsCount: Int {
        accounts.count
    }

    var accountsCountPublisher: AnyPublisher<Int, Never> {
        $accounts
            .map { $0.count }
            .eraseToAnyPublisher()
    }
    
    var isAutofillEnabledInSettings: Bool {
        get { appSettings.autofillCredentialsEnabled }
        set {
            appSettings.autofillCredentialsEnabled = newValue
            keyValueStore.set(false, forKey: UserDefaultsWrapper<Bool>.Key.autofillFirstTimeUser.rawValue)
            NotificationCenter.default.post(name: AppUserDefaults.Notifications.autofillEnabledChange, object: self)
        }
    }

    init(appSettings: AppSettings,
         tld: TLD,
         secureVault: (any AutofillSecureVault)?,
         currentTabUrl: URL? = nil,
         currentTabUid: String? = nil,
         autofillNeverPromptWebsitesManager: AutofillNeverPromptWebsitesManager = AppDependencyProvider.shared.autofillNeverPromptWebsitesManager,
         privacyConfig: PrivacyConfiguration = ContentBlocking.shared.privacyConfigurationManager.privacyConfig,
         keyValueStore: KeyValueStoringDictionaryRepresentable = UserDefaults.standard,
         syncService: DDGSyncing,
         locale: Locale = Locale.current) {
        self.appSettings = appSettings
        self.tld = tld
        self.secureVault = secureVault
        self.currentTabUrl = currentTabUrl
        self.currentTabUid = currentTabUid
        self.autofillNeverPromptWebsitesManager = autofillNeverPromptWebsitesManager
        self.privacyConfig = privacyConfig
        self.keyValueStore = keyValueStore
        self.syncService = syncService
        self.locale = locale

        if let count = getAccountsCount() {
            authenticationNotRequired = count == 0 || AppDependencyProvider.shared.autofillLoginSession.isSessionValid
        }
        updateData()
        setupCancellables()

        if showBreakageReporter {
            Pixel.fire(pixel: .autofillLoginsReportAvailable)
        }
    }
    
 // MARK: Public Methods

    func delete(at indexPath: IndexPath) -> Bool {
        let section = sections[indexPath.section]
        switch section {
        case .credentials(_, let items), .suggestions(_, let items):
            let item = items[indexPath.row]
            let success = delete(item.account)
            updateData()
            return success
        default:
            break
        }
        return false
    }
    
    func deleteAllCredentials() -> Bool {
        return deleteAll()
    }

    func undoLastDelete() {
        guard let cachedDeletedCredentials = cachedDeletedCredentials else {
            return
        }
        undelete(cachedDeletedCredentials)
    }
    
    func clearUndoCache() {
        cachedDeletedCredentials = nil
    }

    func clearAllAccounts() {
        accounts = []
        accountsToSuggest = []
        sections = makeSections(with: accounts)
    }

    func undoClearAllAccounts() {
        updateData()
    }

    func lockUI() {
        authenticationNotRequired = !hasAccountsSaved
        authenticator.logOut()
    }
    
    func authenticate(completion: @escaping (AutofillLoginListAuthenticator.AuthError?) -> Void) {
        guard !isAuthenticating else {
            return
        }

        isAuthenticating = true

        if !authenticator.canAuthenticate() {
            viewState = .noAuthAvailable
            completion(nil)
            return
        }

        if viewState != .authLocked {
            completion(nil)
            return
        }
        
        authenticator.authenticate(completion: completion)
    }

    func authenticateInvalidateContext() {
        isAuthenticating = false
        authenticator.invalidateContext()
    }

    func rowsInSection(_ section: Int) -> Int {
        switch self.sections[section] {
        case .enableAutofill:
            return autofillNeverPromptWebsitesManager.neverPromptWebsites.isEmpty ? 1 : 2
        case .suggestions(_, let items):
            if isEditing || !showBreakageReporter {
                return items.count
            } else {
                return items.count + 1
            }
        case .credentials(_, let items):
            return items.count
        }
    }
    
    func updateData() {
        self.accounts = fetchAccounts()
        self.accountsToSuggest = fetchSuggestedAccounts()
        self.sections = makeSections(with: accounts)
        self.showBreakageReporter = shouldShowBreakageReporter()
    }
    
    func filterData(with query: String? = nil) {
        var filteredAccounts = self.accounts
        
        if let query = query, query.count > 0 {
            filteredAccounts = filteredAccounts.filter { account in
                if !account.name(tld: tld, autofillDomainNameUrlMatcher: autofillDomainNameUrlMatcher).lowercased().contains(query.lowercased()) &&
                    !(account.domain ?? "").lowercased().contains(query.lowercased()) &&
                    !(account.username ?? "").lowercased().contains(query.lowercased()) {
                    return false
                }
                return true
            }
        }
        self.sections = makeSections(with: filteredAccounts)
    }

    func resetNeverPromptWebsites() {
        _ = autofillNeverPromptWebsitesManager.deleteAllNeverPromptWebsites()
    }

    func createBreakageReporterAlert() -> UIAlertController? {
        guard let currentTabUrl = currentTabUrl else {
            return nil
        }

        let urlName = tld.eTLDplus1(forStringURL: currentTabUrl.absoluteString) ??
        autofillDomainNameUrlMatcher.normalizeUrlForWeb(currentTabUrl.absoluteString)

        let alert = UIAlertController(title: UserText.autofillSettingsReportNotWorkingConfirmationPromptTitle(for: urlName),
                                      message: UserText.autofillSettingsReportNotWorkingConfirmationPromptMessage,
                                      preferredStyle: .alert)

        let sendReportAction = UIAlertAction(title: UserText.autofillSettingsReportNotWorkingConfirmationPromptButton,
                                             style: .default) {[weak self] _ in
            self?.saveReport(for: currentTabUrl)
            Pixel.fire(pixel: .autofillLoginsReportConfirmationPromptConfirmed)
        }

        alert.addAction(sendReportAction)
        alert.addAction(UIAlertAction(title: UserText.actionCancel, style: .cancel, handler: { _ in
            Pixel.fire(pixel: .autofillLoginsReportConfirmationPromptDismissed)
        }))
        alert.preferredAction = sendReportAction

        return alert
    }

    func shouldShowSyncPromo() -> Bool {
        return viewState == .showItems
               && !isEditing
               && syncPromoManager.shouldPresentPromoFor(.passwords, count: accountsCount)
    }

    func dismissSyncPromo() {
        syncPromoManager.dismissPromoFor(.passwords)
    }

    func getSurveyToPresent() -> AutofillSurveyManager.AutofillSurvey? {
        guard locale.isEnglishLanguage,
              viewState == .showItems || viewState == .empty,
              !isEditing,
              privacyConfig.isEnabled(featureKey: .autofillSurveys) else {
            return nil
        }
        return autofillSurveyManager.surveyToPresent(settings: privacyConfig.settings(for: .autofillSurveys))
    }

    func surveyUrl(survey: String) -> URL? {
        return autofillSurveyManager.buildSurveyUrl(survey, accountsCount: accountsCount)
    }

    func dismissSurvey(id: String) {
        autofillSurveyManager.markSurveyAsCompleted(id: id)
    }

    // MARK: Private Methods

    private func saveReport(for currentTabUrl: URL) {
        let report = BrokenSiteReport(siteUrl: currentTabUrl,
                                      category: "",
                                      description: "",
                                      osVersion: "",
                                      manufacturer: "",
                                      upgradedHttps: false,
                                      tdsETag: nil,
                                      configVersion: nil,
                                      blockedTrackerDomains: nil,
                                      installedSurrogates: nil,
                                      isGPCEnabled: true,
                                      ampURL: "",
                                      urlParametersRemoved: true,
                                      protectionsState: true,
                                      reportFlow: .appMenu,
                                      siteType: .mobile,
                                      atb: "",
                                      model: "",
                                      errors: nil,
                                      httpStatusCodes: nil,
                                      openerContext: nil,
                                      vpnOn: false,
                                      jsPerformance: nil,
                                      userRefreshCount: 0,
                                      variant: "")

        try? breakageReporter.report(report, reportMode: .regular, daysToExpiry: breakageReportIntervalDays)
    }

    private func getAccountsCount() -> Int? {
        guard let secureVault = secureVault else {
            return nil
        }
        do {
            return try secureVault.accountsCount()
        } catch {
            return nil
        }
    }

    private func fetchAccounts() -> [SecureVaultModels.WebsiteAccount] {
        guard let secureVault = secureVault else {
            return []
        }

        do {
            let accounts = try secureVault.accounts()

            Task {
                await credentialIdentityStoreManager.replaceCredentialStore(with: accounts)
            }

            return accounts
        } catch {
            Logger.autofill.error("Failed to fetch accounts \(error.localizedDescription, privacy: .public)")
            return []
        }
    }

    private func fetchSuggestedAccounts() -> [SecureVaultModels.WebsiteAccount] {
        guard let currentUrl = currentTabUrl else {
            return []
        }

        let suggestedAccounts = accounts.filter { account in
            return autofillDomainNameUrlMatcher.isMatchingForAutofill(
                currentSite: currentUrl.absoluteString,
                savedSite: account.domain ?? "",
                tld: tld
            )
        }

        let sortedSuggestions = suggestedAccounts.sorted(by: {
            autofillDomainNameUrlSort.compareAccountsForSortingAutofill(lhs: $0, rhs: $1, tld: tld) == .orderedAscending
        })

        return sortedSuggestions
    }

    private func makeSections(with accounts: [SecureVaultModels.WebsiteAccount]) -> [AutofillLoginListSectionType] {
        var newSections = [AutofillLoginListSectionType]()

        if !isSearching {
            if !isEditing {
                newSections.append(.enableAutofill)
            }

            if !accountsToSuggest.isEmpty {
                let accountItems = accountsToSuggest.map { AutofillLoginItem(account: $0,
                                                                             tld: tld,
                                                                             autofillDomainNameUrlMatcher: autofillDomainNameUrlMatcher,
                                                                             autofillDomainNameUrlSort: autofillDomainNameUrlSort)
                }
                newSections.append(.suggestions(title: UserText.autofillLoginListSuggested, items: accountItems))
            }
        }

        let viewModelsGroupedByFirstLetter = accounts.groupedByFirstLetter(
                tld: tld,
                autofillDomainNameUrlMatcher: autofillDomainNameUrlMatcher,
                autofillDomainNameUrlSort: autofillDomainNameUrlSort)
        let accountSections = viewModelsGroupedByFirstLetter.sortedIntoSections(autofillDomainNameUrlSort,
                                                                                tld: tld)

        newSections.append(contentsOf: accountSections)
        return newSections
    }
    
    private func setupCancellables() {
        authenticator.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateViewState()
            }
            .store(in: &cancellables)
    }
    
    private func updateViewState() {
        var newViewState: AutofillLoginListViewModel.ViewState
        
        if authenticator.state == .loggedOut && !authenticationNotRequired {
            newViewState = .authLocked
        } else if authenticator.state == .notAvailable {
            newViewState = .noAuthAvailable
        } else if isSearching {
            if sections.count == 0 {
                newViewState = .searchingNoResults
            } else {
                newViewState = .searching
            }
        } else if isEditing {
            newViewState = sections.count >= 1 ? .showItems : .empty
        } else {
            newViewState = sections.count > 1 ? .showItems : .empty
        }
        
        // Avoid unnecessary updates
        if newViewState != viewState {
            viewState = newViewState
        }
    }

    func tableContentsToDelete(accountId: String?) -> (sectionsToDelete: [Int], rowsToDelete: [IndexPath]) {
        var sectionsToDelete: [Int] = []
        var rowsToDelete: [IndexPath] = []

        for (index, section) in sections.enumerated() {
            switch section {
            case .credentials(_, let items), .suggestions(_, let items):
                if let itemIndex = items.firstIndex(where: { $0.account.id == accountId }) {
                        if items.count == 1 {
                            sectionsToDelete.append(index)
                        } else {
                            rowsToDelete.append(IndexPath(row: itemIndex, section: index))
                        }
                    }
            default:
                break
            }
        }

        return (sectionsToDelete: sectionsToDelete, rowsToDelete: rowsToDelete)
    }

    @discardableResult
    func delete(_ account: SecureVaultModels.WebsiteAccount) -> Bool {
        guard let secureVault = secureVault,
              let accountID = account.id,
              let accountIdInt = Int64(accountID) else { return false }
        
        do {
            cachedDeletedCredentials = try secureVault.websiteCredentialsFor(accountId: accountIdInt)
            try secureVault.deleteWebsiteCredentialsFor(accountId: accountIdInt)
            return true
        } catch {
            Pixel.fire(pixel: .secureVaultError, error: error)
            return false
        }
    }
    
    private func undelete(_ account: SecureVaultModels.WebsiteCredentials) {
        guard let secureVault = secureVault,
              var cachedDeletedCredentials = cachedDeletedCredentials else {
            return
        }
        do {
            // We need to make a new account object. If we try to use the old one, secure vault will try to process it as an update, which will fail
            let oldAccount = cachedDeletedCredentials.account
            let newAccount = SecureVaultModels.WebsiteAccount(title: oldAccount.title, username: oldAccount.username, domain: oldAccount.domain)
            cachedDeletedCredentials.account = newAccount
            try secureVault.storeWebsiteCredentials(cachedDeletedCredentials)
            clearUndoCache()
            updateData()
        } catch {
            Pixel.fire(pixel: .secureVaultError, error: error)
        }
    }
    
    @discardableResult
    private func deleteAll() -> Bool {
        guard let secureVault = secureVault else { return false }

        do {
            try secureVault.deleteAllWebsiteCredentials()
            return true
        } catch {
            Pixel.fire(pixel: .secureVaultError, error: error)
            return false
        }
    }

    func shouldShowBreakageReporter() -> Bool {
        guard let currentTabUrl = currentTabUrl,
              !accountsToSuggest.isEmpty,
              privacyConfig.isEnabled(featureKey: .autofillBreakageReporter),
              let identifier = currentTabUrl.privacySafeDomainIdentifier,
              !privacyConfig.isInExceptionList(domain: currentTabUrl.host, forFeature: .autofillBreakageReporter) else {
            return false
        }

        if let entry = breakageReporter.persistencyManager.entry(forKey: identifier),
           let lastReportedDateStr = entry.value as? String,
           let lastReportedDate = reporterDateFormatter.date(from: lastReportedDateStr) {

            if Date.daysAgo(breakageReportIntervalDays) > lastReportedDate {
                _ = breakageReporter.persistencyManager.removeExpiredItems(currentDate: Date())
                return true
            } else {
                return false
            }
        }

        return true
    }
}
