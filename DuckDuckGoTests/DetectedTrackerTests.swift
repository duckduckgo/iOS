//
//  DetectedTrackerTests.swift
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
@testable import Core

class DetectedTrackerTests: XCTestCase {

    private struct Constants {
        static let aUrl = "www.example.com"
        static let anotherUrl = "www.anotherurl.com"
        static let aParentDomain = "adomain.com"
        static let anotherParentDomain = "anotherdomain.com"
    }

    func testWhenTrackersHaveSameEntityThenHashMatchesAndIsEqualsIsTrue() {
        
        let entity1 = Entity(displayName: "Entity", domains: nil, prevalence: nil)
        let entity2 = Entity(displayName: "Entity", domains: [ Constants.aParentDomain ], prevalence: 1)

        let tracker1 = DetectedTracker(url: Constants.aUrl, knownTracker: nil, entity: entity1, blocked: true)
        let tracker2 = DetectedTracker(url: Constants.anotherUrl, knownTracker: nil, entity: entity2, blocked: false)

        XCTAssertEqual(tracker1.hashValue, tracker2.hashValue)
        XCTAssertEqual(tracker1, tracker2)
        
    }
    
}
