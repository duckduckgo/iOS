//
//  UsageSegmentationTests.swift
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

import Foundation
import XCTest
@testable import Core

class UsageSegmentationTests: XCTestCase {

    var defaultCalculatorResult: [String: String]? = [:]
    var atbs: [Atb] = []

    override func tearDown() {
        super.tearDown()
        PixelFiringMock.tearDown()
    }

    /// Activity type is not relevant here, that's tested elsewhere.
    func testWhenValidATBReceivedAndCalculatorReturnsNoResult_ThenNoPixelFired() {
        
        defaultCalculatorResult = nil

        let sut = makeSubject()

        let installAtb = Atb(version: "v100-1", updateVersion: nil)
        let atb = Atb(version: "v100-2", updateVersion: nil)
        sut.processATB(atb, withInstallAtb: installAtb, andActivityType: .search)

        XCTAssertEqual(atbs, [installAtb, atb])
        XCTAssertNil(PixelFiringMock.lastDailyPixelInfo?.pixel)

    }

    func testWhenSearchATBReceivedWithSameInstallAtbThatHasVariant_ThenStoredAndPixelFired() {
        assertWhenATBReceivedWithSameInstallAtb_ThenStoredAndPixelFired(.search,
                                                                          installAtb: "v123-1ru",
                                                                          atb: "v123-1")
    }

    func testWhenAppATBReceivedWithSameInstallAtbThatHasVariant_ThenStoredAndPixelFired() {
        assertWhenATBReceivedWithSameInstallAtb_ThenStoredAndPixelFired(.appUse,
                                                                          installAtb: "v123-1ru",
                                                                          atb: "v123-1")
    }

    func testWhenAppATBReceivedWithSameInstallAtb_ThenStoredAndPixelFired() {
        assertWhenATBReceivedWithSameInstallAtb_ThenStoredAndPixelFired(.appUse)
    }

    func testWhenSearchATBReceivedWithSameInstallAtb_ThenStoredAndPixelFired() {
        assertWhenATBReceivedWithSameInstallAtb_ThenStoredAndPixelFired(.search)
    }

    func testWhenNewAppATBReceivedWithInstallAtb_ThenBothStoredAndPixelFired() {
        assertWhenNewATBReceivedWithInstallAtb_ThenBothStoredAndPixelFired(.appUse)
    }

    func testWhenNewSearchATBReceivedWithInstallAtb_ThenBothStoredAndPixelFired() {
        assertWhenNewATBReceivedWithInstallAtb_ThenBothStoredAndPixelFired(.search)
    }

    func testWhenSearchActvityATBReceivedTwice_ThenNotStoredAndNoPixelFired() {
        assertWhenATBReceivedTwice_ThenNotStoredAndNoPixelFired(.search)
    }

    func testWhenAppActvityATBReceivedTwice_ThenNotStoredAndNoPixelFired() {
        assertWhenATBReceivedTwice_ThenNotStoredAndNoPixelFired(.appUse)
    }

    private func assertWhenATBReceivedWithSameInstallAtb_ThenStoredAndPixelFired(_ activityType: UsageActivityType, installAtb: String = "v100-1", atb: String = "v100-1", file: StaticString = #filePath, line: UInt = #line) {

        let sut = makeSubject()

        let installAtb = Atb(version: installAtb, updateVersion: nil)
        let atb = Atb(version: atb, updateVersion: nil)
        sut.processATB(atb, withInstallAtb: installAtb, andActivityType: activityType)

        XCTAssertEqual(atbs, [installAtb])
        XCTAssertEqual(Pixel.Event.usageSegments, PixelFiringMock.lastDailyPixelInfo?.pixel, file: file, line: line)
    }

    private func assertWhenNewATBReceivedWithInstallAtb_ThenBothStoredAndPixelFired(_ activityType: UsageActivityType, file: StaticString = #filePath, line: UInt = #line) {
        let sut = makeSubject()

        let installAtb = Atb(version: "v100-1", updateVersion: nil)
        let atb = Atb(version: "v100-2", updateVersion: nil)
        sut.processATB(atb, withInstallAtb: installAtb, andActivityType: activityType)

        XCTAssertEqual(atbs, [installAtb, atb], file: file, line: line)
        XCTAssertEqual(Pixel.Event.usageSegments, PixelFiringMock.lastDailyPixelInfo?.pixel, file: file, line: line)
    }

    private func assertWhenATBReceivedTwice_ThenNotStoredAndNoPixelFired(_ activityType: UsageActivityType, file: StaticString = #filePath, line: UInt = #line) {
        let sut = makeSubject()

        let installAtb = Atb(version: "v100-1", updateVersion: nil)
        let atb = Atb(version: "v100-2", updateVersion: nil)
        self.atbs = [installAtb, atb]
        sut.processATB(atb, withInstallAtb: installAtb, andActivityType: activityType)

        XCTAssertEqual(atbs, [installAtb, atb], file: file, line: line)
        XCTAssertNil(PixelFiringMock.lastDailyPixelInfo?.pixel, file: file, line: line)
    }

    private func makeSubject() -> UsageSegmenting {
        return UsageSegmentation(pixelFiring: PixelFiringMock.self, storage: self, calculatorFactory: self)
    }

}

extension UsageSegmentationTests: UsageSegmentationStoring {

}

extension UsageSegmentationTests: UsageSegmentationCalculatorMaking {

    func make(installAtb: Atb) -> any UsageSegmentationCalculating {
        return MockUsageSegmentationCalculator(installAtb, defaultCalculatorResult)
    }

}

class MockUsageSegmentationCalculator: UsageSegmentationCalculating {

    let installAtb: Atb
    let result: [String: String]?
    init(_ installAtb: Atb, _ result: [String: String]?) {
        self.installAtb = installAtb
        self.result = result
    }

    func processAtb(_ atb: Atb, forActivityType activityType: UsageActivityType) -> [String: String]? {
        return result
    }

}
