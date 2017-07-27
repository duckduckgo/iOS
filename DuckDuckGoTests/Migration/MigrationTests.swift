//
//  MigrationTests.swift
//  DuckDuckGo
//
//  Created by Christopher Brind on 27/07/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

import XCTest
@testable import DuckDuckGo

class MigrationTests: XCTestCase {

    func testWhenNoMigrationRequiredCompletionIsCalled() {
        
        var completed = false
        
        Migration().start {
            completed = true
        }
        
        XCTAssert(completed)
    }
    
}
