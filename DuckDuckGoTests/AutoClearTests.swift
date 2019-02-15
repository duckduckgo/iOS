//
//  AutoClearTests.swift
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

class AutoClearTests: XCTestCase {
    
    class MockWorker: AutoClearWorker {
        
        var forgetDataInvocationCount = 0
        var forgetTabsInvocationCount = 0
        
        func forgetData() {
            forgetDataInvocationCount += 1
        }
        
        func forgetTabs() {
            forgetTabsInvocationCount += 1
        }
    }
    
    private var worker: MockWorker!
    private var logic: AutoClear!

    override func setUp() {
        worker = MockWorker()
        logic = AutoClear(worker: worker)
    }
    
    func testWhenModeIsSetToCleanDataThenDataIsCleared() {
        let appSettings = AppUserDefaults()
        appSettings.autoClearAction = .clearData
        appSettings.autoClearTiming = .termination
        
        logic.applicationDidLaunch()
        
        XCTAssertEqual(worker.forgetDataInvocationCount, 1)
        XCTAssertEqual(worker.forgetTabsInvocationCount, 0)
    }
    
    func testWhenModeIsSetToCleanTabsAndDataThenDataIsCleared() {
        let appSettings = AppUserDefaults()
        appSettings.autoClearAction = [.clearData, .clearTabs]
        appSettings.autoClearTiming = .termination
        
        logic.applicationDidLaunch()
        
        XCTAssertEqual(worker.forgetDataInvocationCount, 1)
        
        // Tabs are cleared when loading TabsModel for the first time
        XCTAssertEqual(worker.forgetTabsInvocationCount, 0)
    }
    
    func testWhenModeIsNotSetThenNothingIsCleared() {
        let appSettings = AppUserDefaults()
        appSettings.autoClearAction = []
        appSettings.autoClearTiming = .termination
        
        logic.applicationDidLaunch()
        
        XCTAssertEqual(worker.forgetDataInvocationCount, 0)
        XCTAssertEqual(worker.forgetTabsInvocationCount, 0)
    }
    
    func testWhenTimingIsSetToTerminationThenOnlyRestartClearsData() {
        let appSettings = AppUserDefaults()
        appSettings.autoClearAction = .clearData
        appSettings.autoClearTiming = .termination
        
        logic.applicationWillMoveToForeground()
        logic.applicationDidEnterBackground()
        
        XCTAssertEqual(worker.forgetDataInvocationCount, 0)
        
        logic.applicationDidLaunch()
        
        XCTAssertEqual(worker.forgetDataInvocationCount, 1)
    }
    
    func testWhenDesiredTimingIsSetThenDataIsClearedOnceThimeHasElapsed() {
        let appSettings = AppUserDefaults()
        appSettings.autoClearAction = .clearData
        
        let cases: [AutoClearSettingsModel.Timing: TimeInterval] = [.delay5min: 5 * 60,
                                                                    .delay15min: 15 * 60,
                                                                    .delay30min: 30 * 60,
                                                                    .delay60min: 60 * 60]
        
        var iterationCount = 0
        for (timing, delay) in cases {
            appSettings.autoClearTiming = timing
            
            logic.applicationDidEnterBackground(CACurrentMediaTime() - delay + 1)
            logic.applicationWillMoveToForeground()
            
            XCTAssertEqual(worker.forgetDataInvocationCount, iterationCount)
            
            logic.applicationDidEnterBackground(CACurrentMediaTime() - delay - 1)
            logic.applicationWillMoveToForeground()
            
            iterationCount += 1
            XCTAssertEqual(worker.forgetDataInvocationCount, iterationCount)
        }
    }
}
