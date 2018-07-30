//
//  VariantTests.swift
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

class VariantTests: XCTestCase {

    func testSerpVariants() {
        let variants = Variant.defaultVariants.compactMap({ [ "sc", "sd" ].contains($0.name) ? $0 : nil })
        XCTAssertEqual(2, variants.count)
        XCTAssertEqual(1, variants[0].weight)
        XCTAssertEqual(1, variants[1].weight)
    }

}
