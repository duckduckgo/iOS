//
//  UserDefaultsExtension.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 13/04/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

extension UserDefaults {
    public func bool(forKey key: String, defaultValue: Bool) -> Bool {
        return object(forKey: key) as? Bool ?? defaultValue
    }
}
