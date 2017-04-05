//
//  UIColorExtensionTests.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 03/04/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import XCTest
import Core

class UIColorExtensionTests: XCTestCase {
    
    func testCombineRgbColor() {
        let ratio: CGFloat = 0.5
        let first = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 0.6)
        let second = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.2)
        let expected = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.4)
        let actual = first.combine(withColor: second, ratio: ratio)
        XCTAssertEqual(actual, expected)
    }
}

