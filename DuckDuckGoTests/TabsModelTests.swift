//
//  TabsModelTests.swift
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

class TabsModelTests: XCTestCase {
    
    private var emptyModel: TabsModel {
        return TabsModel()
    }

    private var singleModel: TabsModel {
        let model = TabsModel()
        model.add(tab: Tab(link: nil))
        return model
    }
    
    private var filledModel: TabsModel {
        let model = TabsModel()
        model.add(tab: Tab(link: nil))
        model.add(tab: Tab(link: nil))
        model.add(tab: Tab(link: nil))
        return model
    }
    
    func testCountIsInitiallyZero() {
        XCTAssertEqual(TabsModel().count, 0)
    }
    
    func testCurrentIsInitiallyNil() {
        XCTAssertNil(TabsModel().currentIndex)
    }
    
    func testWhenFirstItemAddedThenCountIsOneAndCurrentIndexIsZero() {
        let testee = emptyModel
        testee.add(tab: Tab(link: nil))
        XCTAssertEqual(testee.count, 1)
        XCTAssertEqual(testee.currentIndex, 0)
    }
    
    func testWhenAdditionalItemAddedThenCountIsIncrementedAndCurrentIsSetToNewIndex() {
        let testee = filledModel
        XCTAssertEqual(testee.count, 3)
        XCTAssertEqual(testee.currentIndex, 2)
        testee.add(tab: Tab(link: nil))
        XCTAssertEqual(testee.count, 4)
        XCTAssertEqual(testee.currentIndex, 3)
    }
    
    func testWhenItemRemovedThenCountDecrements() {
        let testee = filledModel
        XCTAssertEqual(testee.count, 3)
        testee.remove(at: 0)
        XCTAssertEqual(testee.count, 2)
    }
    
    func testWhenFinalItemRemovedThenCountIsZero() {
        let testee = singleModel
        testee.remove(at: 0)
        XCTAssertEqual(testee.count, 0)
    }
    
    func testWhenFinalItemRemovedThenModelIsEmpty() {
        let testee = singleModel
        testee.remove(at: 0)
        XCTAssertTrue(testee.isEmpty)
    }
    
    func testWhenPreviousItemRemovedThenCurrentIndexDecrements() {
        let testee = filledModel
        filledModel.currentIndex = 2
        testee.remove(at: 0)
        XCTAssertEqual(testee.currentIndex, 1)
    }
    
    func testWhenCurrentItemRemovedAndCurrentIsNotLastThenCurrentIndexStaysTheSame() {
        let testee = filledModel
        filledModel.currentIndex = 1
        testee.remove(at: 1)
        XCTAssertEqual(testee.currentIndex, 1)
    }
    
    func testWhenCurrentItemRemovedAndCurrentIsLastThenCurrentIndexDecrements() {
        let testee = filledModel
        filledModel.currentIndex = 2
        testee.remove(at: 2)
        XCTAssertEqual(testee.currentIndex, 1)
    }
    
    func testWhenFinalItemRemovedThenCurrentIsNil() {
        let testee = singleModel
        testee.remove(at: 0)
        XCTAssertNil(testee.currentIndex)
    }
}
