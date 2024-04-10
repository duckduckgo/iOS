//
//  PixelExperimentTests.swift
//  UnitTests
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
@testable import Core

class PixelExperimentTests: XCTestCase {

    override func setUp() {
        super.setUp()

        PixelExperiment.cleanup()
        PixelExperiment.customLogic = nil
        PixelExperiment.install()
    }

    override func tearDown() {
        PixelExperiment.cleanup()
        PixelExperiment.customLogic = nil
        super.tearDown()
    }

    func testParametersWhenNoVariantAllocated() {
        PixelExperiment.customLogic = PixelExperimentLogic(fire: { _ in }, customCohort: .noVariant)
        let parameters = PixelExperiment.parameters

        XCTAssertTrue(parameters.isEmpty, "Expected parameters to be empty when no variant is allocated.")
    }

    func testExperimentInstallation() {
        PixelExperiment.cleanup()
        PixelExperiment.install()

        XCTAssertTrue(PixelExperiment.isExperimentInstalled, "The experiment should be marked as installed after calling install().")
    }

    func testCleanupResetsState() {
        PixelExperiment.install()
        PixelExperiment.cleanup()

        XCTAssertFalse(PixelExperiment.isExperimentInstalled, "The experiment should not be marked as installed after cleanup.")
        XCTAssertNil(PixelExperiment.cohort, "There should be no cohort allocated after cleanup.")
    }

    func testAllocatedCohortMatchesCurrentCohorts() {
        PixelExperiment.customLogic = PixelExperimentLogic(fire: { _ in }, customCohort: .control)

        let matches = !PixelExperiment.allocatedCohortDoesNotMatchCurrentCohorts

        XCTAssertTrue(matches, "The allocated cohort should match")
    }

    func testPixelFiredOnEnrolment() {
        var fireCalled = false
        let logic = PixelExperimentLogic(fire: { pixel in
            XCTAssertEqual(pixel, Pixel.Event.pixelExperimentEnrollment, "Expected pixelExperimentEnrollment pixel to be fired upon enrollment")
            fireCalled = true
        })

        logic.install()
        let cohort = logic.cohort

        XCTAssertNotNil(logic.cohort, "Expected a cohort to be allocated")

        if cohort != .noVariant {
            XCTAssert(fireCalled, "Pixel have to be fired in case a variant is assigned")
        }
    }

}
