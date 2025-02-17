//
//  NetworkProtectionDNSSettingsViewModelTests.swift
//  DuckDuckGo
//
//  Copyright © 2025 DuckDuckGo. All rights reserved.
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
@testable import DuckDuckGo

final class NetworkProtectionDNSSettingsViewModelTests: XCTestCase {

    var model: NetworkProtectionDNSSettingsViewModel!
    let userDefaults = UserDefaults(suiteName: "TestDefaults")!
    var vpnSettings: VPNSettings!

    override func setUpWithError() throws {
        vpnSettings = VPNSettings(defaults: userDefaults)
        model = NetworkProtectionDNSSettingsViewModel(settings: vpnSettings, controller: MockTunnelController(), featureFlagger: MockFeatureFlagger())
    }

    override func tearDownWithError() throws {
        userDefaults.removePersistentDomain(forName: "TestDefaults")
        vpnSettings = nil
        model = nil
    }

    func testInitialState() {
        XCTAssertEqual(model.dnsSettings, vpnSettings.dnsSettings)
        XCTAssertFalse(model.isCustomDNSSelected)
        XCTAssertEqual(model.customDNSServers, vpnSettings.customDnsServers.joined(separator: ", "))
        XCTAssertTrue(model.isBlockRiskyDomainsOn)
    }

    func test_WhenUpdateDNSSettingsToCustomThenPropagatesToVpnSettings() {
        // GIVEN
        model.customDNSServers = "1.1.1.1"
        model.isCustomDNSSelected = true

        // WHEN
        model.applyDNSSettings()

        // THEN
        switch vpnSettings.dnsSettings {
        case .custom(let servers):
            XCTAssertEqual(servers, ["1.1.1.1"], "Custom DNS servers should be updated correctly.")
        default:
            XCTFail("Expected dnsSettings to be .custom, but got \(vpnSettings.dnsSettings)")
        }
    }

    func test_WhenUpdateDNSSettingsToDefaultWithThenPropagatesToVpnSettings() {
        // GIVEN
        model.isCustomDNSSelected = false
        model.isBlockRiskyDomainsOn = true

        // WHEN
        model.applyDNSSettings()

        // THEN
        switch vpnSettings.dnsSettings {
        case .ddg(let blockRiskyDomains):
            XCTAssertTrue(blockRiskyDomains, "Expected blockRiskyDomains to be false.")
        default:
            XCTFail("Expected dnsSettings to be .ddg, but got \(vpnSettings.dnsSettings)")
        }
    }

    func test_WhenUpdateDNSSettingsToDefaultWithBlockOffThenPropagatesToVpnSettings() {
        // GIVEN
        model.isCustomDNSSelected = false
        model.isBlockRiskyDomainsOn = false

        // WHEN
        model.applyDNSSettings()

        // THEN
        switch vpnSettings.dnsSettings {
        case .ddg(let blockRiskyDomains):
            XCTAssertFalse(blockRiskyDomains, "Expected blockRiskyDomains to be false.")
        default:
            XCTFail("Expected dnsSettings to be .ddg, but got \(vpnSettings.dnsSettings)")
        }
    }

    func test_WhenMovingFromDefaultToCustomAndBackToDefaultThenBlockSettingRetainedToFalse() {
        // GIVEN
        model.isCustomDNSSelected = false
        model.isBlockRiskyDomainsOn = false
        model.applyDNSSettings()
        model.isCustomDNSSelected = true
        model.customDNSServers = "1.1.1.1"
        model.applyDNSSettings()

        // WHEN
        model.isCustomDNSSelected = false
        model.applyDNSSettings()

        // THEN
        switch vpnSettings.dnsSettings {
        case .ddg(let blockRiskyDomains):
            XCTAssertFalse(blockRiskyDomains, "Expected blockRiskyDomains to be false.")
        default:
            XCTFail("Expected dnsSettings to be .ddg, but got \(vpnSettings.dnsSettings)")
        }
    }

