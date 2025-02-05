//
//  DataImportSummaryViewModel.swift
//  DuckDuckGo
//
//  Copyright © 2025 DuckDuckGo. All rights reserved.
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
import DDGSync

protocol DataImportSummaryViewModelDelegate: AnyObject {
    func dataImportSummaryViewModelDidRequestLaunchSync(_ viewModel: DataImportSummaryViewModel)
    func dataImportSummaryViewModelComplete(_ viewModel: DataImportSummaryViewModel)
}

final class DataImportSummaryViewModel: ObservableObject {

    weak var delegate: DataImportSummaryViewModelDelegate?

    @Published var passwordsSummary: DataImport.DataTypeSummary?
    @Published var bookmarksSummary: DataImport.DataTypeSummary?

    private let syncService: DDGSyncing

    var syncIsActive: Bool {
        syncService.authState != .inactive
    }

    var syncButtonTitle: String {
        if passwordsSummary != nil && bookmarksSummary != nil {
            return String(format: UserText.dataImportSummarySync,
                          UserText.dataImportSummarySyncData)
        } else if passwordsSummary != nil {
            return String(format: UserText.dataImportSummarySync,
                          UserText.dataImportSummarySyncPasswords)
        } else {
            return String(format: UserText.dataImportSummarySync,
                          UserText.dataImportSummarySyncBookmarks)
        }
    }

    init(summary: DataImportSummary, syncService: DDGSyncing) {
        self.passwordsSummary = try? summary[.passwords]?.get()
        self.bookmarksSummary = try? summary[.bookmarks]?.get()
        self.syncService = syncService
    }

    func isAllSuccessful() -> Bool {
       guard let passwords = passwordsSummary,
             let bookmarks = bookmarksSummary,
             passwords.failed == 0,
             passwords.duplicate == 0,
             bookmarks.failed == 0,
             bookmarks.duplicate == 0
       else { return false }

       return true
   }


    func dismiss() {
        delegate?.dataImportSummaryViewModelComplete(self)
    }

    func launchSync() {
        delegate?.dataImportSummaryViewModelDidRequestLaunchSync(self)
    }

}
