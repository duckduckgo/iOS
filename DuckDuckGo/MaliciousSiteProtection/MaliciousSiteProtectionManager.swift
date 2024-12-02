//
//  MaliciousSiteProtectionManager.swift
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

final class MaliciousSiteProtectionManager: MaliciousSiteDetecting {

    func evaluate(_ url: URL) async -> ThreatKind? {
        try? await Task.sleep(interval: 0.3)
        return .none
    }

}

// MARK: - To Remove

// These entities are copied from BSK and they will be used to mock the library
import SpecialErrorPages

protocol MaliciousSiteDetecting {
    func evaluate(_ url: URL) async -> ThreatKind?
}

public enum ThreatKind: String, CaseIterable, CustomStringConvertible {
    public var description: String { rawValue }

    case phishing
    case malware
}

public extension ThreatKind {

    var errorPageType: SpecialErrorKind {
        switch self {
        case .malware: .phishing // WIP in BSK
        case .phishing: .phishing
        }
    }

}
