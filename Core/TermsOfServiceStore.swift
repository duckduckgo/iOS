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

public protocol TermsOfServiceStore {

    var terms: [String: TermsOfService] { get }

}

public class EmbeddedTermsOfServiceStore: TermsOfServiceStore {

    struct Constansts {
        static let fileName = "tosdr.json"
    }

    public private(set) var terms: [String: TermsOfService]

    public init() {
        let parser = TermsOfServiceListParser()
        let bundle = Bundle(for: EmbeddedTermsOfServiceStore.self)
        let fileLoader = FileLoader()
        let data = try! fileLoader.load(fileName: Constansts.fileName, fromBundle: bundle)
        terms = try! parser.convert(fromJsonData: data)
    }

}
