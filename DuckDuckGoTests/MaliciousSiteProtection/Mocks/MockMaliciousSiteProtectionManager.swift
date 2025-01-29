//
//  MockMaliciousSiteProtectionManager.swift
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
import MaliciousSiteProtection
@testable import DuckDuckGo

final class MockMaliciousSiteProtectionManager: MaliciousSiteDetecting, MaliciousSiteProtectionDatasetsFetching {
    private(set) var didCallStartFetching = false
    private(set) var didCallRegisterBackgroundRefreshTaskHandler = false

    var threatKind: ThreatKind?

    func startFetching() {
        didCallStartFetching = true
    }

    func registerBackgroundRefreshTaskHandler() {
        didCallRegisterBackgroundRefreshTaskHandler = true
    }

    func evaluate(_ url: URL) async -> MaliciousSiteProtection.ThreatKind? {
        threatKind
    }

}
