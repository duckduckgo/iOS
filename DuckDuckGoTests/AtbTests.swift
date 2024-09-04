//
//  AtbTests.swift
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
import Common
@testable import Core

class AtbTests: XCTestCase {

    func testEquality() {
        XCTAssertEqual(Atb(version: "", updateVersion: nil), Atb(version: "", updateVersion: nil))
        XCTAssertEqual(Atb(version: "v100-1", updateVersion: nil), Atb(version: "v100-1", updateVersion: nil))
        XCTAssertEqual(Atb(version: "v100-1ru", updateVersion: nil), Atb(version: "v100-1", updateVersion: nil))

        XCTAssertNotEqual(Atb(version: "v100-2", updateVersion: nil), Atb(version: "v100-1", updateVersion: nil))
        XCTAssertNotEqual(Atb(version: "v203-1", updateVersion: nil), Atb(version: "v100-1", updateVersion: nil))
        XCTAssertNotEqual(Atb(version: "v203-1", updateVersion: nil), Atb(version: "v100-1ru", updateVersion: nil))
    }

    func testAgeInDays() {
        XCTAssertEqual(Atb(version: "", updateVersion: nil).ageInDays, -1)
        XCTAssertEqual(Atb(version: "v000-0", updateVersion: nil).ageInDays, -1)
        XCTAssertEqual(Atb(version: "v000-8", updateVersion: nil).ageInDays, -1)

        XCTAssertEqual(Atb(version: "v000-1", updateVersion: nil).ageInDays, 0)
        XCTAssertEqual(Atb(version: "v000-7", updateVersion: nil).ageInDays, 6)
        XCTAssertEqual(Atb(version: "v001-1", updateVersion: nil).ageInDays, 7)
        XCTAssertEqual(Atb(version: "v100-1", updateVersion: nil).ageInDays, 700)
        XCTAssertEqual(Atb(version: "v100-7", updateVersion: nil).ageInDays, 706)
    }

    func testWeek() {
        XCTAssertEqual(Atb(version: "", updateVersion: nil).week, -1)
        XCTAssertEqual(Atb(version: "v000-7", updateVersion: nil).week, 0)
        XCTAssertEqual(Atb(version: "v100-7", updateVersion: nil).week, 100)
        XCTAssertEqual(Atb(version: "v200-7", updateVersion: nil).week, 200)
    }

    func testSubtractingAtbs() {
        XCTAssertEqual(Atb(version: "v100-7", updateVersion: nil) - Atb(version: "v100-7", updateVersion: nil), 0)
        XCTAssertEqual(Atb(version: "v100-7", updateVersion: nil) - Atb(version: "v100-2", updateVersion: nil), 5)
        XCTAssertEqual(Atb(version: "v101-1", updateVersion: nil) - Atb(version: "v100-7", updateVersion: nil), 1)
        XCTAssertEqual(Atb(version: "v101-1", updateVersion: nil) - Atb(version: "v201-1", updateVersion: nil), -700)
        XCTAssertEqual(Atb(version: "v201-1", updateVersion: nil) - Atb(version: "v101-1", updateVersion: nil), 700)
        XCTAssertEqual(Atb(version: "v201-7", updateVersion: nil) - Atb(version: "v123-1", updateVersion: nil), 552)
    }

    func testIsReturningUser() {
        XCTAssertFalse(Atb(version: "", updateVersion: nil).isReturningUser)
        XCTAssertFalse(Atb(version: "v100-1", updateVersion: nil).isReturningUser)
        XCTAssertFalse(Atb(version: "ru", updateVersion: nil).isReturningUser)
        XCTAssertFalse(Atb(version: "longatb-1ru", updateVersion: nil).isReturningUser)
        XCTAssertTrue(Atb(version: "v100-1ru", updateVersion: nil).isReturningUser)
    }

}
