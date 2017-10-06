//
//  JsonTestDataLoader.swift
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


import Foundation
@testable import Core


class JsonTestDataLoader {
    
    func empty() -> Data {
        return "".data(using: .utf16)!
    }
    
    func invalid() -> Data {
        return "{[}".data(using: .utf16)!
    }
    
    func unexpected() -> Data {
        return try! FileLoader().load(fileName: "MockJson/unexpected.json", fromBundle: bundle)
    }
    
    func fromJsonFile(_ fileName: String) -> Data {
        return try! FileLoader().load(fileName: fileName, fromBundle: bundle)
    }
    
    private var bundle: Bundle {
        return Bundle(for: type(of: self))
    }
}
