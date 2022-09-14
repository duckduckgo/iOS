//
//  ReaderModeCache.swift
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
import Core

final class ReaderModeCache {
    static let shared = ReaderModeCache()

    private init() {}

    private static let cacheDirectory: URL = {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("readability")
    }()

    func cacheReadabilityResult(_ readabilityResult: ReadabilityResult, for url: URL) {
        let cacheURL = localURL(for: url)
        try? FileManager.default.createDirectory(at: Self.cacheDirectory, withIntermediateDirectories: true)
        try? readabilityResult.encode().write(to: cacheURL)
    }

    private func localURL(for url: URL) -> URL {
        let filename = url.absoluteString.sha256()
        return Self.cacheDirectory.appendingPathComponent(filename)
    }

    func readabilityResult(for url: URL) throws -> ReadabilityResult {
        let cacheURL = localURL(for: url)
        let data = try Data(contentsOf: cacheURL)
        guard let readabilityResult = try ReadabilityResult(data: data) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: ""))
        }
        return readabilityResult
    }

    func clear() {
        try? FileManager.default.removeItem(at: Self.cacheDirectory)
    }

}
