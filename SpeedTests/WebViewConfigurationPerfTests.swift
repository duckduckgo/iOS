//
//  WebViewConfigurationPerfTests.swift
//  DuckDuckGo
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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
import WebKit

@testable import DuckDuckGo
@testable import Core

class WebViewConfigurationPerfTests: XCTestCase {
    
    override func setUp() {
        loadBlockingLists()
    }

    func testLoadingScriptsPerformance() {
        
        let contentBlocker = ContentBlocker()
        
        // Warm up
        let configuration = WKWebViewConfiguration.nonPersistent()
        configuration.loadScripts(contentBlocker: contentBlocker, contentBlockingEnabled: true)
        
        measureMetrics([.wallClockTime], automaticallyStartMeasuring: false) {
            let configuration = WKWebViewConfiguration.nonPersistent()
            
            startMeasuring()
            configuration.loadScripts(contentBlocker: contentBlocker, contentBlockingEnabled: true)
            stopMeasuring()
        }
    }

}
