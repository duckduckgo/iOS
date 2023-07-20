//
//  NetworkProtectionStatusViewModelTests.swift
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

import XCTest
import NetworkProtection
import NetworkExtension
@testable import DuckDuckGo

final class NetworkProtectionStatusViewModelTests: XCTestCase {
    private var tunnelController: MockNetworkProtectionTunnelControlling!
    private var viewModel: NetworkProtectionStatusViewModel!

    private var testError: Error {
        let nsError = NSError(domain: "", code: 0)
        return NEVPNError(_nsError: nsError)
    }

    override func setUp() {
        super.setUp()
        tunnelController = MockNetworkProtectionTunnelControlling()
        viewModel = NetworkProtectionStatusViewModel(tunnelController: tunnelController)
    }

    override func tearDown() {
        tunnelController = nil
        viewModel = nil
        super.tearDown()
    }

    func testStatusUpdate_connected_setsIsNetPEnabledToTrue() throws {
        tunnelController.statusSubject.send(.connected(connectedDate: Date()))
        waitFor(condition: self.viewModel.isNetPEnabled)
    }

    func testStatusUpdate_notConnected_setsIsNetPEnabledToTrue() {
        viewModel.isNetPEnabled = true
        let nonConnectedCases: [ConnectionStatus] = [.connecting, .disconnected, .disconnecting, .notConfigured, .reasserting]
        for current in nonConnectedCases {
            tunnelController.statusSubject.send(current)
            waitFor(condition: !self.viewModel.isNetPEnabled)
        }
    }

    func testDidToggleNetPToTrue_setsTunnelControllerStateToTrue() async {
        await viewModel.didToggleNetP(to: true)
        XCTAssertEqual(self.tunnelController.spySetStateEnabled, true)
    }

    func testDidToggleNetPToTrue_tunnelControllerErrors_setsStatusMessage() async {
        tunnelController.stubSetStateError = testError
        await viewModel.didToggleNetP(to: true)
        XCTAssertNotNil(self.viewModel.statusMessage)
    }

    func testDidToggleNetPToTrue_tunnelControllerErrors_setsIsNetPEnabledToFalse() async {
        tunnelController.stubSetStateError = testError
        await viewModel.didToggleNetP(to: true)
        XCTAssertFalse(self.viewModel.isNetPEnabled)
    }

    func testDidToggleNetPToFalse_tunnelControllerErrors_setsStatusMessage() async {
        tunnelController.stubSetStateError = testError
        await viewModel.didToggleNetP(to: false)
        XCTAssertNotNil(self.viewModel.statusMessage)
    }

    func testDidToggleNetPToFalse_setsTunnelControllerStateToFalse() async {
        await viewModel.didToggleNetP(to: false)
        XCTAssertEqual(self.tunnelController.spySetStateEnabled, false)
    }

    // MARK: - Helpers

    private func waitFor(condition: @escaping @autoclosure () -> Bool) {
        let predicate = NSPredicate { _, _ in
            condition()
        }
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: nil)
        wait(for: [expectation])
    }
}
