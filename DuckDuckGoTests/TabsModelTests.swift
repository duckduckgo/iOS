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

    private let exampleLink = Link(title: nil, url: URL(string: "https://example.com")!)

    private var emptyModel: TabsModel {
        return TabsModel(desktop: false)
    }

    private var singleModel: TabsModel {
        let model = TabsModel(tabs: [
            Tab(link: exampleLink)
        ], desktop: false)
        return model
    }

    private var filledModel: TabsModel {
        let model = TabsModel(tabs: [
            Tab(link: Link(title: "url1", url: URL(string: "https://ur1l.com")!)),
            Tab(link: Link(title: "url2", url: URL(string: "https://ur12.com")!)),
            Tab(link: Link(title: "url3", url: URL(string: "https://ur13.com")!))
        ], desktop: false)
        return model
    }
    
    func testWhenAtLeastOneTabIsNotViewedThenHasUnreadIsTrue() {
        let tab = Tab(link: exampleLink, viewed: false)
        
        let model = filledModel
        model.insert(tab: tab, at: 1)

        XCTAssertTrue(model.hasUnread)
    }
    
    func testWhenTabInsertedThenInsertedAtCorrectLocation() {

        let model = filledModel
        model.insert(tab: Tab(link: exampleLink), at: 1)

        XCTAssertNotNil(model.tabs[0].link)
        XCTAssertEqual("https://example.com", model.tabs[1].link?.url.absoluteString)
        XCTAssertNotNil(model.tabs[2].link)
        XCTAssertNotNil(model.tabs[3].link)

    }

    func testWhenTabsAddedViewedIsFalse() {
        XCTAssertFalse(filledModel.tabs[0].viewed)
    }

    func testWhenModelIsNewThenContainsHomeTab() {
        XCTAssertEqual(TabsModel(desktop: false).count, 1)
        XCTAssertNil(TabsModel(desktop: false).get(tabAt: 0).link)
        XCTAssertEqual(TabsModel(desktop: false).currentIndex, 0)
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
        let tab = Tab(link: Link(title: nil, url: URL(string: "https://www.example.com")!))
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
        testee.add(tab: Tab(link: exampleLink))
        XCTAssertEqual(testee.count, 2)
        XCTAssertEqual(testee.currentIndex, 1)
    }

    func testWhenAdditionalItemAddedThenCountIsIncrementedAndCurrentIsSetToNewIndex() {
        let testee = filledModel
        XCTAssertEqual(testee.count, 3)
        XCTAssertEqual(testee.currentIndex, 0)
        testee.add(tab: Tab(link: exampleLink))
        XCTAssertEqual(testee.count, 4)
        XCTAssertEqual(testee.currentIndex, 3)
    }

    func testWhenItemRemovedThenCountDecrements() {
        let testee = filledModel
        XCTAssertEqual(testee.count, 3)
        testee.remove(at: 0)
        XCTAssertEqual(testee.count, 2)
    }

    func testWhenFinalItemRemovedThenHomeTabRemains() {
        let testee = singleModel
        testee.remove(at: 0)
        XCTAssertEqual(testee.count, 1)
        XCTAssertNil(testee.get(tabAt: 0).link)
    }

    func testWhenOnlyHomeTabThenNoActiveTabs() {
        let testee = emptyModel
        XCTAssertFalse(testee.hasActiveTabs)
    }

    func testWhenOneOrMoreActiveTabsThenHasActiveTabs() {
        let testee = singleModel
        XCTAssertTrue(testee.hasActiveTabs)
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

    func testWhenLastIsRemovedThenHomeTabCreated() {
        let testee = singleModel
        testee.remove(at: 0)
        XCTAssertEqual(1, testee.count)
        XCTAssertEqual(0, testee.currentIndex)
    }
    
    func testWhenTabExistsThenReturnTrue() throws {
        let currentHost = try XCTUnwrap(filledModel.tabs[1].link?.url.host)
        XCTAssertTrue(filledModel.tabExists(withHost: currentHost))
        XCTAssertFalse(filledModel.tabExists(withHost: "domaindoesnotexist"))
    }

}
