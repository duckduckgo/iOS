//
//  TermsOfServiceStore.swift
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

class TermsOfServiceStore {
    
    struct Constansts {
        static let fileName = "tosdr.json"
    }
    
    private(set) lazy var terms = TermsOfServiceStore.load()
    
    static func load() -> [String: TermsOfService] {
        let parser = TermsOfServiceListParser()
        let bundle = Bundle(for: TermsOfServiceStore.self)
        let fileLoader = FileLoader()
        let data = try! fileLoader.load(fileName: Constansts.fileName, fromBundle: bundle)
        let terms = try! parser.convert(fromJsonData: data)
        return terms
    }
}
