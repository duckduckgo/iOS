//
//  PrivacyConfigurationDataTests.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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
import CommonCrypto
@testable import Core

class PrivacyConfigurationDataTests: XCTestCase {

    private var data = JsonTestDataLoader()

    func testJSONParsing() {
        let jsonData = data.fromJsonFile("MockFiles/privacy-config-example.json")
        let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]

        let configData = PrivacyConfigurationData(json: json!)

        XCTAssertEqual(configData.unprotectedTemporary.count, 1)
        XCTAssertEqual(configData.unprotectedTemporary.first?.domain, "example.com")

        let gpcFeature = configData.features["contentBlocking"]
        XCTAssertNotNil(gpcFeature)
        XCTAssertEqual(gpcFeature?.state, "enabled")
        XCTAssertEqual(gpcFeature?.exceptions.first?.domain, "example.com")

        let exampleFeature = configData.features["exampleFeature"]
        XCTAssertEqual(exampleFeature?.state, "enabled")
        XCTAssertEqual((exampleFeature?.settings["dictValue"] as? [String: String])?["key"], "value")
        XCTAssertEqual((exampleFeature?.settings["arrayValue"] as? [String])?.first, "value")
        XCTAssertEqual((exampleFeature?.settings["stringValue"] as? String), "value")
        XCTAssertEqual((exampleFeature?.settings["numericalValue"] as? Int), 1)

        let allowlist = configData.trackerAllowlist
        XCTAssertEqual(allowlist.state, "enabled")
        let rulesMap = allowlist.entries.reduce(into: [String: [String]]()) { partialResult, entry in
            partialResult[entry.rule] = entry.domains
        }
        XCTAssertEqual(rulesMap["example.com/tracker.js"], ["test.com"])
        XCTAssertEqual(rulesMap["example2.com/path/"], ["<all>"])
        XCTAssertEqual(rulesMap["example2.com/resource.json"], ["<all>"])
    }

}
