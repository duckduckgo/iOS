//
//  DefaultContextualTipsStorageTests.swift
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
@testable import DuckDuckGo

class DefaultContextualTipsStorageTests: XCTestCase {
    
    var testee: DefaultContextualTipsStorage!
    let testGroupName = "test"
    
    var userDefaults: UserDefaults {
        return UserDefaults(suiteName: testGroupName)!
    }
    
    override func setUp() {
        userDefaults.removePersistentDomain(forName: testGroupName)
        testee = DefaultContextualTipsStorage(userDefaults: userDefaults)
    }
    
    func testWhenFirstCreatedThenNextTipsAreZero() {
        XCTAssertEqual(0, testee.nextHomeScreenTip)
        XCTAssertEqual(0, testee.nextBrowsingTip)
    }
    
    func testWhenIncrementedThenNextTipsAreStored() {
        
        testee.nextHomeScreenTip += 1
        testee.nextBrowsingTip += 1
        
        testee = DefaultContextualTipsStorage(userDefaults: userDefaults)
        XCTAssertEqual(1, testee.nextHomeScreenTip)
        XCTAssertEqual(1, testee.nextBrowsingTip)
        
    }
        
}
