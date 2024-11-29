//
//  UnifiedMetadataCollector.swift
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

import Foundation

protocol UnifiedMetadataCollector {
    associatedtype Metadata: UnifiedFeedbackMetadata

    func collectMetadata() async -> Metadata?
}

protocol UnifiedFeedbackMetadata: Encodable {
    func toBase64() -> String
    func toString() -> String
}

extension UnifiedFeedbackMetadata {
    func toBase64() -> String {
        let encoder = JSONEncoder()

        do {
            let encodedMetadata = try encoder.encode(self)
            return encodedMetadata.base64EncodedString()
        } catch {
            return "Failed to encode metadata to JSON, error message: \(error.localizedDescription)"
        }
    }

    func toString() -> String {
        let encoder = JSONEncoder()
        do {
            let encodedMetadata = try encoder.encode(self)
            return String(data: encodedMetadata, encoding: .utf8) ?? ""
        } catch {
            return "Failed to encode metadata to JSON string, error message: \(error.localizedDescription)"
        }
    }
}