    func test_WhenMovingFromDefaultToCustomAndBackToDefaultThenBlockSettingRetainedToTrue() {
        // GIVEN
        model.isCustomDNSSelected = false
        model.isBlockRiskyDomainsOn = true
        model.applyDNSSettings()
        model.isCustomDNSSelected = true
        model.customDNSServers = "1.1.1.1"
        model.applyDNSSettings()

        // WHEN
        model.isCustomDNSSelected = false
        model.applyDNSSettings()

        // THEN
        switch vpnSettings.dnsSettings {
        case .ddg(let blockRiskyDomains):
            XCTAssertTrue(blockRiskyDomains, "Expected blockRiskyDomains to be true.")
        default:
            XCTFail("Expected dnsSettings to be .ddg, but got \(vpnSettings.dnsSettings)")
        }
    }

    func test_WhenMovingFromCustomToDefaultAndBackToCustomThenPreviouslySelectedServerRetained() {
        // GIVEN
        model.isCustomDNSSelected = true
        model.customDNSServers = "1.1.1.1"
        model.applyDNSSettings()
        model.isCustomDNSSelected = false
        model.applyDNSSettings()

        // WHEN
        model.isCustomDNSSelected = true
        model.applyDNSSettings()

        // THEN
        switch vpnSettings.dnsSettings {
        case .custom(let servers):
            XCTAssertEqual(servers, ["1.1.1.1"], "Custom DNS servers should be updated correctly.")
        default:
            XCTFail("Expected dnsSettings to be .custom, but got \(vpnSettings.dnsSettings)")
        }
    }

    func testWhenUpdateDNSSettingsToCustomAndNoServerProvidedPreviousDnsSettingApplies() {
        // GIVEN
        model.isCustomDNSSelected = false
        model.applyDNSSettings()
        let previousDNS = vpnSettings.dnsSettings

        // WHEN
        model.customDNSServers = ""
        model.isCustomDNSSelected = true
        model.applyDNSSettings()

        // THEN
        XCTAssertEqual(vpnSettings.dnsSettings, previousDNS, "DNS settings should remain unchanged when no custom DNS is provided.")
    }

    func testToggleDNSSettings() {
        // GIVEN
        let initial = model.isCustomDNSSelected

        // WHEN
        model.toggleDNSSettings()

        // THEN
        XCTAssertEqual(model.isCustomDNSSelected, !initial, "toggleDNSSettings should invert the value.")
    }

    func testToggleIsBlockRiskyDomainsOn() {
        // GIVEN
        let initial = model.isBlockRiskyDomainsOn

        // WHEN
        model.toggleIsBlockRiskyDomainsOn()

        // THEN
        XCTAssertEqual(model.isBlockRiskyDomainsOn, !initial, "toggleIsBlockRiskyDomainsOn should invert the value.")
    }

    func testUpdateApplyButtonStateWhenValid() {
        // GIVEN
        model.isCustomDNSSelected = true
        model.customDNSServers = "1.1.1.1"

        // WHEN
        model.updateApplyButtonState()

        // THEN
        XCTAssertTrue(model.isApplyButtonEnabled, "Apply button should be enabled for valid custom DNS.")
    }

    func testUpdateApplyButtonStateWhenInvalid() {
        // GIVEN
        model.isCustomDNSSelected = true
        model.customDNSServers = "invalid"

        // WHEN
        model.updateApplyButtonState()

        // THEN
        XCTAssertFalse(model.isApplyButtonEnabled, "Apply button should be disabled for invalid custom DNS.")
    }

    func testUpdateApplyButtonStateWhenDefault() {
        // GIVEN
        model.isCustomDNSSelected = false

        // WHEN
        model.updateApplyButtonState()

        // THEN
        XCTAssertTrue(model.isApplyButtonEnabled, "Apply button should be enabled in default mode.")
    }

}

private final class MockTunnelController: TunnelController {
    func start() async {
    }

    func stop() async {
    }

    func command(_ command: NetworkProtection.VPNCommand) async throws {
    }

    var isConnected: Bool = false
}
