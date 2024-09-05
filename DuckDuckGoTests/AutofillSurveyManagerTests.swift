//
//  AutofillSurveyManagerTests.swift
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
import BrowserServicesKit
@testable import DuckDuckGo

final class AutofillSurveyManagerTests: XCTestCase {

    private var manager: AutofillSurveyManager!

    override func setUpWithError() throws {
        try super.setUpWithError()

        setupUserDefault(with: #file)
        manager = AutofillSurveyManager()
        manager.resetSurveys()
    }

    override func tearDownWithError() throws {
        manager.resetSurveys()
        manager = nil

        try super.tearDownWithError()
    }

    func testSurveyToPresentReturnsCorrectSurvey() {
        let settings: [String: Any] = [
            "surveys": [
                ["id": "1", "url": "https://example.com/survey1"],
                ["id": "2", "url": "https://example.com/survey2"]
            ]
        ]

        let survey = manager.surveyToPresent(settings: settings as PrivacyConfigurationData.PrivacyFeature.FeatureSettings)
        XCTAssertNotNil(survey)
        XCTAssertEqual(survey?.id, "1")
        XCTAssertEqual(survey?.url, "https://example.com/survey1")
    }

    func testSurveyToPresentSkipsCompletedSurveys() {
        let settings: [String: Any] = [
            "surveys": [
                ["id": "1", "url": "https://example.com/survey1"],
                ["id": "2", "url": "https://example.com/survey2"]
            ]
        ]

        manager.markSurveyAsCompleted(id: "1")

        let survey = manager.surveyToPresent(settings: settings as PrivacyConfigurationData.PrivacyFeature.FeatureSettings)
        XCTAssertNotNil(survey)
        XCTAssertEqual(survey?.id, "2")
        XCTAssertEqual(survey?.url, "https://example.com/survey2")
    }

    func testBuildSurveyUrlValid() {
        let url = "https://example.com/survey"
        let accountsCount = 5
        let resultUrl = manager.buildSurveyUrl(url, accountsCount: accountsCount)
        XCTAssertNotNil(resultUrl)
        XCTAssertEqual(resultUrl?.host, "example.com")
        XCTAssertTrue(resultUrl?.query?.contains("saved_passwords=some") ?? false)
    }

    func testAddPasswordsCountSurveyParameter() {
        let baseURL = URL(string: "https://example.com/survey")!
        let modifiedURL = manager.buildSurveyUrl(baseURL.absoluteString, accountsCount: 10)
        XCTAssertNotNil(modifiedURL)
        XCTAssertEqual(modifiedURL?.query?.contains("saved_passwords=some"), true)
    }

    func testPasswordsCountHasCorrectBucketNameSurveyParameter() {
        let baseURL = URL(string: "https://example.com/survey")!
        var modifiedURL = manager.buildSurveyUrl(baseURL.absoluteString, accountsCount: 0)
        XCTAssertEqual(modifiedURL?.query?.contains("saved_passwords=none"), true)

        modifiedURL = manager.buildSurveyUrl(baseURL.absoluteString, accountsCount: 1)
        XCTAssertEqual(modifiedURL?.query?.contains("saved_passwords=few"), true)

        modifiedURL = manager.buildSurveyUrl(baseURL.absoluteString, accountsCount: 3)
        XCTAssertEqual(modifiedURL?.query?.contains("saved_passwords=few"), true)

        modifiedURL = manager.buildSurveyUrl(baseURL.absoluteString, accountsCount: 4)
        XCTAssertEqual(modifiedURL?.query?.contains("saved_passwords=some"), true)

        modifiedURL = manager.buildSurveyUrl(baseURL.absoluteString, accountsCount: 10)
        XCTAssertEqual(modifiedURL?.query?.contains("saved_passwords=some"), true)

        modifiedURL = manager.buildSurveyUrl(baseURL.absoluteString, accountsCount: 11)
        XCTAssertEqual(modifiedURL?.query?.contains("saved_passwords=many"), true)

        modifiedURL = manager.buildSurveyUrl(baseURL.absoluteString, accountsCount: 49)
        XCTAssertEqual(modifiedURL?.query?.contains("saved_passwords=many"), true)

        modifiedURL = manager.buildSurveyUrl(baseURL.absoluteString, accountsCount: 50)
        XCTAssertEqual(modifiedURL?.query?.contains("saved_passwords=lots"), true)

        modifiedURL = manager.buildSurveyUrl(baseURL.absoluteString, accountsCount: 100)
        XCTAssertEqual(modifiedURL?.query?.contains("saved_passwords=lots"), true)
    }
}
