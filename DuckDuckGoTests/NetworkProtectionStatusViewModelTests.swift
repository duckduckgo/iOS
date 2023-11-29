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
    private var serverInfoObserver: MockConnectionServerInfoObserver!
    private var viewModel: NetworkProtectionStatusViewModel!

    private var testError: Error {
        let nsError = NSError(domain: "", code: 0)
        return NEVPNError(_nsError: nsError)
    }

    override func setUp() {
        super.setUp()
        tunnelController = MockTunnelController()
        statusObserver = MockConnectionStatusObserver()
        serverInfoObserver = MockConnectionServerInfoObserver()
        viewModel = NetworkProtectionStatusViewModel(
            tunnelController: tunnelController,
            statusObserver: statusObserver,
            serverInfoObserver: serverInfoObserver
        )
    }

    override func tearDown() {
        serverInfoObserver = nil
        statusObserver = nil
        tunnelController = nil
        viewModel = nil
        super.tearDown()
    }

    func testInit_prefetchesLocationList() throws {
        let locationListRepo = MockNetworkProtectionLocationListRepository()
        viewModel = NetworkProtectionStatusViewModel(locationListRepository: locationListRepo)
        waitFor(condition: locationListRepo.didCallFetchLocationList)
    }

    func testStatusUpdate_connected_setsIsNetPEnabledToTrue() throws {
        whenStatusUpdate_connected()
    }

    func testStatusUpdate_notConnected_setsIsNetPEnabledToFalse() throws {
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
        try waitForPublisher(viewModel.$statusMessage, toEmit: "Connected - 00:00:00")
        try waitForPublisher(viewModel.$statusMessage, toEmit: "Connected - 00:00:01")
    }

    func testStatusUpdate_disconnecting_updateStatusToDisconnecting() throws {
        viewModel.isNetPEnabled = true
        statusObserver.subject.send(.disconnecting)
        try waitForPublisher(viewModel.$statusMessage, toEmit: UserText.netPStatusDisconnecting)
    }

    func testStatusUpdate_connectingOrReasserting_updateStatusToConnecting() throws {
        let connectingStates: [ConnectionStatus] = [.connecting, .reasserting]
        for current in connectingStates {
            statusObserver.subject.send(current)
            try waitForPublisher(viewModel.$statusMessage, toEmit: UserText.netPStatusConnecting)
        }
    }

    func testStatusUpdate_disconnectedOrNotConfigured_updateStatusToDisconnected() throws {
        let disconnectedStates: [ConnectionStatus] = [.disconnected, .notConfigured]
        // Wait for the initial value first
        try waitForPublisher(viewModel.$statusMessage, toEmit: UserText.netPStatusDisconnected)
        for current in disconnectedStates {
            viewModel.statusMessage = ""
            statusObserver.subject.send(current)
            try waitForPublisher(viewModel.$statusMessage, toEmit: UserText.netPStatusDisconnected)
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

    func testStatusUpdate_publishesLocation() throws {
        let location = "SomeLocation"
        let serverInfo = NetworkProtectionStatusServerInfo(serverLocation: location, serverAddress: nil)
        serverInfoObserver.subject.send(serverInfo)
        try waitForPublisher(viewModel.$location, toEmit: location)
    }

    func testStatusUpdate_publishesIPAddress() throws {
        let ipAddress = "123.456.789.147"
        let serverInfo = NetworkProtectionStatusServerInfo(serverLocation: nil, serverAddress: ipAddress)
        serverInfoObserver.subject.send(serverInfo)
        try waitForPublisher(viewModel.$ipAddress, toEmit: ipAddress)
    }

    func testStatusUpdate_nilServerLocationAndServerAddress_hidesConnectionDetails() throws {
        let serverInfo = NetworkProtectionStatusServerInfo(serverLocation: nil, serverAddress: nil)
        // Wait for initial value first
        try waitForPublisher(viewModel.$shouldShowConnectionDetails, toEmit: false)
        serverInfoObserver.subject.send(serverInfo)
        try waitForPublisher(viewModel.$shouldShowConnectionDetails, toEmit: false)
    }

    func testStatusUpdate_anyServerInfoPropertiesNonNil_showsConnectionDetails() throws {
        for serverInfo in [
            NetworkProtectionStatusServerInfo(serverLocation: nil, serverAddress: "123.123.123.123"),
            NetworkProtectionStatusServerInfo(serverLocation: "Antartica", serverAddress: nil),
            NetworkProtectionStatusServerInfo(serverLocation: "Your Garden", serverAddress: "111.222.333.444")
        ] {
            serverInfoObserver.subject.send(serverInfo)
            try waitForPublisher(viewModel.$shouldShowConnectionDetails, toEmit: true)
        }
    }

    // MARK: - Helpers

    private func whenStatusUpdate_connected() {
        statusObserver.subject.send(.connected(connectedDate: Date()))
        waitFor(condition: self.viewModel.isNetPEnabled)
    }

    private func whenStatusUpdate_notConnected() {
        let nonConnectedCases: [ConnectionStatus] = [.disconnected, .disconnecting, .notConfigured, .reasserting]
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
        wait(for: [expectation], timeout: 5)
    }
}
