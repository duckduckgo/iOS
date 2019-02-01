//
//  AutoClearLogicTests.swift
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

class AutoClearLogicTests: XCTestCase {
    
    class MockWorker: AutoClearWorker {
        
        var forgetDataExpectation: XCTestExpectation?
        var forgetTabsExpectation: XCTestExpectation?
        
        func forgetData() {
            forgetDataExpectation?.fulfill()
        }
        
        func forgetTabs() {
            forgetTabsExpectation?.fulfill()
        }
    }
    
    private var worker: MockWorker!
    private var logic: AutoClearLogic!

    override func setUp() {
        worker = MockWorker()
        logic = AutoClearLogic(worker: worker)
    }
    
    func testWhenModeIsSetToCleanDataThenDataIsCleared() {
        let appSettings = AppUserDefaults()
        appSettings.autoClearMode = AutoClearDataSettings.Action.clearData.rawValue
        appSettings.autoClearTiming = AutoClearDataSettings.Timing.termination.rawValue
        
        worker.forgetDataExpectation = expectation(description: "Data Cleared")
        worker.forgetTabsExpectation = expectation(description: "Tabs Cleared")
        worker.forgetTabsExpectation?.isInverted = true
        
        logic.applicationDidLaunch()
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testWhenModeIsSetToCleanTabsThenTabsAreCleared() {
        let appSettings = AppUserDefaults()
        appSettings.autoClearMode = AutoClearDataSettings.Action.clearTabs.rawValue
        appSettings.autoClearTiming = AutoClearDataSettings.Timing.termination.rawValue
        
        worker.forgetDataExpectation = expectation(description: "Data Cleared")
        worker.forgetDataExpectation?.isInverted = true
        worker.forgetTabsExpectation = expectation(description: "Tabs Cleared")
        
        logic.applicationDidLaunch()
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testWhenModeIsSetToCleanTabsAndDataThenBothAreCleared() {
        let appSettings = AppUserDefaults()
        let mode: AutoClearDataSettings.Action = [.clearData, .clearTabs]
        appSettings.autoClearMode = mode.rawValue
        appSettings.autoClearTiming = AutoClearDataSettings.Timing.termination.rawValue
        
        worker.forgetDataExpectation = expectation(description: "Data Cleared")
        worker.forgetTabsExpectation = expectation(description: "Tabs Cleared")
        
        logic.applicationDidLaunch()
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testWhenModeIsNotSetThenNothingIsCleared() {
        let appSettings = AppUserDefaults()
        appSettings.autoClearMode = 0
        appSettings.autoClearTiming = AutoClearDataSettings.Timing.termination.rawValue
        
        worker.forgetDataExpectation = expectation(description: "Data Cleared")
        worker.forgetDataExpectation?.isInverted = true
        worker.forgetTabsExpectation = expectation(description: "Tabs Cleared")
        worker.forgetTabsExpectation?.isInverted = true
        
        logic.applicationDidLaunch()
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testWhenTimingIsSetToTerminationThenOnlyRestartClearsData() {
        let appSettings = AppUserDefaults()
        appSettings.autoClearMode = AutoClearDataSettings.Action.clearData.rawValue
        appSettings.autoClearTiming = AutoClearDataSettings.Timing.termination.rawValue
        
        worker.forgetDataExpectation = expectation(description: "Data should not be cleared")
        worker.forgetDataExpectation?.isInverted = true

        logic.applicationWillEnterForeground()
        logic.applicationDidEnterBackground()
        
        worker.forgetDataExpectation = expectation(description: "Data cleared")
        logic.applicationDidLaunch()
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testWhenDesiredTimingIsSetThenDataIsClearedOnceThimeHasElapsed() {
        let appSettings = AppUserDefaults()
        appSettings.autoClearMode = AutoClearDataSettings.Action.clearData.rawValue
        
        let cases: [AutoClearDataSettings.Timing: TimeInterval] = [.delay5min: 5 * 60,
                                                                    .delay15min: 15 * 60,
                                                                    .delay30min: 30 * 60,
                                                                    .delay60min: 60 * 60]
        
        for (timing, delay) in cases {
            appSettings.autoClearTiming = timing.rawValue
            
            worker.forgetDataExpectation = expectation(description: "Data not cleared")
            worker.forgetDataExpectation?.isInverted = true
            
            logic.applicationDidEnterBackground(CACurrentMediaTime() - delay + 1)
            logic.applicationWillEnterForeground()
            
            worker.forgetDataExpectation = expectation(description: "Data cleared")
            
            logic.applicationDidEnterBackground(CACurrentMediaTime() - delay - 1)
            logic.applicationWillEnterForeground()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}
