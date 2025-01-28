//
//  SafariZipDataImporter.swift
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
import os.log

final public class SafariZipDataImporter: DataImporter {

    private let loginImporter: CSVImporter

    public var importableTypes: [DataImport.DataType] {
        return [.passwords]
    }

    public init(csvImporter: CSVImporter) {
        loginImporter = csvImporter
    }

    public func importData(types: Set<DataImport.DataType>) -> DataImportTask {
        .detachedWithProgress { updateProgress in
            do {
                let result = try await self.importDataSync(types: types, updateProgress: updateProgress)
                return result
            } catch {
                Logger.autofill.debug("Failed to import data: \(error)")
            }
            return [:]
        }
    }

    private func importDataSync(types: Set<DataImport.DataType>, updateProgress: @escaping DataImportProgressCallback) async throws -> DataImportSummary {
        var summary = DataImportSummary()

        if types.contains(.passwords) {
            let importTask = loginImporter.importData(types: [.passwords])
            let result = await importTask.result

            if case .success(let importSummary) = result {
                summary[.passwords] = importSummary[.passwords]
            }

        }

        try updateProgress(.done)

        return summary
    }
}
