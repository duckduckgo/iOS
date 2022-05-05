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

struct AutofillLoginListSection: Identifiable {
    let id = UUID()
    let title: String
    var items: [AutofillLoginListItemViewModel]
}

final class AutofillLoginListViewModel: ObservableObject {
    @Published var sections = [AutofillLoginListSection]()

    init() {
        update()
    }
    
    func update() {
        guard let secureVault = try? SecureVaultFactory.default.makeVault(errorReporter: SecureVaultErrorReporter.shared) else { return }

        sections.removeAll()

        #warning("REFACTOR THIS")
        if let accounts = try? secureVault.accounts() {
            var sections = [String: AutofillLoginListSection]()
            
            for account in accounts {
                print("ACCOUNT \(account.name) \(account.domain)")
                
                if let first = account.name.first?.lowercased() {
                    if sections[first] != nil {
                        sections[first]?.items.append(AutofillLoginListItemViewModel(account: account))
                    } else {
                        let newSection = [AutofillLoginListItemViewModel(account: account)]
                        sections[first] = AutofillLoginListSection(title: String(first), items: newSection)
                    }
                }
            }
            
            for (_, var value) in sections {
                value.items.sort { leftItem, rightItem in
                    leftItem.title.lowercased() < rightItem.title.lowercased()
                }
                
                self.sections.append(value)
            }
            
            self.sections.sort(by: { leftSection, rightSection in
                leftSection.title < rightSection.title
            })
        }
    }
}
