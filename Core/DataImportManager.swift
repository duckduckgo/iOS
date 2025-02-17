//
//  DataImportManager.swift
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
import Persistence
import Bookmarks
import Common

public protocol DataImportManaging: DataImporter {
    func importFile(at url: URL, for fileType: DataImportFileType) async throws -> DataImportSummary?
    func importZipArchive(from contents: ImportArchiveContents, for dataTypes: [DataImport.DataType]) async -> DataImportSummary
    static func preview(contents: ImportArchiveContents, tld: TLD) -> [DataImportPreview]
}

public typealias DataImportFileType = DataImportManager.FileType
public typealias DataImportPreview = DataImportManager.ImportPreview

public final class DataImportManager: DataImportManaging {

    public enum FileType {
        case csv
        case html
        case zip

        public init?(typeIdentifier: String) {
            switch typeIdentifier.lowercased() {
            case "public.zip-archive": self = .zip
            case "public.comma-separated-values-text": self = .csv
            case "public.html": self = .html
            default: return nil
            }
        }
    }

    public struct ImportPreview: Equatable, Hashable {
        public let type: DataImport.DataType
        public let count: Int

        public init(type: DataImport.DataType, count: Int) {
            self.type = type
            self.count = count
        }
    }

    private let loginImporter: LoginImporter
    private let reporter: SecureVaultReporting
    private let bookmarksDatabase: CoreDataDatabase
    private let favoritesDisplayMode: FavoritesDisplayMode
    private let tld: TLD

    private var csvImporter: CSVImporter?
    private var bookmarksImporter: BookmarksImporter?

    public init(loginImporter: LoginImporter = SecureVaultLoginImporter(),
                reporter: SecureVaultReporting,
                bookmarksDatabase: CoreDataDatabase,
                favoritesDisplayMode: FavoritesDisplayMode,
                tld: TLD) {
        self.loginImporter = loginImporter
        self.reporter = reporter
        self.bookmarksDatabase = bookmarksDatabase
        self.favoritesDisplayMode = favoritesDisplayMode
        self.tld = tld
    }

    public func importFile(at url: URL, for fileType: DataImportFileType) async throws -> DataImportSummary? {
        defer { cleanupImporters() }

        switch fileType {
        case .csv:
            csvImporter = createCSVImporter(url: url)
            return await importData(types: [.passwords]).task.value
        case .html:
            do {
                let html: String = try String(contentsOf: url, encoding: .utf8)
                bookmarksImporter = await createBookmarksImporter(htmlContent: html)
                return await importData(types: [.bookmarks]).task.value
            } catch {
                Logger.autofill.debug("Failed to read HTML file: \(error.localizedDescription)")
                return nil
            }
        default:
            return nil
        }
    }

    @MainActor
    public func importZipArchive(from contents: ImportArchiveContents,
                                 for dataTypes: [DataImport.DataType]) async -> DataImportSummary {
        defer { cleanupImporters() }

        csvImporter = dataTypes.contains(.passwords) ? contents.passwords.first.map { createCSVImporter(csvContent: $0) } : nil
        bookmarksImporter = dataTypes.contains(.bookmarks) ? contents.bookmarks.first.map { createBookmarksImporter(htmlContent: $0) } : nil

        return await importData(types: Set(dataTypes)).task.value
    }

    public static func preview(contents: ImportArchiveContents, tld: TLD) -> [ImportPreview] {
        var importPreview: [ImportPreview] = []

        if let csvContents = contents.passwords.first {
            let passwordsCount = CSVImporter.totalValidLogins(in: csvContents, defaultColumnPositions: nil, tld: tld)
            if passwordsCount > 0 {
                importPreview.append(ImportPreview(type: .passwords, count: passwordsCount))
            }
        }

        if let htmlContents = contents.bookmarks.first {
            let bookmarksCount = BookmarksImporter.totalValidBookmarks(in: htmlContents)
            if bookmarksCount > 0 {
                importPreview.append(ImportPreview(type: .bookmarks, count: bookmarksCount))
            }
        }

        return importPreview
    }

    public func importData(types: Set<DataImport.DataType>) -> DataImportTask {
        .detachedWithProgress { [weak self] updateProgress in
            guard let self else { return [:] }

            do {
                return try await self.importDataSync(types: types, updateProgress: updateProgress)
            } catch {
                Logger.autofill.debug("Failed to import data: \(error)")
                return [:]
            }
        }
    }

    // MARK: - Private

    @MainActor
    private func createBookmarksImporter(htmlContent: String) -> BookmarksImporter {
        BookmarksImporter(coreDataStore: bookmarksDatabase,
                          favoritesDisplayMode: favoritesDisplayMode,
                          htmlContent: htmlContent)
    }

    private func createCSVImporter(url: URL? = nil, csvContent: String? = nil) -> CSVImporter {
        CSVImporter(fileURL: url,
                    csvContent: csvContent,
                    loginImporter: loginImporter,
                    defaultColumnPositions: nil,
                    reporter: reporter,
                    tld: tld)
    }

    private func cleanupImporters() {
        csvImporter = nil
        bookmarksImporter = nil
    }

    private func importDataSync(types: Set<DataImport.DataType>, updateProgress: @escaping DataImportProgressCallback) async throws -> DataImportSummary {
        var summary = DataImportSummary()

        if types.contains(.passwords), let csvImporter {
            let importTask = csvImporter.importData(types: [.passwords])
            if case .success(let importSummary) = await importTask.result {
                summary[.passwords] = importSummary[.passwords]
            }
        }

        if types.contains(.bookmarks), let bookmarksImporter {
            if let bookmarksSummary = try? await bookmarksImporter.parseAndSave().get() {
               summary[.bookmarks] = .success(DataImport.DataTypeSummary(bookmarksSummary))
            }
        }

        try updateProgress(.done)
        return summary
    }

}
