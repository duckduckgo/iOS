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
import UIKit
import Combine

enum AutofillLoginListSectionType {
    case enableAutofill
    case credentials(title: String, items: [AutofillLoginListItemViewModel])
}

struct AutofillLoginListSection: Identifiable {
    enum SectionType {
        case credentials
        case enableAutofill
    }
    
    let id = UUID()
    let title: String
    var items: [AutofillLoginListItemViewModel]
}

final class AutofillLoginListViewModel: ObservableObject {
    enum ViewState {
        case authLocked
        case empty
        case showItems
        case searching
    }
    
    
    private(set) var indexes = [String]()
    private var cancellables: Set<AnyCancellable> = []
    var isSearching: Bool = false {
        didSet {
            updateData()
        }
    }
    
    @Published private (set) var viewState: AutofillLoginListViewModel.ViewState = .authLocked
    @Published private(set) var sections = [AutofillLoginListSectionType]()
    
    private let authenticator = AutofillLoginListAuthenticator()
    
    var isAutofillEnabled: Bool {
        get {
            appSettings.autofill
        }
        
        set {
            appSettings.autofill = newValue
        }
    }
    private var appSettings: AppSettings
    
    init(appSettings: AppSettings) {
        self.appSettings = appSettings
        
        updateData()
        setupCancellables()
    }
    
 // MARK: Public Methods

    func filterData(with query: String) {
        updateData(with: query)
    }
    
    func delete(at indexPath: IndexPath) {
        let section = sections[indexPath.section]
        switch section {
        case .credentials(_, let items):
            let item = items[indexPath.row]
            delete(item.account)
            updateData()
        default:
            break
        }
    }
    
    func lockUI() {
        authenticator.logOut()
    }
    
    func authenticate() {
        if viewState != .authLocked {
            return
        }
        
        authenticator.authenticate { error in
            if let error = error {
                print("ERROR \(error)")
            }
        }
    }

    func rowsInSection(_ section: Int) -> Int {
        switch self.sections[section] {
        case .enableAutofill:
            return 1
        case .credentials(_, let items):
            return items.count
        }
    }
    
    func updateData(with query: String? = nil) {
        guard let secureVault = try? SecureVaultFactory.default.makeVault(errorReporter: SecureVaultErrorReporter.shared) else { return }
        var newSections = [AutofillLoginListSectionType]()

        sections.removeAll()
        indexes.removeAll()
        
        if !isSearching {
            newSections.append(.enableAutofill)
        }
        
#warning("REFACTOR THIS")
        if let accounts = try? secureVault.accounts() {
            var sectionsDictionary = [String: [AutofillLoginListItemViewModel]]()

            for account in accounts {
                print("ACCOUNT \(account.name) \(account.domain)")
               
                if let query = query, query.count > 0 {
                    if !account.name.lowercased().contains(query.lowercased()) &&
                        !account.domain.lowercased().contains(query.lowercased()) &&
                        !account.username.lowercased().contains(query.lowercased()) {
                        continue
                    }
                }
                
                
                if let first = account.name.first?.lowercased() {
                    if sectionsDictionary[first] != nil {
                        sectionsDictionary[first]?.append(AutofillLoginListItemViewModel(account: account))
                    } else {
                        let newSection = [AutofillLoginListItemViewModel(account: account)]
                        sectionsDictionary[first] = newSection
                    }
                }
            }
            
            for (key, var value) in sectionsDictionary {
                value.sort { leftItem, rightItem in
                    leftItem.title.lowercased() < rightItem.title.lowercased()
                }
                
                newSections.append(.credentials(title: key, items: value))
                indexes.append(key.uppercased())
            }
            
            newSections.sort(by: { leftSection, rightSection in
                if case .credentials(let left, _) = leftSection,
                   case .credentials(let right, _) = rightSection {
                    return left < right
                }
                return false
            })
            
            self.indexes.sort(by: { lhs, rhs in
                lhs < rhs
            })
            
            self.sections = newSections
            updateViewState()
        }
    }
    
    // MARK: Private Methods

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
        
        if authenticator.state == .loggedOut {
            newViewState = .authLocked
        } else if isSearching {
            newViewState = .searching
        } else {
            newViewState = self.sections.count > 1 ? .showItems : .empty
        }
        
        // Avoid unnecessary updates
        if newViewState != viewState {
            viewState = newViewState
        }
    }
    
    private func delete(_ account: SecureVaultModels.WebsiteAccount) {
        guard let secureVault = try? SecureVaultFactory.default.makeVault(errorReporter: SecureVaultErrorReporter.shared),
              let accountID = account.id else { return }
        
        do {
            try secureVault.deleteWebsiteCredentialsFor(accountId: accountID)
        } catch {
#warning("Pixel?")
        }
    }
}
