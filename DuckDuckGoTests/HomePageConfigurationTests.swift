//
//  HomePageConfigurationTests.swift
//  UnitTests
//
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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

import Foundation
import XCTest
@testable import Core
@testable import DuckDuckGo

class HomePageConfigurationTests: XCTestCase {

    func testLayoutCentered() {
        let test = Test(layout: .centered, favorites: false, links: [])
        assertLayout(test: test, expected: [ .centeredSearch(fixed: true) ])
    }

    func testLayoutCenteredWithFavourites() {
        let test = Test(layout: .centered, favorites: true, links: [])
        assertLayout(test: test, expected: [ .centeredSearch(fixed: true), .favorites, .padding ])
    }

    func testLayoutCenteredWithFavouritesAndLink() {
        let url = URL(string: "http://www.example.com")!
        let test = Test(layout: .centered, favorites: true, links: [Link(title: nil, url: url)])
        assertLayout(test: test, expected: [.centeredSearch(fixed: false), .favorites, .padding])
    }

    func testLayoutNavigationBar() {
        let test = Test(layout: .navigationBar, favorites: false, links: [])
        assertLayout(test: test, expected: [ .navigationBarSearch(fixed: true) ])
    }

    func testLayoutNavigationBarWithFavourites() {
        let test = Test(layout: .navigationBar, favorites: true, links: [])
        assertLayout(test: test, expected: [ .navigationBarSearch(fixed: true), .favorites ])
    }

    func testLayoutWithNavigationBarFavouritesAndLink() {
        let url = URL(string: "http://www.example.com")!
        let test = Test(layout: .navigationBar, favorites: true, links: [Link(title: nil, url: url)])
        assertLayout(test: test, expected: [ .navigationBarSearch(fixed: false), .favorites ])
    }
}

private func assertLayout(
    test: Test,
    expected: [HomePageConfiguration.Component],
    file: StaticString = #file,
    line: UInt = #line
) {
    let actual = homePageConfigurationComponents(for: test)
    XCTAssertEqual(actual, expected, "\(test) was \(actual)", file: file, line: line)
}

private func homePageConfigurationComponents(for test: Test) -> [HomePageConfiguration.Component] {
    let settings = StubHomePageSettings(layout: test.layout, favorites: test.favorites)

    let store = MockBookmarkStore()
    store.favorites = test.links
    let manager = BookmarksManager(dataStore: store)

    let config = HomePageConfiguration(settings: settings)

    return config.components(bookmarksManager: manager)
}

private struct Test {
    let layout: HomePageLayout
    let favorites: Bool
    let links: [Link]
}

private struct StubHomePageSettings: HomePageSettings {

    var layout: HomePageLayout
    var favorites: Bool
    
    func migrate(from appSettigs: AppSettings) {
        // no-op
    }
    
}
