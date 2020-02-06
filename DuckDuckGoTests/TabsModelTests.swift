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
        model.add(tab: Tab(link: Link(title: "url1", url: URL(string: "https://ur1l.com")!)))
        model.add(tab: Tab(link: Link(title: "url2", url: URL(string: "https://ur12.com")!)))
        model.add(tab: Tab(link: Link(title: "url3", url: URL(string: "https://ur13.com")!)))
        return model
    }
    
    func testWhenAtLeastOneTabIsNotViewedThenHasUnreadIsTrue() {
        let link = Link(title: nil, url: URL(string: "https://example.com")!)
        let tab = Tab(link: link, viewed: false)
        
        let model = filledModel
        model.insert(tab: tab, at: 1)

        XCTAssertTrue(model.hasUnread)
    }
    
    func testWhenTabInsertedThenInsertedAtCorrectLocation() {
        let link = Link(title: nil, url: URL(string: "https://example.com")!)

        let model = filledModel
        model.insert(tab: Tab(link: link), at: 1)

        XCTAssertNotNil(model.tabs[0].link)
        XCTAssertEqual("https://example.com", model.tabs[1].link?.url.absoluteString)
        XCTAssertNotNil(model.tabs[2].link)
        XCTAssertNotNil(model.tabs[3].link)

    }

    func testWhenTabsAddedViewedIsTrue() {
        XCTAssertTrue(filledModel.tabs[0].viewed)
    }

    func testCountIsInitiallyZero() {
        XCTAssertEqual(TabsModel().count, 0)
    }

    func testCurrentIsInitiallyNil() {
        XCTAssertNil(TabsModel().currentIndex)
    }
    
    func testWhenTabMovedToInvalidPositionNoChangeMadeToCurrentIndex() {
        let testee = filledModel
        testee.select(tabAt: 1)
        testee.moveTab(from: 1, to: 3)
        XCTAssertEqual(1, testee.currentIndex)
        testee.moveTab(from: 1, to: -1)
        XCTAssertEqual(1, testee.currentIndex)
    }
    
    func testWhenTabMovedToStartOfListThenCurrentIndexUpdatedCorrectly() {
        let testee = filledModel
        testee.select(tabAt: 1)
        
        testee.moveTab(from: 1, to: 0)
        XCTAssertEqual(0, testee.currentIndex)
    }

    func testWhenTabMovedToEndOfListThenCurrentIndexUpdatedCorrectly() {
        let testee = filledModel
        testee.select(tabAt: 1)
        
        testee.moveTab(from: 1, to: 2)
        XCTAssertEqual(2, testee.currentIndex)
    }

    func testWhenTabExistsThenIndexReturned() {
        let tab = Tab(link: nil)
        let testee = filledModel
        testee.add(tab: tab)
        XCTAssertEqual(testee.indexOf(tab: tab), 3)
    }

    func testWhenTabDoesNotExistThenIndexIsNil() {
        let tab = Tab(link: nil)
        let testee = filledModel
        XCTAssertNil(testee.indexOf(tab: tab))
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
        testee.select(tabAt: 2)
        testee.remove(at: 0)
        XCTAssertEqual(testee.currentIndex, 1)
    }

    func testWhenLaterItemRemovedThenCurrentIndexStaysTheSame() {
        let testee = filledModel
        testee.select(tabAt: 0)
        testee.remove(at: 2)
        XCTAssertEqual(testee.currentIndex, 0)
    }

    func testWhenCurrentIsFirstItemAndItIsRemovedThenCurrentIsZero() {
        let testee = filledModel
        testee.select(tabAt: 0)
        testee.remove(at: 0)
        XCTAssertEqual(testee.currentIndex, 0)
    }

    func testWhenCurrentIsOnlyItemAndItIsRemovedThenCurrentIsNil() {
        let testee = singleModel
        testee.select(tabAt: 0)
        testee.remove(at: 0)
        XCTAssertNil(testee.currentIndex)
    }
    
    func testWhenAllClearedThenCountIsZeroAndCurrentIsNil() {
        let testee = filledModel
        testee.clearAll()
        XCTAssertEqual(testee.count, 0)
        XCTAssertNil(testee.currentIndex)
    }
}
