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

    func testIdentifierMigration() {

        let legacyTDS = "\"abc\"\"\""

        let id1 = ContentBlockerRulesIdentifier(identifier: legacyTDS)
        let id1v = ContentBlockerRulesIdentifier(tdsEtag: "abc", tempListEtag: nil, unprotectedSitesHash: nil)
        XCTAssertEqual(id1, id1v)

        let legacyTDSTmp = "\"abc\"\"def\""
        let id2 = ContentBlockerRulesIdentifier(identifier: legacyTDSTmp)
        let id2v = ContentBlockerRulesIdentifier(tdsEtag: "abc", tempListEtag: "def", unprotectedSitesHash: nil)
        XCTAssertEqual(id2, id2v)

        let legacyTDSTmpUnp = "\"abc\"\"def\"ghj"
        let id3 = ContentBlockerRulesIdentifier(identifier: legacyTDSTmpUnp)
        let id3v = ContentBlockerRulesIdentifier(tdsEtag: "abc", tempListEtag: "def", unprotectedSitesHash: "ghj")
        XCTAssertEqual(id3, id3v)

        let legacyTDSUnp = "\"abc\"\"\"ghj"
        let id4 = ContentBlockerRulesIdentifier(identifier: legacyTDSUnp)
        let id4v = ContentBlockerRulesIdentifier(tdsEtag: "abc", tempListEtag: nil, unprotectedSitesHash: "ghj")
        XCTAssertEqual(id4, id4v)

    }
    
    func testStringInitialization() {
        let etag = "\"ABC\""
        let tempEtag = "\"DEF\""
        
        let unprotected = "ghj"
        
        let empty = "\"\""
        
        let basic1 = ContentBlockerRulesIdentifier(tdsEtag: etag, tempListEtag: nil, unprotectedSitesHash: nil)
        let basic2 = ContentBlockerRulesIdentifier(identifier: etag + empty + empty)!

        XCTAssertEqual(basic1, basic2)
        
        let withTempList1 = ContentBlockerRulesIdentifier(tdsEtag: etag, tempListEtag: tempEtag, unprotectedSitesHash: nil)
        let withTempList2 = ContentBlockerRulesIdentifier(identifier: etag + tempEtag + empty)!
        
        XCTAssertEqual(withTempList1, withTempList2)
        
        let withUnp1 = ContentBlockerRulesIdentifier(tdsEtag: etag, tempListEtag: nil, unprotectedSitesHash: unprotected)
        let withUnp2 = ContentBlockerRulesIdentifier(identifier: etag + empty + unprotected)!

        XCTAssertEqual(withUnp1, withUnp2)
        
        let full1 = ContentBlockerRulesIdentifier(tdsEtag: etag, tempListEtag: tempEtag, unprotectedSitesHash: unprotected)
        let full2 = ContentBlockerRulesIdentifier(identifier: etag + tempEtag + unprotected)!

        XCTAssertEqual(full1, full2)
    }
    
    func testForEquality() {
        
        let empty = ContentBlockerRulesIdentifier(tdsEtag: "", tempListEtag: nil, unprotectedSitesHash: nil)
        
        let a = ContentBlockerRulesIdentifier(tdsEtag: "a", tempListEtag: nil, unprotectedSitesHash: nil)
        let ab = ContentBlockerRulesIdentifier(tdsEtag: "a", tempListEtag: "b", unprotectedSitesHash: "")
        let abc = ContentBlockerRulesIdentifier(tdsEtag: "a", tempListEtag: "b", unprotectedSitesHash: "c")
        let bbc = ContentBlockerRulesIdentifier(tdsEtag: "b", tempListEtag: "b", unprotectedSitesHash: "c")
        let bac = ContentBlockerRulesIdentifier(tdsEtag: "b", tempListEtag: "a", unprotectedSitesHash: "c")
        let bacd = ContentBlockerRulesIdentifier(tdsEtag: "b", tempListEtag: "a", unprotectedSitesHash: "d")
        
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
