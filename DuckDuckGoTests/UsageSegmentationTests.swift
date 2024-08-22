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

    func testWhenAppATBReceivedWithSameInstallAtb_ThenStoredAndPixelFired() {
        assertWhenATBReceivedWithSameInstallAtb_ThenStoredAndPixelFired(.app)
    }

    func testWhenSearchATBReceivedWithSameInstallAtb_ThenStoredAndPixelFired() {
        assertWhenATBReceivedWithSameInstallAtb_ThenStoredAndPixelFired(.search)
    }

    func testWhenNewAppATBReceivedWithInstallAtb_ThenBothStoredAndPixelFired() {
        assertWhenNewATBReceivedWithInstallAtb_ThenBothStoredAndPixelFired(.app)
    }

    func testWhenNewSearchATBReceivedWithInstallAtb_ThenBothStoredAndPixelFired() {
        assertWhenNewATBReceivedWithInstallAtb_ThenBothStoredAndPixelFired(.search)
    }

    func testWhenSearchActvityATBReceivedTwice_ThenNotStoredAndNoPixelFired() {
        assertWhenATBReceivedTwice_ThenNotStoredAndNoPixelFired(.search)
    }

    func testWhenAppActvityATBReceivedTwice_ThenNotStoredAndNoPixelFired() {
        assertWhenATBReceivedTwice_ThenNotStoredAndNoPixelFired(.app)
    }

    private func assertWhenATBReceivedWithSameInstallAtb_ThenStoredAndPixelFired(_ activityType: UsageActivityType, file: StaticString = #filePath, line: UInt = #line) {

        let sut = UsageSegmentation(pixelFiring: PixelFiringMock.self, storage: self)

        let installAtb = Atb(version: "v100-1", updateVersion: nil)
        let atb = Atb(version: "v100-1", updateVersion: nil)
        sut.processATB(atb, withInstallAtb: installAtb, andActivityType: activityType)

        XCTAssertEqual(atbs, [installAtb])
        XCTAssertEqual(Pixel.Event.usageSegments, PixelFiringMock.lastDailyPixelInfo?.pixel)
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

final class MockUsageSegmentation: UsageSegmenting {

    struct ProcessATBArgs {

        let atb: Atb
        let installAtb: Atb
        let activityType: UsageActivityType

    }

    var atbs: [ProcessATBArgs] = []

    func processATB(_ atb: Atb, withInstallAtb installAtb: Atb, andActivityType activityType: UsageActivityType) {
        atbs.append(ProcessATBArgs(atb: atb, installAtb: installAtb, activityType: activityType))
    }
}
