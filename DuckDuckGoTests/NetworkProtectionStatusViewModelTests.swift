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
import SubscriptionTestingUtilities
import Subscription
@testable import DuckDuckGo

final class NetworkProtectionStatusViewModelTests: XCTestCase {
    private var tunnelController: MockTunnelController!
    private var statusObserver: MockConnectionStatusObserver!
    private var serverInfoObserver: MockConnectionServerInfoObserver!
    private var subscriptionManager: SubscriptionManagerMock!
    private var viewModel: NetworkProtectionStatusViewModel!

    private var testError: Error {
        let nsError = NSError(domain: "", code: 0)
        return NEVPNError(_nsError: nsError)
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        tunnelController = MockTunnelController()
        statusObserver = MockConnectionStatusObserver()
        serverInfoObserver = MockConnectionServerInfoObserver()
        subscriptionManager = SubscriptionManagerMock(accountManager: AccountManagerMock(),
                                                      subscriptionEndpointService: SubscriptionEndpointServiceMock(),
                                                      authEndpointService: AuthEndpointServiceMock(),
                                                      storePurchaseManager: StorePurchaseManagerMock(),
                                                      currentEnvironment: SubscriptionEnvironment(serviceEnvironment: .production, purchasePlatform: .appStore),
                                                      canPurchase: true,
                                                      subscriptionFeatureMappingCache: SubscriptionFeatureMappingCacheMock())
        viewModel = NetworkProtectionStatusViewModel(tunnelController: tunnelController,
                                                     settings: VPNSettings(defaults: .networkProtectionGroupDefaults),
                                                     statusObserver: statusObserver,
                                                     serverInfoObserver: serverInfoObserver,
                                                     locationListRepository: MockNetworkProtectionLocationListRepository(),
                                                     usesUnifiedFeedbackForm: false,
                                                     subscriptionManager: subscriptionManager)
    }

    override func tearDown() {
        serverInfoObserver = nil
        statusObserver = nil
        tunnelController = nil
        viewModel = nil
        super.tearDown()
    }

    func testStatusUpdate_connected_setsIsNetPEnabledToTrue() async throws {
        await whenStatusUpdate_connected()
    }

    func testStatusUpdate_notConnected_setsIsNetPEnabledToFalse() async throws {
        await whenStatusUpdate_notConnected()
    }

    func testDidToggleNetPToTrue_setsTunnelControllerStateToTrue() async {
        await viewModel.didToggleNetP(to: true)
        XCTAssertEqual(self.tunnelController.didCallStart, true)
    }

    func testDidToggleNetPToFalse_setsTunnelControllerStateToFalse() async {
        await viewModel.didToggleNetP(to: false)
        XCTAssertEqual(self.tunnelController.didCallStart, false)
    }

    func testStatusUpdate_connected_setsHeaderTitleToOn() async {
        viewModel.headerTitle = ""
        await whenStatusUpdate_connected()
        XCTAssertEqual(self.viewModel.headerTitle, UserText.netPStatusHeaderTitleOn)
    }

    func testStatusUpdate_notconnected_setsHeaderTitleToOff() async {
        viewModel.headerTitle = ""
        await whenStatusUpdate_notConnected()
        XCTAssertEqual(self.viewModel.headerTitle, UserText.netPStatusHeaderTitleOff)
    }

    func testStatusUpdate_connected_setsStatusImageIDToVPN() async {
        viewModel.statusImageID = ""
        await whenStatusUpdate_connected()
        XCTAssertEqual(self.viewModel.statusImageID, "VPN")
    }

    func testStatusUpdate_disconnected_setsStatusImageIDToVPNDisabled() async {
        viewModel.statusImageID = ""
        await whenStatusUpdate_notConnected()
        XCTAssertEqual(self.viewModel.statusImageID, "VPNDisabled")
    }

    func testStatusUpdate_connected_updatesStatusMessageEverySecond_withTimeLapsed() throws {
        statusObserver.subject.send(.connected(connectedDate: Date()))
        try waitForPublisher(viewModel.$statusMessage, toEmit: "Connected · 00:00:00")
        try waitForPublisher(viewModel.$statusMessage, toEmit: "Connected · 00:00:01")
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
        let attributes = serverAttributes()
        let serverInfo = NetworkProtectionStatusServerInfo(serverLocation: attributes, serverAddress: nil)
        serverInfoObserver.subject.send(serverInfo)
        try waitForPublisher(viewModel.$location, toEmit: "🇺🇸 El Segundo, United States")
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
        try waitForPublisher(viewModel.$hasServerInfo, toEmit: false)
        serverInfoObserver.subject.send(serverInfo)
        try waitForPublisher(viewModel.$hasServerInfo, toEmit: false)
    }

    func testStatusUpdate_anyServerInfoPropertiesNonNil_showsConnectionDetails() throws {
        for serverInfo in [
            NetworkProtectionStatusServerInfo(serverLocation: nil, serverAddress: "123.123.123.123"),
            NetworkProtectionStatusServerInfo(serverLocation: serverAttributes(), serverAddress: nil),
            NetworkProtectionStatusServerInfo(serverLocation: serverAttributes(), serverAddress: "111.222.333.444")
        ] {
            serverInfoObserver.subject.send(serverInfo)
            try waitForPublisher(viewModel.$hasServerInfo, toEmit: true)
        }
    }

    // MARK: - Helpers

    private func whenStatusUpdate_connected() async {
        statusObserver.subject.send(.connected(connectedDate: Date()))
        await waitFor(condition: self.viewModel.isNetPEnabled)
    }

    private func whenStatusUpdate_notConnected() async {
        let nonConnectedCases: [ConnectionStatus] = [.disconnected, .disconnecting, .notConfigured, .reasserting]
        for current in nonConnectedCases {
            statusObserver.subject.send(current)
            await waitFor(condition: !self.viewModel.isNetPEnabled)
        }
    }

    private func waitFor(condition: @escaping @autoclosure () -> Bool) async {
        let predicate = NSPredicate { _, _ in
            condition()
        }
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: nil)
        await fulfillment(of: [expectation], timeout: 20)
    }

    private func serverAttributes() -> NetworkProtectionServerInfo.ServerAttributes {
        let json = """
        {
            "city": "El Segundo",
            "country": "us",
            "latitude": 33.9192,
            "longitude": -118.4165,
            "region": "North America",
            "state": "ca",
            "tzOffset": -28800
        }
        """

        // swiftlint:disable:next force_try
        return try! JSONDecoder().decode(NetworkProtectionServerInfo.ServerAttributes.self, from: json.data(using: .utf8)!)
    }

}
