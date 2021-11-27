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
        let id1v = ContentBlockerRulesIdentifier(tdsEtag: "abc", tempListEtag: nil, allowListEtag: nil, unprotectedSitesHash: nil)
        XCTAssertEqual(id1, id1v)

        let legacyTDSTmp = "\"abc\"\"def\""
        let id2 = ContentBlockerRulesIdentifier(identifier: legacyTDSTmp)
        let id2v = ContentBlockerRulesIdentifier(tdsEtag: "abc", tempListEtag: "def", allowListEtag: nil, unprotectedSitesHash: nil)
        XCTAssertEqual(id2, id2v)

        let legacyTDSTmpUnp = "\"abc\"\"def\"ghj"
        let id3 = ContentBlockerRulesIdentifier(identifier: legacyTDSTmpUnp)
        let id3v = ContentBlockerRulesIdentifier(tdsEtag: "abc", tempListEtag: "def", allowListEtag: nil, unprotectedSitesHash: "ghj")
        XCTAssertEqual(id3, id3v)

        let legacyTDSUnp = "\"abc\"\"\"ghj"
        let id4 = ContentBlockerRulesIdentifier(identifier: legacyTDSUnp)
        let id4v = ContentBlockerRulesIdentifier(tdsEtag: "abc", tempListEtag: nil, allowListEtag: nil, unprotectedSitesHash: "ghj")
        XCTAssertEqual(id4, id4v)
    }
    
    func testStringInitialization() {
        let etag = "\"ABC\""
        let tempEtag = "\"DEF\""
        let allowListEtag = "\"XYZ\""
        
        let unprotected = "\"ghj\""
        
        let empty = "\"\""
        
        let basic1 = ContentBlockerRulesIdentifier(tdsEtag: etag, tempListEtag: nil, allowListEtag: nil, unprotectedSitesHash: nil)
        let basic2 = ContentBlockerRulesIdentifier(identifier: etag + empty + empty + empty)!

        XCTAssertEqual(basic1, basic2)
        
        let withTempList1 = ContentBlockerRulesIdentifier(tdsEtag: etag, tempListEtag: tempEtag, allowListEtag: nil, unprotectedSitesHash: nil)
        let withTempList2 = ContentBlockerRulesIdentifier(identifier: etag + tempEtag + empty + empty)!
        
        XCTAssertEqual(withTempList1, withTempList2)

        let withAllowList1 = ContentBlockerRulesIdentifier(tdsEtag: etag, tempListEtag: nil, allowListEtag: allowListEtag, unprotectedSitesHash: nil)
        let withAllowList2 = ContentBlockerRulesIdentifier(identifier: etag + empty + allowListEtag + empty)!

        XCTAssertEqual(withAllowList1, withAllowList2)
        
        let withUnp1 = ContentBlockerRulesIdentifier(tdsEtag: etag, tempListEtag: nil, allowListEtag: nil, unprotectedSitesHash: unprotected)
        let withUnp2 = ContentBlockerRulesIdentifier(identifier: etag + empty + empty + unprotected)!

        XCTAssertEqual(withUnp1, withUnp2)
        
        let full1 = ContentBlockerRulesIdentifier(tdsEtag: etag,
                                                  tempListEtag: tempEtag,
                                                  allowListEtag: allowListEtag,
                                                  unprotectedSitesHash: unprotected)
        let full2 = ContentBlockerRulesIdentifier(identifier: etag + tempEtag + allowListEtag + unprotected)!

        XCTAssertEqual(full1, full2)
    }
    
    func testForEquality() {
        
        let empty = ContentBlockerRulesIdentifier(tdsEtag: "", tempListEtag: nil, allowListEtag: nil, unprotectedSitesHash: nil)
        
        let a = ContentBlockerRulesIdentifier(tdsEtag: "a", tempListEtag: nil, allowListEtag: nil, unprotectedSitesHash: nil)
        let ab = ContentBlockerRulesIdentifier(tdsEtag: "a", tempListEtag: "b", allowListEtag: nil, unprotectedSitesHash: "")
        let abc = ContentBlockerRulesIdentifier(tdsEtag: "a", tempListEtag: "b", allowListEtag: "c", unprotectedSitesHash: "")
        let abcd = ContentBlockerRulesIdentifier(tdsEtag: "a", tempListEtag: "b", allowListEtag: "c", unprotectedSitesHash: "d")

        let bbcd = ContentBlockerRulesIdentifier(tdsEtag: "b", tempListEtag: "b", allowListEtag: "c", unprotectedSitesHash: "d")

        let baac = ContentBlockerRulesIdentifier(tdsEtag: "b", tempListEtag: "a", allowListEtag: "a", unprotectedSitesHash: "c")
        let baad = ContentBlockerRulesIdentifier(tdsEtag: "b", tempListEtag: "a", allowListEtag: "a", unprotectedSitesHash: "d")
        
        XCTAssertTrue(empty.compare(with: a).contains(.tdsEtag))
        XCTAssertFalse(empty.compare(with: a).contains(.tempListEtag))
        XCTAssertFalse(empty.compare(with: a).contains(.allowListEtag))
        XCTAssertFalse(empty.compare(with: a).contains(.unprotectedSites))
        
        XCTAssertTrue(empty.compare(with: ab).contains(.tdsEtag))
        XCTAssertTrue(empty.compare(with: ab).contains(.tempListEtag))
        XCTAssertFalse(empty.compare(with: ab).contains(.allowListEtag))
        XCTAssertFalse(empty.compare(with: ab).contains(.unprotectedSites))
        
        XCTAssertTrue(empty.compare(with: abc).contains(.tdsEtag))
        XCTAssertTrue(empty.compare(with: abc).contains(.tempListEtag))
        XCTAssertTrue(empty.compare(with: abc).contains(.allowListEtag))
        XCTAssertFalse(empty.compare(with: abc).contains(.unprotectedSites))
        
        XCTAssertTrue(a.compare(with: ab).contains(.tempListEtag))
        XCTAssertFalse(a.compare(with: ab).contains(.allowListEtag))
        
        XCTAssertTrue(ab.compare(with: abc).contains(.allowListEtag))
        
        XCTAssertTrue(bbcd.compare(with: abcd).contains(.tdsEtag))
        
        XCTAssertTrue(baac.compare(with: bbcd).contains(.tempListEtag))
        XCTAssertTrue(baac.compare(with: bbcd).contains(.allowListEtag))
        XCTAssertTrue(baac.compare(with: bbcd).contains(.unprotectedSites))
        
        XCTAssertTrue(baac.compare(with: abc).contains(.tdsEtag))
        XCTAssertTrue(baac.compare(with: abc).contains(.tempListEtag))
        XCTAssertTrue(baac.compare(with: abc).contains(.allowListEtag))
        XCTAssertTrue(baac.compare(with: abc).contains(.unprotectedSites))
        
        XCTAssertTrue(baac.compare(with: baad).contains(.unprotectedSites))
        XCTAssertFalse(baac.compare(with: baad).contains(.tempListEtag))
        XCTAssertFalse(baac.compare(with: baad).contains(.allowListEtag))
    }
}
