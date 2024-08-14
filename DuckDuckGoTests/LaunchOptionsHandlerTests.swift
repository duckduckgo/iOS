//
//  LaunchOptionsHandlerTests.swift
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
@testable import Core

final class LaunchOptionsHandlerTests: XCTestCase {
    private static let suiteName = "testing_launchOptionsHandler"
    private var userDefaults: UserDefaults!

    override func setUpWithError() throws {
        try super.setUpWithError()
        userDefaults = UserDefaults(suiteName: Self.suiteName)
    }

    override func tearDownWithError() throws {
        userDefaults.removePersistentDomain(forName: Self.suiteName)
        userDefaults = nil
        try super.tearDownWithError()
    }

    // MARK: - isUITesting

    func testShouldReturnTrueWhenIsUITestingIsCalledAndLaunchArgumentContainsIsUITesting() {
        // GIVEN
        let launchArguments = ["isUITesting"]
        let sut = LaunchOptionsHandler(launchArguments: launchArguments, userDefaults: userDefaults)

        // WHEN
        let result = sut.isUITesting

        // THEN
        XCTAssertTrue(result)
    }

    func testShouldReturnFalseWhenIsUITestingIsCalledAndLaunchArgumentsDoesNotContainIsUITesting() {
        // GIVEN
        let sut = LaunchOptionsHandler(launchArguments: [], userDefaults: userDefaults)

        // WHEN
        let result = sut.isUITesting

        // THEN
        XCTAssertFalse(result)
    }

    // MARK: - isOnboardingCompleted

    func testShouldReturnTrueWhenIsOnboardingCompletedAndDefaultsIsOnboardingCompletedIsTrue() {
        // GIVEN
        userDefaults.set("true", forKey: "isOnboardingCompleted")
        let sut = LaunchOptionsHandler(launchArguments: [], userDefaults: userDefaults)

        // WHEN
        let result = sut.isOnboardingCompleted

        // THEN
        XCTAssertTrue(result)
    }

    func testShouldReturnTrueWhenIsOnboardingCompletedAndDefaultsIsOnboardingCompletedIsFalse() {
        // GIVEN
        userDefaults.removeObject(forKey: "isOnboardingCompleted")
        let sut = LaunchOptionsHandler(launchArguments: [], userDefaults: userDefaults)

        // WHEN
        let result = sut.isOnboardingCompleted

        // THEN
        XCTAssertFalse(result)
    }

    // MARK: - App Variant

    func testShouldReturnAppVariantWhenAppVariantIsCalledAndDefaultsContainsAppVariant() {
        // GIVEN
        userDefaults.set("mb", forKey: "currentAppVariant")
        let sut = LaunchOptionsHandler(launchArguments: [], userDefaults: userDefaults)

        // WHEN
        let result = sut.appVariantName

        // THEN
        XCTAssertEqual(result, "mb")
    }

    func testShouldReturnNilWhenAppVariantIsCalledAndDefaultsDoesNotContainsAppVariant() {
        // GIVEN
        userDefaults.removeObject(forKey: "currentAppVariant")
        let sut = LaunchOptionsHandler(launchArguments: [], userDefaults: userDefaults)

        // WHEN
        let result = sut.appVariantName

        // THEN
        XCTAssertNil(result)
    }

    func testShouldReturnNilWhenAppVariantIsCalledAndDefaultsContainsNullStringAppVariant() {
        // GIVEN
        userDefaults.set("null", forKey: "currentAppVariant")
        let sut = LaunchOptionsHandler(launchArguments: [], userDefaults: userDefaults)

        // WHEN
        let result = sut.appVariantName

        // THEN
        XCTAssertNil(result)
    }

    func testShouldReturnNilWhenAppVariantIsCalledAndisUITestingIsFalse() {
        // GIVEN
        userDefaults.removeObject(forKey: "isOnboardingCompleted")
        let sut = LaunchOptionsHandler(launchArguments: [], userDefaults: userDefaults)

        // WHEN
        let result = sut.appVariantName

        // THEN
        XCTAssertNil(result)
    }
}
