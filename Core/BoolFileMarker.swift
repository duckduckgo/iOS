//
//  BoolFileMarker.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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

public struct BoolFileMarker {
    let fileManager = FileManager.default
    private let url: URL

    public var isPresent: Bool {
        fileManager.fileExists(atPath: url.path)
    }

    public func mark() {
        if !isPresent {
            fileManager.createFile(atPath: url.path, contents: nil, attributes: [.protectionKey: FileProtectionType.none])
        }
    }

    public func unmark() {
        if isPresent {
            try? fileManager.removeItem(at: url)
        }
    }

    public init?(name: Name) {
        guard let applicationSupportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }

        self.url = applicationSupportDirectory.appendingPathComponent(name.rawValue)
    }

    public struct Name: RawRepresentable {
        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = "\(rawValue).marker"
        }
    }
}
