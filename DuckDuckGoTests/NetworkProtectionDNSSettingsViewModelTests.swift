////
////  NetworkProtectionDNSSettingsViewModelTests.swift
////  DuckDuckGo
////
////  Copyright © 2025 DuckDuckGo. All rights reserved.
////
////  Licensed under the Apache License, Version 2.0 (the "License");
////  you may not use this file except in compliance with the License.
////  You may obtain a copy of the License at
////
////  http://www.apache.org/licenses/LICENSE-2.0
////
////  Unless required by applicable law or agreed to in writing, software
////  distributed under the License is distributed on an "AS IS" BASIS,
////  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
////  See the License for the specific language governing permissions and
////  limitations under the License.
////
//
//import XCTest
//import NetworkProtection
//@testable import DuckDuckGo
//
//final class NetworkProtectionDNSSettingsViewModelTests: XCTestCase {
//
//    var model: NetworkProtectionDNSSettingsViewModel!
//    let userDefaults = UserDefaults(suiteName: "TestDefaults")!
//    var vpnSettings: VPNSettings!
//
//    override func setUpWithError() throws {
//        vpnSettings = VPNSettings(defaults: userDefaults)
//        model = NetworkProtectionDNSSettingsViewModel(settings: vpnSettings, controller: MockTunnelController(), featureFlagger: MockFeatureFlagger())
//    }
//
//    override func tearDownWithError() throws {
//        userDefaults.removePersistentDomain(forName: "TestDefaults")
//        vpnSettings = nil
//        model = nil
//    }
//
//    func testInitialState() {
//        XCTAssertEqual(model.dnsSettings, vpnSettings.dnsSettings)
//        XCTAssertFalse(model.isCustomDNSSelected)
//        XCTAssertEqual(model.customDNSServers, vpnSettings.customDnsServers.joined(separator: ", "))
//        XCTAssertTrue(model.isBlockRiskyDomainsOn)
//    }
//
//    func test_WhenUpdateDNSSettingsToCustomThenPropagatesToVpnSettings() {
//        // WHEN
//        model.isCustomDNSSelected = true
//        model.customDNSServers = "1.1.1.1, 8.8.8.8"
//
//        // THEN
//        switch vpnSettings.dnsSettings {
//        case .custom(let servers):
//            XCTAssertEqual(servers, ["1.1.1.1", "8.8.8.8"], "Custom DNS servers should be updated correctly.")
//        default:
//            XCTFail("Expected dnsSettings to be .custom, but got \(vpnSettings.dnsSettings)")
//        }
//    }
//
//
//}
//
//final class MockTunnelController: TunnelController {
//    func start() async {
//    }
//
//    func stop() async {
//    }
//
//    func command(_ command: NetworkProtection.VPNCommand) async throws {
//    }
//
//    var isConnected: Bool = false
//}
