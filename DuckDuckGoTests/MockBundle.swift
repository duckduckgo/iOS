//
//  MockBundle.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 31/01/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation
@testable import DuckDuckGo
@testable import Kingfisher
@testable import Core

class MockBundle: InfoBundle {
    
    private var mockEntries = [String: Any]()
    
    func object(forInfoDictionaryKey key: String) -> Any? {
        return mockEntries[key]
    }
    
    func add(name: String, value: Any) {
        mockEntries[name] = value
    }
}
