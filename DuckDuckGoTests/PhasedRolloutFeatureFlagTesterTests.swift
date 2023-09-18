//
//  PhasedRolloutFeatureFlagTesterTests.swift
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
import BrowserServicesKit
@testable import DuckDuckGo

private class MockPixelSender: PhasedRolloutPixelSender {

    enum MockPixelSenderError: Error {
        case mockPixelSenderError
    }

    let returnError: Bool
    var receivedPixelCall: Bool = false

    init(returnError: Bool = false) {
        self.returnError = returnError
    }

    func sendPixel(completion: @escaping (Error?) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.receivedPixelCall = true

            if self.returnError {
                completion(MockPixelSenderError.mockPixelSenderError)
            } else {
                completion(nil)
            }
        }
    }

}

final class PhasedRolloutFeatureFlagTesterTests: XCTestCase {

    private static let testSuiteName = "\(#file)"

    override func setUp() {
        super.setUp()

        let defaults = UserDefaults(suiteName: Self.testSuiteName)!
        defaults.removePersistentDomain(forName: Self.testSuiteName)
    }

    override func tearDown() {
        super.tearDown()

        let defaults = UserDefaults(suiteName: Self.testSuiteName)!
        defaults.removePersistentDomain(forName: Self.testSuiteName)
    }

    func testWhenAttemptingToSendPixel_AndRolloutSubfeatureIsDisabled_ThenPixelDoesNotSend() {
        let mockManager = MockPrivacyConfigurationManager()
        mockManager.privacyConfig = mockConfiguration(subfeatureEnabled: false)
        let pixelSender = MockPixelSender(returnError: false)
        let userDefaults = UserDefaults(suiteName: Self.testSuiteName)!

        let tester = PhasedRolloutFeatureFlagTester(privacyConfigurationManager: mockManager,
                                                    pixelSender: pixelSender,
                                                    userDefaults: userDefaults)

        let expectation = expectation(description: #function)
        tester.sendFeatureFlagEnabledPixelIfNecessary {
            expectation.fulfill()
        }
        wait(for: [expectation])

        XCTAssertFalse(pixelSender.receivedPixelCall)
        XCTAssertFalse(userDefaults.bool(forKey: PhasedRolloutFeatureFlagTester.Constants.hasSentPixelKey))
    }

    func testWhenAttemptingToSendPixel_AndRolloutSubfeatureIsEnabled_AndPixelHasNotBeenSentBefore_ThenPixelSends() {
        let mockManager = MockPrivacyConfigurationManager()
        mockManager.privacyConfig = mockConfiguration(subfeatureEnabled: true)
        let pixelSender = MockPixelSender(returnError: false)
        let userDefaults = UserDefaults(suiteName: Self.testSuiteName)!

        let tester = PhasedRolloutFeatureFlagTester(privacyConfigurationManager: mockManager,
                                                    pixelSender: pixelSender,
                                                    userDefaults: userDefaults)

        let expectation = expectation(description: #function)
        tester.sendFeatureFlagEnabledPixelIfNecessary {
            expectation.fulfill()
        }
        wait(for: [expectation])

        XCTAssert(pixelSender.receivedPixelCall)
        XCTAssert(userDefaults.bool(forKey: PhasedRolloutFeatureFlagTester.Constants.hasSentPixelKey))
    }

    func testWhenAttemptingToSendPixel_AndRolloutSubfeatureIsEnabled_AndPixelHasBeenSentBefore_ThenPixelDoesNotSend() {
        let mockManager = MockPrivacyConfigurationManager()
        mockManager.privacyConfig = mockConfiguration(subfeatureEnabled: true)
        let pixelSender = MockPixelSender(returnError: false)
        let userDefaults = UserDefaults(suiteName: Self.testSuiteName)!

        let tester = PhasedRolloutFeatureFlagTester(privacyConfigurationManager: mockManager,
                                                    pixelSender: pixelSender,
                                                    userDefaults: userDefaults)

        let firstExpectation = expectation(description: #function)
        tester.sendFeatureFlagEnabledPixelIfNecessary {
            firstExpectation.fulfill()
        }
        wait(for: [firstExpectation])

        XCTAssert(pixelSender.receivedPixelCall)
        XCTAssert(userDefaults.bool(forKey: PhasedRolloutFeatureFlagTester.Constants.hasSentPixelKey))

        // Test the second call:

        pixelSender.receivedPixelCall = false

        let secondExpectation = expectation(description: #function)
        tester.sendFeatureFlagEnabledPixelIfNecessary {
            secondExpectation.fulfill()
        }
        wait(for: [secondExpectation])

        XCTAssertFalse(pixelSender.receivedPixelCall)
        XCTAssert(userDefaults.bool(forKey: PhasedRolloutFeatureFlagTester.Constants.hasSentPixelKey))
    }

    // MARK: - Mock Creation

    private func mockConfiguration(subfeatureEnabled: Bool) -> PrivacyConfiguration {
        let mockPrivacyConfiguration = MockPrivacyConfiguration()
        mockPrivacyConfiguration.isSubfeatureKeyEnabled = { _, _ in
            return subfeatureEnabled
        }

        return mockPrivacyConfiguration
    }

}
