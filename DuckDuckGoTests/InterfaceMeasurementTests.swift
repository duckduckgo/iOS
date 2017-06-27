//
//  InterfaceMeasurementTests.swift
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

class InterfaceMeasurementTests: XCTestCase {
    
    func testWhenScreenSizeIs320x480TheniPhone4IsTrue() {
        let screen = UIScreenSpy(width: 320, height: 480)
        let testee = InterfaceMeasurement(forScreen: screen)
        XCTAssertTrue(testee.hasiPhone4ScreenSize)
    }
    
    func testWhenScreenIsNot320WidthTheniPhone4IsFalse() {
        let screen = UIScreenSpy(width: 321, height: 480)
        let testee = InterfaceMeasurement(forScreen: screen)
        XCTAssertFalse(testee.hasiPhone4ScreenSize)
    }

    func testWhenScreenIsNot480HeightTheniPhone4IsFalse() {
        let screen = UIScreenSpy(width: 320, height: 481)
        let testee = InterfaceMeasurement(forScreen: screen)
        XCTAssertFalse(testee.hasiPhone4ScreenSize)
    }
    
    func testWhenScreenSizeIs320x568TheniPhone5IsTrue() {
        let screen = UIScreenSpy(width: 320, height: 568)
        let testee = InterfaceMeasurement(forScreen: screen)
        XCTAssertTrue(testee.hasiPhone5ScreenSize)
    }

    func testWhenScreenIsNot320WidthTheniPhone5IsFalse() {
        let screen = UIScreenSpy(width: 321, height: 568)
        let testee = InterfaceMeasurement(forScreen: screen)
        XCTAssertFalse(testee.hasiPhone5ScreenSize)
    }
    
    func testWhenScreenIsNot568HeightTheniPhone5IsFalse() {
        let screen = UIScreenSpy(width: 320, height: 569)
        let testee = InterfaceMeasurement(forScreen: screen)
        XCTAssertFalse(testee.hasiPhone5ScreenSize)
    }

    
    func testWheniPhone4ThenSmallScreenSizeIsTrue() {
        let screen = UIScreenSpy(width: 320, height: 480)
        let testee = InterfaceMeasurement(forScreen: screen)
        XCTAssertTrue(testee.isSmallScreenDevice)
    }

    func testWheniPhone5ThenSmallScreenSizeIsTrue() {
        let screen = UIScreenSpy(width: 320, height: 568)
        let testee = InterfaceMeasurement(forScreen: screen)
        XCTAssertTrue(testee.isSmallScreenDevice)
    }
    
    func testWhenScreenUnknownThenSmallScreenSizeIsFalse() {
        let screen = UIScreenSpy(width: 0, height: 0)
        let testee = InterfaceMeasurement(forScreen: screen)
        XCTAssertFalse(testee.isSmallScreenDevice)
    }
    
    class UIScreenSpy: UIScreen {
     
        let nativeSize: CGRect
        
        init(width: CGFloat, height: CGFloat) {
            nativeSize = CGRect(x: 0, y: 0, width: width, height: height)
        }
        
        override var nativeBounds: CGRect {
            return nativeSize
        }
        
        override var scale: CGFloat {
            return 1
        }
    }
}

