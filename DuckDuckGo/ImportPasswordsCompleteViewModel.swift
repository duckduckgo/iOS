//
//  ImportPasswordsCompleteViewModel.swift
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

protocol ImportPasswordsCompleteViewModelDelegate: AnyObject {
    func importPasswordsCompleteViewModelComplete(_ viewModel: ImportPasswordsCompleteViewModel)
}

final class ImportPasswordsCompleteViewModel: ObservableObject {
    
    weak var delegate: ImportPasswordsCompleteViewModelDelegate?
    
    @Published var passwordsSummary: DataImport.DataTypeSummary?
//    @Published var failureCount: Int = 0
//    @Published var duplicatesCount: Int = 0
    
    init(summary: DataImportSummary) {

        passwordsSummary = try? summary[.passwords]?.get()
//        switch summary {
//        case .success(let summary):
//            passwordsSummary = summary[.passwords]
//        }
//        dataSummaryResult(importTask: importTask)
    }
    
//    private func dataSummaryResult(importTask: DataImportTask) {
//        Task {
//            let result = await importTask.result
//            if let summary = try? result.get()[.passwords]?.get() {
//                successCount = summary.successful
//                failureCount = summary.failed
//                duplicatesCount = summary.duplicate
//                Logger.autofill.debug("Import result successful: \(summary.successful)")
//                Logger.autofill.debug("Import result duplicate: \(summary.duplicate)")
//                Logger.autofill.debug("Import result failed: \(summary.failed)")
//            }
//        }
//    }
    
    func dismiss() {
        delegate?.importPasswordsCompleteViewModelComplete(self)
    }

//    func summary(for dataType: DataType) -> DataTypeSummary? {
//        if case .success(let summary) = self.summary.last(where: { $0.dataType == dataType })?.result {
//            return summary
//        }
//        return nil
//    }

}
