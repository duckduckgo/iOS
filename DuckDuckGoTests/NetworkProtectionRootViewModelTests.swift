//
//  NetworkProtectionRootViewModelTests.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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
import XCTest
@testable import DuckDuckGo
import NetworkProtection

final class NetworkProtectionRootViewModelTests: XCTestCase {

    func test_initialViewKind_featureVisibilityFalse_isInvite() {
        let featureActivation = MockNetworkProtectionFeatureActivation()
        featureActivation.isFeatureActivated = false
        let viewModel = NetworkProtectionRootViewModel(featureActivation: featureActivation)
        XCTAssertEqual(viewModel.initialViewKind, .invite)
    }

    func test_initialViewKind_featureVisibilityTrue_isStatus() {
        let featureActivation = MockNetworkProtectionFeatureActivation()
        featureActivation.isFeatureActivated = true
        let viewModel = NetworkProtectionRootViewModel(featureActivation: featureActivation)
        XCTAssertEqual(viewModel.initialViewKind, .status)
    }
}

final class MockNetworkProtectionFeatureActivation: NetworkProtectionFeatureActivation {
    var isFeatureActivated: Bool = false
}
