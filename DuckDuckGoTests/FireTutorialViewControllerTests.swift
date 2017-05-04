//
//  FireTutorialViewControllerTests.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 05/05/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//


import XCTest
@testable import DuckDuckGo
@testable import Kingfisher
@testable import Core


class FireTutorialViewControllerTests: XCTestCase {

    func testLoadFromStoryboardIsNonNull() {
        let testee = FireTutorialViewController.loadFromStoryboard()
        XCTAssertNotNil(testee)
    }
}
