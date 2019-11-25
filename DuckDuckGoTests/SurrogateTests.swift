//
//  DisconnectMeStoreTests.swift
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

class SurrogateTests: XCTestCase {

    private var bundle: Bundle {
        return Bundle(for: type(of: self))
    }

    var data: Data!

    override func setUp() {
        guard let data = try? FileLoader().load(fileName: "MockFiles/surrogates1.txt", fromBundle: bundle) else {
            XCTFail("Failed to load MockFiles/surrogate1s.txt")
            return
        }
        self.data = data
    }

    func testWhenSurrogatesFileStoredThenCanBeLoadedLater() {
        let persister = SurrogateStore()
        persister.persist(data: data)

        let loader = SurrogateStore()
        XCTAssertNotNil(loader.contentsAsString)
    }
    
}
