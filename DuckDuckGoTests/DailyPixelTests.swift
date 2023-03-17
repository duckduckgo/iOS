//
//  DailyPixelTests.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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
import OHHTTPStubs
import OHHTTPStubsSwift
import Networking
@testable import Core

final class DailyPixelTests: XCTestCase {
    
    let host = "improving.duckduckgo.com"
    
    let dailyPixelStorage = UserDefaults(suiteName: "com.duckduckgo.daily.pixel.storage")!
        
    override func tearDown() {
        HTTPStubs.removeAllStubs()
        resetDailyPixelStorage()
        super.tearDown()
    }
    
    private func resetDailyPixelStorage() {
        dailyPixelStorage.dictionaryRepresentation().keys.forEach(dailyPixelStorage.removeObject(forKey:))
    }

    func testThatDailyPixelFiresCorrectlyForTheFirstTime() {
        let expectation = XCTestExpectation()
        
        stub(condition: isHost(host)) { _ -> HTTPStubsResponse in
            return HTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }
        
        DailyPixel.fire(pixel: .forgetAllPressedBrowsing) { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    func testThatDailyPixelFiresForTheFirstTimeButNotForTheSecond() {
        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 2
        
        stub(condition: isHost(host)) { _ -> HTTPStubsResponse in
            return HTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }
        
        DailyPixel.fire(pixel: .forgetAllPressedBrowsing) { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        
        DailyPixel.fire(pixel: .forgetAllPressedBrowsing) { error in
            XCTAssertNotNil(error)
            XCTAssertEqual(error as? DailyPixel.Error, .alreadyFired)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    func testThatDailyPixelWillFireIfFiredPreviouslyOnDifferentDay() {
        let expectation = XCTestExpectation()
        
        stub(condition: isHost(host)) { _ -> HTTPStubsResponse in
            return HTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }
        
        updateLastFireDateToYesterday(for: .forgetAllPressedBrowsing)
        
        DailyPixel.fire(pixel: .forgetAllPressedBrowsing) { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    private func updateLastFireDateToYesterday(for pixel: Pixel.Event) {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        dailyPixelStorage.set(yesterday, forKey: pixel.name)
    }
    
}
