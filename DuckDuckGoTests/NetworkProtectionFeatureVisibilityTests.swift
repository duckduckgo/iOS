//
//  NetworkProtectionFeatureVisibilityTests.swift
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

import XCTest
@testable import DuckDuckGo

/// Test all permutations according to https://app.asana.com/0/0/1206812323779606/f
final class NetworkProtectionFeatureVisibilityTests: XCTestCase {
    func testPrivacyProNotYetLaunched() {
        // Waitlist beta OFF, not current waitlist user -> Show nothing, use nothing
        let mockWithNothing = NetworkProtectionFeatureVisibilityMocks(with: [])
        XCTAssertFalse(mockWithNothing.shouldMonitorEntitlement())
        XCTAssertFalse(mockWithNothing.shouldShowVPNShortcut())
    }

    func testPrivacyProLaunched() {
        // Waitlist beta OFF, not current waitlist user -> Enforce entitlement check, nothing else
        let mockWithNothingElse = NetworkProtectionFeatureVisibilityMocks(with: [.isPrivacyProLaunched])
        XCTAssertTrue(mockWithNothingElse.shouldMonitorEntitlement())
        XCTAssertFalse(mockWithNothingElse.shouldShowVPNShortcut())
    }
}

struct NetworkProtectionFeatureVisibilityMocks: NetworkProtectionFeatureVisibility {
    struct Options: OptionSet {
        let rawValue: Int

        static let isPrivacyProLaunched = Options(rawValue: 1 << 0)
    }

    let options: Options

    init(with options: Options) {
        self.options = options
    }

    func adding(_ additionalOptions: Options) -> NetworkProtectionFeatureVisibilityMocks {
        NetworkProtectionFeatureVisibilityMocks(with: options.union(additionalOptions))
    }

    func isPrivacyProLaunched() -> Bool {
        options.contains(.isPrivacyProLaunched)
    }

    func shouldMonitorEntitlement() -> Bool {
        isPrivacyProLaunched()
    }
}
