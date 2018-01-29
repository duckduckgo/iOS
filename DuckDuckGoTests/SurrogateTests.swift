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
        guard let data = try? FileLoader().load(fileName: "MockFiles/surrogates.txt", fromBundle: bundle) else {
            XCTFail("Failed to load MockFiles/surrogates.txt")
            return
        }
        self.data = data
    }
    
    func testWhenSurrogatesFileStoredThenCanBeLoadedLater() {
        let persister = SurrogateStore(groupIdentifier: "com.example.group")
        persister.parseAndPersist(data: data)
        
        let loader = SurrogateStore(groupIdentifier: "com.example.group")
        XCTAssertNotNil(loader.jsFunctions)
        XCTAssertEqual(2, loader.jsFunctions?.count)
    }
    
    func testWhenSurrogatesFileProperlyFormattedThenParsedInToFunctionDictionary() {
        
        guard let surrogateFile = String(data: data, encoding: .utf8) else {
            XCTFail("Failed to convert mock surrogate data in to a String")
            return
        }
        
        let dict = SurrogateParser.parse(lines: surrogateFile.components(separatedBy: .newlines))
        XCTAssertEqual(2, dict.count)
        
        XCTAssertTrue(dict["example.com/script1.js"]?.hasPrefix("(function() {") ?? false)
        XCTAssertTrue(dict["example.com/script1.js"]?.contains("console.log(\"Sample function 1\")") ?? false)
        XCTAssertTrue(dict["example.com/script1.js"]?.hasSuffix("})();") ?? false)

        XCTAssertTrue(dict["example.com/script2.js"]?.hasPrefix("(function() {") ?? false)
        XCTAssertTrue(dict["example.com/script2.js"]?.contains("console.log(\"Sample function 2\")") ?? false)
        XCTAssertTrue(dict["example.com/script2.js"]?.hasSuffix("})();") ?? false)

    }

}

