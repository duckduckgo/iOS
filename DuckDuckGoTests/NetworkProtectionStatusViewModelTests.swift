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

    func testStatusUpdate_connected_updatesStatusMessageEverySecond_withTimeLapsed() throws {
        statusObserver.subject.send(.connected(connectedDate: Date()))
        // To make this more test stable, give it 3 seconds to give the initial and first updates
        let collected = try waitForPublisher(viewModel.$statusMessage.collectNext(3))
        let expectedMessages = ["Connected - 00:00:00", "Connected - 00:00:01"]
        if #available(iOS 16.0, *) {
            XCTAssertTrue(collected.contains(expectedMessages))
        } else {
            XCTAssertTrue(
                collected.contains {
                    $0 == expectedMessages.first!
                }
            )
            XCTAssertTrue(
                collected.contains {
                    $0 == expectedMessages.last!
                }
            )
        }
    }

    func testStatusUpdate_disconnecting_updateStatusToDisconnecting() throws {
        viewModel.isNetPEnabled = true
        statusObserver.subject.send(.disconnecting)
        let statusMessage = try waitForPublisher(viewModel.$statusMessage.collectNext(2)).last
        XCTAssertEqual(statusMessage, UserText.netPStatusDisconnecting)
    }

    func testStatusUpdate_connectingOrReasserting_updateStatusToConnecting() throws {
        let connectingStates: [ConnectionStatus] = [.connecting, .reasserting]
        // Collect the initial value first
        _ = try waitForPublisher(viewModel.$statusMessage.collectNext(1)).last
        for current in connectingStates {
            statusObserver.subject.send(current)
            let statusMessage = try waitForPublisher(viewModel.$statusMessage.collectNext(1)).last
            XCTAssertEqual(statusMessage, UserText.netPStatusConnecting)
        }
    }

    func testStatusUpdate_disconnectedOrNotConfigured_updateStatusToDisconnected() throws {
        let disconnectedStates: [ConnectionStatus] = [.disconnected, .notConfigured]
        // Collect the initial value first
        _ = try waitForPublisher(viewModel.$statusMessage.collectNext(1)).last
        for current in disconnectedStates {
            viewModel.isNetPEnabled = true
            statusObserver.subject.send(current)
            let statusMessage = try waitForPublisher(viewModel.$statusMessage.collectNext(1)).last
            XCTAssertEqual(statusMessage, UserText.netPStatusDisconnected)
        }
    }

    func testStatusUpdate_notLoadingStates_enablesToggle() throws {
        let notLoadingStates: [ConnectionStatus] = [.connected(connectedDate: Date()), .disconnected, .notConfigured]
        for current in notLoadingStates {
            viewModel.shouldDisableToggle = true
            statusObserver.subject.send(current)
            try waitForPublisher(viewModel.$shouldDisableToggle, toEmit: false)
        }
    }

    func testStatusUpdate_loadingStates_disablesToggle() throws {
        let toggleEnabledStates: [ConnectionStatus] = [.disconnecting, .connecting, .reasserting]
        for current in toggleEnabledStates {
            viewModel.shouldDisableToggle = false
            statusObserver.subject.send(current)
            try waitForPublisher(viewModel.$shouldDisableToggle, toEmit: true)
        }
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
