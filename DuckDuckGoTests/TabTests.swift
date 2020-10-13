//
//  TabTests.swift
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

class TabTests: XCTestCase {

    struct Constants {
        static let title = "A title"
        static let url = URL(string: "https://example.com")!
        static let differentUrl = URL(string: "https://aDifferentUrl.com")!
    }

    func testWhenDesktopPropertyChangesThenObserversNotified() {
        let observer = MockTabObserver()

        let tab = Tab(link: link())
        tab.addObserver(observer)
        tab.isDesktop = true

        XCTAssertNotNil(observer.didChangeTab)

    }

    func testWhenDesktopModeToggledThenPropertyIsUpdated() {
        _ = AppWidthObserver.shared.willResize(toWidth: UIScreen.main.bounds.width)

        let tab = Tab(link: link())

        if AppWidthObserver.shared.isLargeWidth {
            XCTAssertTrue(tab.isDesktop)
            tab.toggleDesktopMode()
            XCTAssertFalse(tab.isDesktop)
            tab.toggleDesktopMode()
            XCTAssertTrue(tab.isDesktop)
        } else {
            XCTAssertFalse(tab.isDesktop)
            tab.toggleDesktopMode()
            XCTAssertTrue(tab.isDesktop)
            tab.toggleDesktopMode()
            XCTAssertFalse(tab.isDesktop)
        }
    }

    func testWhenEncodedWithDesktopPropertyThenDecodesSuccessfully() {
        let data = NSKeyedArchiver.archivedData(withRootObject: Tab(link: link(), viewed: false, desktop: true))
        XCTAssertFalse(data.isEmpty)

        let tab = NSKeyedUnarchiver.unarchiveObject(with: data) as? Tab
        
        XCTAssertNotNil(tab?.link)
        XCTAssertFalse(tab?.viewed ?? true)
        XCTAssertTrue(tab?.isDesktop ?? false)
    }

    /// This test supports the migration scenario where desktop was not a property of tab
    func testWhenEncodedWithoutDesktopPropertyThenDecodesSuccessfully() {
        let tab = Tab(coder: CoderStub(properties: ["link": link(), "viewed": false]))
        XCTAssertNotNil(tab?.link)
        XCTAssertFalse(tab?.viewed ?? true)
        XCTAssertFalse(tab?.isDesktop ?? true)
    }
    
    func testWhenTabObserverIsOutOfScopeThenUpdatesAreSuccessful() {
        var observer: MockTabObserver? = MockTabObserver()
        let tab = Tab(link: link())
        tab.addObserver(observer!)
        observer = nil
        tab.viewed = true
        XCTAssertTrue(tab.viewed)
    }
    
    func testWhenTabLinkChangesThenObserversAreNotified() {
        let observer = MockTabObserver()
        
        let tab = Tab(link: link())
        tab.addObserver(observer)
        tab.link = Link(title: nil, url: Constants.url)

        XCTAssertNotNil(observer.didChangeTab)
    }

    func testWhenTabViewedChangesThenObserversAreNotified() {
        let observer = MockTabObserver()
        
        let tab = Tab(link: link())
        tab.addObserver(observer)
        tab.viewed = true
        
        XCTAssertNotNil(observer.didChangeTab)
    }

    func testWhenTabWithViewedDecodedThenItDecodesSuccessfully() {

        let tab = Tab(coder: CoderStub(properties: ["link": link(), "viewed": false]))
        XCTAssertNotNil(tab?.link)
        XCTAssertFalse(tab?.viewed ?? true)
    }

    func testWhenTabEncodedBeforeViewedPropertyAddedIsDecodedThenItDecodesSuccessfully() {

        let tab = Tab(coder: CoderStub(properties: ["link": link()]))
        XCTAssertNotNil(tab?.link)
        XCTAssertTrue(tab?.viewed ?? false)
    }

    func testWhenSameObjectThenEqualsPasses() {
        let link = Link(title: Constants.title, url: Constants.url)
        let tab = Tab(link: link)
        XCTAssertEqual(tab, tab)
    }

    func testWhenSameDataThenEqualsPasses() {
        let lhs = Tab(link: Link(title: Constants.title, url: Constants.url))
        let rhs = Tab(link: Link(title: Constants.title, url: Constants.url))
        XCTAssertEqual(lhs, rhs)
    }

    func testWhenLinksDifferentThenEqualsFails() {
        let lhs = Tab(link: Link(title: Constants.title, url: Constants.url))
        let rhs = Tab(link: Link(title: Constants.title, url: Constants.differentUrl))
        XCTAssertNotEqual(lhs, rhs)
    }

    private func link() -> Link {
        return Link(title: "title", url: URL(string: "http://example.com")!)
    }

}

private class CoderStub: NSCoder {

    private let properties: [String: Any]

    init(properties: [String: Any]) {
        self.properties = properties
    }

    override func containsValue(forKey key: String) -> Bool {
        return properties.keys.contains(key)
    }

    override func decodeObject(forKey key: String) -> Any? {
        return properties[key]
    }

    override func decodeBool(forKey key: String) -> Bool {
        return (properties[key] as? Bool)!
    }
    
}

private class MockTabObserver: NSObject, TabObserver {
    
    var didChangeTab: Tab?
    
    func didChange(tab: Tab) {
        didChangeTab = tab
    }
    
}
