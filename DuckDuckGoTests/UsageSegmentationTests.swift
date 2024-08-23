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

    var atbs: [Atb] = []

    override func tearDown() {
        super.tearDown()
        PixelFiringMock.tearDown()
    }

    func testWhenAppATBReceivedWithSameInstallAtbThatHasVariant_ThenStoredAndNoPixelFired() {
        assertWhenATBReceivedWithSameInstallAtb_ThenStoredAndNoPixelFired(.appUse,
                                                                          installAtb: "v123-1ru",
                                                                          atb: "v123-1")
    }

    func testWhenAppATBReceivedWithSameInstallAtb_ThenStoredAndNoPixelFired() {
        assertWhenATBReceivedWithSameInstallAtb_ThenStoredAndNoPixelFired(.appUse)
    }

    func testWhenSearchATBReceivedWithSameInstallAtb_ThenStoredAndNoPixelFired() {
        assertWhenATBReceivedWithSameInstallAtb_ThenStoredAndNoPixelFired(.search)
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

    private func assertWhenATBReceivedWithSameInstallAtb_ThenStoredAndNoPixelFired(_ activityType: UsageActivityType, installAtb: String = "v100-1", atb: String = "v100-1", file: StaticString = #filePath, line: UInt = #line) {

        let sut = UsageSegmentation(pixelFiring: PixelFiringMock.self, storage: self)

        let installAtb = Atb(version: installAtb, updateVersion: nil)
        let atb = Atb(version: atb, updateVersion: nil)
        sut.processATB(atb, withInstallAtb: installAtb, andActivityType: activityType)

        XCTAssertEqual(atbs, [installAtb])
        XCTAssertNil(PixelFiringMock.lastDailyPixelInfo?.pixel)
    }

    private func assertWhenNewATBReceivedWithInstallAtb_ThenBothStoredAndPixelFired(_ activityType: UsageActivityType, file: StaticString = #filePath, line: UInt = #line) {
        let sut = UsageSegmentation(pixelFiring: PixelFiringMock.self, storage: self)

        let installAtb = Atb(version: "v100-1", updateVersion: nil)
        let atb = Atb(version: "v100-2", updateVersion: nil)
        sut.processATB(atb, withInstallAtb: installAtb, andActivityType: activityType)

        XCTAssertEqual(atbs, [installAtb, atb], file: file, line: line)
        XCTAssertEqual(Pixel.Event.usageSegments, PixelFiringMock.lastDailyPixelInfo?.pixel, file: file, line: line)
    }

    private func assertWhenATBReceivedTwice_ThenNotStoredAndNoPixelFired(_ activityType: UsageActivityType, file: StaticString = #filePath, line: UInt = #line) {
        let sut = UsageSegmentation(pixelFiring: PixelFiringMock.self, storage: self)

        let installAtb = Atb(version: "v100-1", updateVersion: nil)
        let atb = Atb(version: "v100-2", updateVersion: nil)
        self.atbs = [installAtb, atb]
        sut.processATB(atb, withInstallAtb: installAtb, andActivityType: activityType)

        XCTAssertEqual(atbs, [installAtb, atb], file: file, line: line)
        XCTAssertNil(PixelFiringMock.lastDailyPixelInfo?.pixel, file: file, line: line)
    }

}

extension UsageSegmentationTests: UsageSegmentationStoring {

}
