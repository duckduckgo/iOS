//
//  AppVersionExtensionTests.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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
@testable import DuckDuckGo
@testable import Core
@testable import BrowserServicesKit

class AppVersionExtensionTests: XCTestCase {

    struct Constants {
        static let name = "DuckDuckGo"
        static let version = "2.0.4"
        static let build = "14"
    }

    private var mockBundle: MockBundle!
    private var testee: AppVersion!

    override func setUp() {
        super.setUp()
        
        mockBundle = MockBundle()
        testee = AppVersion(bundle: mockBundle)
    }

    func testVersionAndBuildContainsCorrectInformation() {
        mockBundle.add(name: AppVersion.Keys.name, value: Constants.name)
        mockBundle.add(name: AppVersion.Keys.versionNumber, value: Constants.version)
        mockBundle.add(name: AppVersion.Keys.buildNumber, value: Constants.build)
        XCTAssertEqual("2.0.4.14", testee.versionAndBuildNumber)
    }
    
    func testLocalisedTextContainsNameVersionAndBuild() {
        mockBundle.add(name: AppVersion.Keys.name, value: Constants.name)
        mockBundle.add(name: AppVersion.Keys.versionNumber, value: Constants.version)
        mockBundle.add(name: AppVersion.Keys.buildNumber, value: Constants.build)
        XCTAssertEqual("DuckDuckGo 2.0.4.14", testee.localized)
    }
}
