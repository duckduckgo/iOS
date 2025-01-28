//
//  ZipContentExtractor.swift
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

final public class ZipContentExtractor {

    public enum ZipError: Error {
        case extractionFailed
        case fileNotFound
        case decodingFailed
    }

    public struct ExtractedFiles {
        public let csvFiles: [String]
    }

    public init() {}

    public func extractZipContents(from zipURL: URL) throws -> ExtractedFiles {
        let archive = try Archive(url: zipURL, accessMode: .read)

        var csvFiles: [String] = []

        for entry in archive {
            var data = Data()

            _ = try archive.extract(entry) { chunk in
                data.append(chunk)
            }

            guard let content = String(data: data, encoding: .utf8) else {
                Logger.autofill.debug("Failed to decode zip contents")
                throw ZipError.decodingFailed
            }

            let lowercasePath = entry.path.lowercased()
            if lowercasePath.hasSuffix(".csv") {
                csvFiles.append(content)
            }
        }

        // Throw error if no files were found
        if csvFiles.isEmpty {
            throw ZipError.fileNotFound
        }

        return ExtractedFiles(csvFiles: csvFiles)
    }

}
