//
//  DaxDialogBrowserSpecTests.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 25/05/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import XCTest
@testable import DuckDuckGo

class DaxDialogBrowserSpecTests: XCTestCase {
    
    func testWhenOneMajorTrackerWithNoOtherTrackersIsFormattedThenContainsTrackerName() {
        let majorTracker = "TestTracker"
        XCTAssertTrue(DaxOnboarding.BrowsingSpec.withOneMajorTracker.format(args: majorTracker).message.contains(majorTracker))
    }
    
}
