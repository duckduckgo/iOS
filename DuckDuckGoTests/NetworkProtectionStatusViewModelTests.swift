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
import NetworkProtectionTestUtils
@testable import DuckDuckGo

final class NetworkProtectionStatusViewModelTests: XCTestCase {
    private var tunnelController: MockTunnelController!
    private var statusObserver: MockConnectionStatusObserver!
    private var viewModel: NetworkProtectionStatusViewModel!

    private var testError: Error {
        let nsError = NSError(domain: "", code: 0)
        return NEVPNError(_nsError: nsError)
    }

    override func setUp() {
        super.setUp()
        tunnelController = MockTunnelController()
        statusObserver = MockConnectionStatusObserver()
        viewModel = NetworkProtectionStatusViewModel(tunnelController: tunnelController, statusObserver: statusObserver)
    }

    override func tearDown() {
        statusObserver = nil
        tunnelController = nil
        viewModel = nil
        super.tearDown()
    }

    func testStatusUpdate_connected_setsIsNetPEnabledToTrue() {
        whenStatusUpdate_connected()
    }

    func testStatusUpdate_notConnected_setsIsNetPEnabledToFalse() {
        whenStatusUpdate_notConnected()
    }

    func testDidToggleNetPToTrue_setsTunnelControllerStateToTrue() async {
        await viewModel.didToggleNetP(to: true)
        XCTAssertEqual(self.tunnelController.didCallStart, true)
    }

    func testDidToggleNetPToFalse_setsTunnelControllerStateToFalse() async {
        await viewModel.didToggleNetP(to: false)
        XCTAssertEqual(self.tunnelController.didCallStart, false)
    }

    func testStatusUpdate_connected_setsHeaderTitleToOn() {
        viewModel.headerTitle = ""
        whenStatusUpdate_connected()
        XCTAssertEqual(self.viewModel.headerTitle, UserText.netPStatusHeaderTitleOn)
    }

    func testStatusUpdate_notconnected_setsHeaderTitleToOff() {
        viewModel.headerTitle = ""
        whenStatusUpdate_notConnected()
        XCTAssertEqual(self.viewModel.headerTitle, UserText.netPStatusHeaderTitleOff)
    }

    func testStatusUpdate_connected_setsStatusImageIDToVPN() {
        viewModel.statusImageID = ""
        whenStatusUpdate_connected()
        XCTAssertEqual(self.viewModel.statusImageID, "VPN")
    }

    func testStatusUpdate_disconnected_setsStatusImageIDToVPNDisabled() {
        viewModel.statusImageID = ""
        whenStatusUpdate_notConnected()
        XCTAssertEqual(self.viewModel.statusImageID, "VPNDisabled")
    }

    // MARK: - Helpers

    private func whenStatusUpdate_connected() {
        statusObserver.subject.send(.connected(connectedDate: Date()))
        waitFor(condition: self.viewModel.isNetPEnabled)
    }

    private func whenStatusUpdate_notConnected() {
        let nonConnectedCases: [ConnectionStatus] = [.connecting, .disconnected, .disconnecting, .notConfigured, .reasserting]
        for current in nonConnectedCases {
            statusObserver.subject.send(current)
            waitFor(condition: !self.viewModel.isNetPEnabled)
        }
    }

    private func waitFor(condition: @escaping @autoclosure () -> Bool) {
        let predicate = NSPredicate { _, _ in
            condition()
        }
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: nil)
        wait(for: [expectation])
    }
}
