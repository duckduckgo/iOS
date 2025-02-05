//
//  ImportArchiveReader.swift
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
import ZIPFoundation
import os.log

public protocol ImportArchiveReading {
    func readContents(from archiveURL: URL) throws -> ImportArchiveContents
}

public typealias ImportArchiveContents = ImportArchiveReader.Contents

public struct ImportArchiveReader: ImportArchiveReading {

    public struct Contents {
        public enum ContentType {
            case passwordsOnly
            case bookmarksOnly
            case both
            case none

            init(passwords: [String], bookmarks: [String]) {
                switch (passwords.isEmpty, bookmarks.isEmpty) {
                case (false, true): self = .passwordsOnly
                case (true, false): self = .bookmarksOnly
                case (false, false): self = .both
                case (true, true): self = .none
                }
            }
        }

        public let passwords: [String]  // CSV contents
        public let bookmarks: [String]  // HTML contents
        public var type: ContentType { ContentType(passwords: passwords, bookmarks: bookmarks) }
    }

    private enum Constants {
        static let csvExtension = ".csv"
        static let htmlExtension = ".html"
    }

    public init() {}

    public func readContents(from url: URL) throws -> Contents {
        let archive = try Archive(url: url, accessMode: .read)

        let passwords = archive.compactMap { entry -> String? in
            guard entry.path.lowercased().hasSuffix(Constants.csvExtension),
                  let content = extractFileContent(from: entry, in: archive) else { return nil }
            return content
        }

        let bookmarks = archive.compactMap { entry -> String? in
            guard entry.path.lowercased().hasSuffix(Constants.htmlExtension),
                  let content = extractFileContent(from: entry, in: archive) else { return nil }
            return content
        }

        return Contents(passwords: passwords, bookmarks: bookmarks)
    }

    // MARK: - Private

    private func extractFileContent(from entry: Entry, in archive: Archive) -> String? {
        var data = Data()

        _ = try? archive.extract(entry) { chunk in
            data.append(chunk)
        }

        guard let content = String(data: data, encoding: .utf8) else {
            Logger.autofill.debug("Failed to decode archive contents")
            return nil
        }

        return content
    }
}
