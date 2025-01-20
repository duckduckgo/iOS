//
//  PageRefreshMonitorExtensionTests.swift
//  DuckDuckGo
//
//  Copyright © 2025 DuckDuckGo. All rights reserved.
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
@testable import PixelExperimentKit
import PageRefreshMonitor
import BrowserServicesKit

final class PageRefreshMonitorExtensionTests: XCTestCase {

    var capturedSubfeatureID: String?
    var captureMetric: String?

    override func setUpWithError() throws {
        TDSOverrideExperimentMetrics.configureTDSOverrideExperimentMetrics { subfeatureID, metric, _, _ in
            self.capturedSubfeatureID = subfeatureID
            self.captureMetric = metric
        }
    }

    override func tearDownWithError() throws {
        capturedSubfeatureID = nil
        captureMetric = nil
    }

    func test_OnDidDetectRefreshPattern_WithValue1_FireExperimentFuncNotCalled() throws {
        PageRefreshMonitor.onDidDetectRefreshPattern(1)

        XCTAssertNil(capturedSubfeatureID)
        XCTAssertNil(captureMetric)
    }

}
