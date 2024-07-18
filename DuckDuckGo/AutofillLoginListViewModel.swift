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
import PrivacyDashboard

internal enum AutofillLoginListSectionType: Comparable {
    case enableAutofill
    case suggestions(title: String, items: [AutofillLoginListItemViewModel])
    case credentials(title: String, items: [AutofillLoginListItemViewModel])
    
    static func < (lhs: AutofillLoginListSectionType, rhs: AutofillLoginListSectionType) -> Bool {
        if case .credentials(let leftTitle, _) = lhs,
           case .credentials(let rightTitle, _) = rhs {
            if leftTitle == miscSectionHeading {
                return false
            } else if rightTitle == miscSectionHeading {
                return true
            }
            
            return leftTitle.localizedCaseInsensitiveCompare(rightTitle) == .orderedAscending
        }
        return true
    }
    
    static let miscSectionHeading = "#"
}

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

    let authenticator = AutofillLoginListAuthenticator(reason: UserText.autofillLoginListAuthenticationReason)
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
    private let breakageReporterKeyValueStoring: KeyValueStoringDictionaryRepresentable
    private var cachedDeletedCredentials: SecureVaultModels.WebsiteCredentials?
    private let autofillDomainNameUrlMatcher = AutofillDomainNameUrlMatcher()
    private let autofillDomainNameUrlSort = AutofillDomainNameUrlSort()
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

    internal lazy var breakageReporter = BrokenSiteReporter(pixelHandler: { [weak self] _ in
        if let currentTabUid = self?.currentTabUid {
            NotificationCenter.default.post(name: .autofillFailureReport, object: self, userInfo: [UserInfoKeys.tabUid: currentTabUid])
        }
        self?.updateData()
        self?.showBreakageReporter = false
    }, keyValueStoring: breakageReporterKeyValueStoring, storageConfiguration: .autofillConfig)

    @Published private (set) var viewState: AutofillLoginListViewModel.ViewState = .authLocked
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
         breakageReporterKeyValueStoring: KeyValueStoringDictionaryRepresentable = UserDefaults.standard) {
        self.appSettings = appSettings
        self.tld = tld
        self.secureVault = secureVault
        self.currentTabUrl = currentTabUrl
        self.currentTabUid = currentTabUid
        self.autofillNeverPromptWebsitesManager = autofillNeverPromptWebsitesManager
        self.privacyConfig = privacyConfig
        self.breakageReporterKeyValueStoring = breakageReporterKeyValueStoring

        if let count = getAccountsCount() {
            authenticationNotRequired = count == 0 || AppDependencyProvider.shared.autofillLoginSession.isSessionValid
        }
        updateData()
        setupCancellables()
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
    
    func authenticate(completion: @escaping(AutofillLoginListAuthenticator.AuthError?) -> Void) {
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

    private func saveReport(for currentTabUrl: URL) {
        let report = BrokenSiteReport(siteUrl: currentTabUrl,
                                      category: "",
                                      description: "",
                                      osVersion: "",
                                      manufacturer: "",
                                      upgradedHttps: false,
                                      tdsETag: nil,
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

    // MARK: Private Methods

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
            return try secureVault.accounts()
        } catch {
            os_log("Failed to fetch accounts")
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
                let accountItems = accountsToSuggest.map { AutofillLoginListItemViewModel(account: $0,
                                                                                          tld: tld,
                                                                                          autofillDomainNameUrlMatcher: autofillDomainNameUrlMatcher,
                                                                                          autofillDomainNameUrlSort: autofillDomainNameUrlSort)
                }
                newSections.append(.suggestions(title: UserText.autofillLoginListSuggested, items: accountItems))
            }
        }

        let viewModelsGroupedByFirstLetter = accounts.autofillLoginListItemViewModelsForAccountsGroupedByFirstLetter(
                tld: tld,
                autofillDomainNameUrlMatcher: autofillDomainNameUrlMatcher,
                autofillDomainNameUrlSort: autofillDomainNameUrlSort)
        let accountSections = viewModelsGroupedByFirstLetter.autofillLoginListSectionsForViewModelsSortedByTitle(autofillDomainNameUrlSort,
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

extension AutofillLoginListItemViewModel: Comparable {
    static func < (lhs: AutofillLoginListItemViewModel, rhs: AutofillLoginListItemViewModel) -> Bool {
        lhs.title < rhs.title
    }
}

internal extension Array where Element == SecureVaultModels.WebsiteAccount {
    
    func autofillLoginListItemViewModelsForAccountsGroupedByFirstLetter(tld: TLD,
                                                                        autofillDomainNameUrlMatcher: AutofillDomainNameUrlMatcher,
                                                                        autofillDomainNameUrlSort: AutofillDomainNameUrlSort)
            -> [String: [AutofillLoginListItemViewModel]] {
        reduce(into: [String: [AutofillLoginListItemViewModel]]()) { result, account in
            
            // Unfortunetly, folding doesn't produce perfect results despite respecting the system locale
            // E.g. Romainian should treat letters with diacritics as seperate letters, but folding doesn't
            // Apple's own apps (e.g. contacts) seem to suffer from the same problem
            let key: String
            if let firstChar = autofillDomainNameUrlSort.firstCharacterForGrouping(account, tld: tld),
               let deDistinctionedChar = String(firstChar).folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil).first,
               deDistinctionedChar.isLetter {
                
                key = String(deDistinctionedChar)
            } else {
                key = AutofillLoginListSectionType.miscSectionHeading
            }
            
            return result[key, default: []].append(AutofillLoginListItemViewModel(account: account,
                                                                                  tld: tld,
                                                                                  autofillDomainNameUrlMatcher: autofillDomainNameUrlMatcher,
                                                                                  autofillDomainNameUrlSort: autofillDomainNameUrlSort))
        }
    }
}

internal extension Dictionary where Key == String, Value == [AutofillLoginListItemViewModel] {
    
    func autofillLoginListSectionsForViewModelsSortedByTitle(_ autofillDomainNameUrlSort: AutofillDomainNameUrlSort, tld: TLD) -> [AutofillLoginListSectionType] {
        map { dictionaryItem -> AutofillLoginListSectionType in
            let sortedGroup = dictionaryItem.value.sorted(by: {
                autofillDomainNameUrlSort.compareAccountsForSortingAutofill(lhs: $0.account, rhs: $1.account, tld: tld) == .orderedAscending
            })
            return AutofillLoginListSectionType.credentials(title: dictionaryItem.key,
                                                            items: sortedGroup)
        }.sorted()
    }
}
