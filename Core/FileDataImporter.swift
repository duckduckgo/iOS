//
//  FileDataImporter.swift
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
import SecureStorage
import os.log

// MARK: - Protocol
public protocol FileDataImportingService {
    func importFile(at url: URL, type: FileDataImporter.ImportType) async -> DataImportSummary
}

// MARK: - Implementation
final public class FileDataImporter: FileDataImportingService {

    public enum ImportType {
        case csv
        case zip
    }

    private let loginImporter: SecureVaultLoginImporter
    private let reporter: SecureVaultReporting

    public init(loginImporter: SecureVaultLoginImporter = SecureVaultLoginImporter(),
                reporter: SecureVaultReporting) {
        self.loginImporter = loginImporter
        self.reporter = reporter
    }
    
    public func importFile(at url: URL, type: ImportType) async -> DataImportSummary {
        switch type {
        case .csv:
            return await importCSV(from: url)
        case .zip:
            return await handleZipContents(at: url)
        }
    }
    
    private func importCSV(from url: URL) async -> DataImportSummary {
        let importer = CSVImporter(
            fileURL: url,
            loginImporter: loginImporter,
            defaultColumnPositions: .init(source: .csv),
            reporter: reporter
        )
        
        return await importer.importData(types: [.passwords]).task.value
    }

    private func handleZipContents(at url: URL) async -> DataImportSummary {
        guard let extractedFiles = try? ZipContentExtractor().extractZipContents(from: url) else {
            Logger.autofill.debug("Failed to extract ZIP file")
            return DataImportSummary()
        }
        
        var summary: DataImportSummary = DataImportSummary()

        // Handle CSV files if present
        if let csv = extractedFiles.csvFiles.first {
            let importer = CSVImporter(
                fileURL: nil,
                csvContent: csv,
                loginImporter: loginImporter,
                defaultColumnPositions: .init(source: .csv),
                reporter: reporter
            )
            
            let safariZipDataImporter = SafariZipDataImporter(csvImporter: importer)
            summary = await safariZipDataImporter.importData(types: [.passwords]).task.value
            Logger.autofill.debug("CSV import summary: \(String(describing: summary))")
        }

        return summary
    }
}
