//
//  MarketplaceAdPostbackDeviceTests.swift
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

import XCTest
import StoreKitTest
@testable import Core
import Foundation

@available(iOS 16.4, *)
final class MarketplaceAdPostbackDeviceTests: XCTestCase {
    private var testSession: SKAdTestSession!

    override func setUpWithError() throws {
        testSession = SKAdTestSession()
        try super.setUpWithError()
    }

    func testSendingPostback_ForNewUser() throws {
        try setPostbacks()

        let mockReturnUserMeasurement = MockReturnUserMeasurement(isReturningUser: false)
        let mockUpdater = MarketplaceAdPostbackUpdater()
        let mockStorage = MockMarketplaceAdPostbackStorage(isReturningUser: false)
        let manager = MarketplaceAdPostbackManager(storage: mockStorage,
                                                   updater: mockUpdater,
                                                   returningUserMeasurement: mockReturnUserMeasurement)

        let expectation = XCTestExpectation(description: "Postback sent")

        manager.sendAppLaunchPostback {
            let fetchedPostbacks = self.testSession.postbacks
            XCTAssertEqual(fetchedPostbacks.count, 3, "Expecting 3 postbacks, received \(fetchedPostbacks.count).")

            if fetchedPostbacks.count >= 1 {
                let firstPostback = fetchedPostbacks[0]
                XCTAssertEqual(firstPostback.fineConversionValue, 0)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3.0)
    }

    func testSendingPostback_ForReturningNewUser() throws {
        try setPostbacks()

        let mockReturnUserMeasurement = MockReturnUserMeasurement(isReturningUser: true)
        let mockUpdater = MarketplaceAdPostbackUpdater()
        let mockStorage = MockMarketplaceAdPostbackStorage(isReturningUser: true)
        let manager = MarketplaceAdPostbackManager(storage: mockStorage,
                                                   updater: mockUpdater,
                                                   returningUserMeasurement: mockReturnUserMeasurement)

        let expectation = XCTestExpectation(description: "Postback sent")

        manager.sendAppLaunchPostback {
            let fetchedPostbacks = self.testSession.postbacks
            XCTAssertEqual(fetchedPostbacks.count, 3, "Expecting 3 postbacks, received \(fetchedPostbacks.count).")

            if fetchedPostbacks.count >= 1 {
                let firstPostback = fetchedPostbacks[0]
                XCTAssertEqual(firstPostback.fineConversionValue, 1)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3.0)
    }

    func testSendingPostback() throws {
        try setPostbacks()

        let mockReturnUserMeasurement = MockReturnUserMeasurement(isReturningUser: true)
        let mockUpdater = MarketplaceAdPostbackUpdater()
        let mockStorage = MockMarketplaceAdPostbackStorage(isReturningUser: true)
        let manager = MarketplaceAdPostbackManager(storage: mockStorage,
                                                   updater: mockUpdater,
                                                   returningUserMeasurement: mockReturnUserMeasurement)

        let expectation = XCTestExpectation(description: "Postback sent")

        manager.sendAppLaunchPostback {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3.0)

        /// This will actually make a remote call to the postbackURL
        testSession.flushPostbacks { responses, error in
            XCTAssertNil(error)
            guard let concreteResponses = responses else {
                XCTFail("No responses received.")
                return
            }
            for response in concreteResponses {
                let postbackResponse = response.value
                XCTAssertNil(postbackResponse.error)
                XCTAssertTrue(postbackResponse.didSucceed)
            }
        }
    }

    private func setPostbacks() throws {
        guard let testPostbacks = SKAdTestPostback.winningPostbacks(withVersion: .version4_0,
                                                                    adNetworkIdentifier: "com.apple.test-1",
                                                                    sourceIdentifier: "3120",
                                                                    appStoreItemIdentifier: 0,
                                                                    sourceAppStoreItemIdentifier: 525_463_029,
                                                                    sourceDomain: nil,
                                                                    fidelityType: 1,
                                                                    isRedownload: false,
                                                                    postbackURL: "https://duckduckgo.com/.well-known/skadnetwork/report-attribution") else {
            XCTFail("Failed to create postbacks.")
            return
        }
        try testSession.setPostbacks(testPostbacks)
    }

}
