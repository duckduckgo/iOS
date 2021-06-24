//
//  ContentBlockerRulesIdentifierTests.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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
@testable import DuckDuckGo

class ContentBlockerRulesIdentifierTests: XCTestCase {
    
    func testWhenInitializedWithLegacyThenNil() {
        XCTAssertNil(ContentBlockerRulesIdentifier(identifier: "tds"))
    }
    
    func testStringInitialization() {
        let etag = "\"ABC\""
        let tempEtag = "\"DEF\""
        
        let unprotected = ["ghj"]
        let unprotectedHash = unprotected.joined().sha1
        
        let empty = "\"\""
        
        let basic1 = ContentBlockerRulesIdentifier(tdsEtag: etag, tempListEtag: nil, unprotectedSites: nil)
        let basic2 = ContentBlockerRulesIdentifier(identifier: etag + empty)!
        
        XCTAssertTrue(basic1.compare(with: basic2).isEmpty)
        
        let withTempList1 = ContentBlockerRulesIdentifier(tdsEtag: etag, tempListEtag: tempEtag, unprotectedSites: nil)
        let withTempList2 = ContentBlockerRulesIdentifier(identifier: etag + tempEtag)!
        
        XCTAssertTrue(withTempList1.compare(with: withTempList2).isEmpty)
        
        let withUnp1 = ContentBlockerRulesIdentifier(tdsEtag: etag, tempListEtag: nil, unprotectedSites: unprotected)
        let withUnp2 = ContentBlockerRulesIdentifier(identifier: etag + empty + unprotectedHash)!
        
        XCTAssertTrue(withUnp1.compare(with: withUnp2).isEmpty)
        
        let full1 = ContentBlockerRulesIdentifier(tdsEtag: etag, tempListEtag: tempEtag, unprotectedSites: unprotected)
        let full2 = ContentBlockerRulesIdentifier(identifier: etag + tempEtag + unprotectedHash)!
        
        XCTAssertTrue(full1.compare(with: full2).isEmpty)
    }
    
    func testForEquality() {
        
        let empty = ContentBlockerRulesIdentifier(tdsEtag: "", tempListEtag: nil, unprotectedSites: nil)
        
        let a = ContentBlockerRulesIdentifier(tdsEtag: "a", tempListEtag: nil, unprotectedSites: nil)
        let ab = ContentBlockerRulesIdentifier(tdsEtag: "a", tempListEtag: "b", unprotectedSites: [])
        let abc = ContentBlockerRulesIdentifier(tdsEtag: "a", tempListEtag: "b", unprotectedSites: ["c"])
        let bbc = ContentBlockerRulesIdentifier(tdsEtag: "b", tempListEtag: "b", unprotectedSites: ["c"])
        let bac = ContentBlockerRulesIdentifier(tdsEtag: "b", tempListEtag: "a", unprotectedSites: ["c"])
        let bacd = ContentBlockerRulesIdentifier(tdsEtag: "b", tempListEtag: "a", unprotectedSites: ["c", "d"])
        
        XCTAssertTrue(empty.compare(with: a).contains(.tdsEtag))
        XCTAssertFalse(empty.compare(with: a).contains(.tempListEtag))
        XCTAssertFalse(empty.compare(with: a).contains(.unprotectedSites))
        
        XCTAssertTrue(empty.compare(with: ab).contains(.tdsEtag))
        XCTAssertTrue(empty.compare(with: ab).contains(.tempListEtag))
        XCTAssertFalse(empty.compare(with: ab).contains(.unprotectedSites))
        
        XCTAssertTrue(empty.compare(with: abc).contains(.tdsEtag))
        XCTAssertTrue(empty.compare(with: abc).contains(.tempListEtag))
        XCTAssertTrue(empty.compare(with: abc).contains(.unprotectedSites))
        
        XCTAssertTrue(a.compare(with: ab).contains(.tempListEtag))
        
        XCTAssertTrue(ab.compare(with: abc).contains(.unprotectedSites))
        
        XCTAssertTrue(bbc.compare(with: abc).contains(.tdsEtag))
        
        XCTAssertTrue(bbc.compare(with: bac).contains(.tempListEtag))
        
        XCTAssertTrue(bac.compare(with: abc).contains(.tdsEtag))
        XCTAssertTrue(bac.compare(with: abc).contains(.tempListEtag))
        
        XCTAssertTrue(bac.compare(with: bacd).contains(.unprotectedSites))
        
        XCTAssertTrue(ab.compare(with: bac).contains(.tdsEtag))
        XCTAssertTrue(ab.compare(with: bac).contains(.tempListEtag))
        XCTAssertTrue(ab.compare(with: bac).contains(.unprotectedSites))
    }
}
