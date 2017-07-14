//
//  TabsModelPersistenceExtensionTests.swift
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

class TabsModelPersistenceExtensionTests: XCTestCase {
    
    struct Constants {
        static let firstTitle = "a title"
        static let firstUrl = "http://aurl.com"
        static let secondTitle = "another title"
        static let secondUrl = "http://anotherurl.com"
    }
    
    override func setUp() {
        UserDefaults.standard.removeObject(forKey: "com.duckduckgo.opentabs")
    }
    
    private var firstTab: Tab {
        return tab(title: Constants.firstTitle, url: Constants.firstUrl)
    }
    
    private var secondTab: Tab {
        return tab(title: Constants.firstTitle, url: Constants.firstUrl)
    }
    
    private var emptyModel: TabsModel {
        return TabsModel()
    }
    
    private var model: TabsModel {
        let model = TabsModel()
        model.add(tab: firstTab)
        model.add(tab: secondTab)
        return model
    }

    func testBeforeModelSavedThenGetIsNil() {
        XCTAssertNil(TabsModel.get())
    }
    
    func testWhenModelSavedThenGetIsNotNil() {
        model.save()
        XCTAssertNotNil(TabsModel.get())
    }
    
    func testWhenEmptyModelIsSavedThenGetLoadsModelWithNoItemsAndNoCurrent() {
        emptyModel.save()
        
        let loaded = TabsModel.get()!
        XCTAssertEqual(loaded.count, 0)
        XCTAssertNil(loaded.currentIndex)
    }

    func testWhenModelIsSavedThenGetLoadsCompleteTabs() {
        model.save()
        
        let loaded = TabsModel.get()!
        XCTAssertEqual(loaded.get(tabAt: 0), firstTab)
        XCTAssertEqual(loaded.get(tabAt: 1), secondTab)
        XCTAssertEqual(loaded.currentIndex, 1)
    }
    
    func testWhenModelIsSavedThenGetLoadsModelWithCurrentSelection() {
        model.save()
        
        let loaded = TabsModel.get()!
        XCTAssertEqual(loaded.count, 2)
        XCTAssertEqual(loaded.currentIndex, 1)
    }
    
    func testWhenModelWithClearedSelectionIsSavedThenGetLoadsModelWithNoCurrent() {
        let saved = model
        saved.clearSelection()
        saved.save()
        
        let loadedModel = TabsModel.get()!
        XCTAssertEqual(loadedModel.count, 2)
        XCTAssertNil(loadedModel.currentIndex)
    }

    private func tab(title: String, url: String) -> Tab {
        return Tab(link: Link(title: title, url: URL(string: url)!))
    }
}
