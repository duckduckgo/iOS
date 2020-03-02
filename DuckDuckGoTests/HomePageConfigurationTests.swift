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

    struct Test {

        let layout: HomePageLayout
        let favorites: Bool
        let links: [Link]
        let expected: [HomePageConfiguration.Component]

    }

    func test() {

        let url = URL(string: "http://www.example.com")!

        let tests = [
            Test(layout: .centered, favorites: false, links: [],
                 expected: [ .centeredSearch(fixed: true) ]),

            Test(layout: .centered, favorites: true, links: [],
                 expected: [ .centeredSearch(fixed: true), .favorites, .padding ]),

            Test(layout: .centered, favorites: true, links: [Link(title: nil, url: url)],
                 expected: [ .centeredSearch(fixed: false), .favorites, .padding ]),

            Test(layout: .navigationBar, favorites: false, links: [],
                 expected: [ .navigationBarSearch(fixed: true) ]),

            Test(layout: .navigationBar, favorites: true, links: [],
                 expected: [ .navigationBarSearch(fixed: true), .favorites ]),

            Test(layout: .navigationBar, favorites: true, links: [Link(title: nil, url: url)],
                 expected: [ .navigationBarSearch(fixed: false), .favorites ])

        ]

        for test in tests {

            let settings = StubHomePageSettings(layout: test.layout, favorites: test.favorites)
            let store = MockBookmarkStore()
            store.favorites = test.links
            let manager = BookmarksManager(dataStore: store)

            let config = HomePageConfiguration(settings: settings)

            let actual = config.components(bookmarksManager: manager)
            if actual != test.expected {
                // This makes it easier to debug failures
                XCTFail("\(test) was \(actual)")
            }

        }

    }

}

struct StubHomePageSettings: HomePageSettings {

    var layout: HomePageLayout
    var favorites: Bool
    
    func migrate(from appSettigs: AppSettings) {
        // no-op
    }
    
}
