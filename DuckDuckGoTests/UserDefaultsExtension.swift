//
//  UserDefaultsExtension.swift
//  DuckDuckGo
//
//  Created by Christopher Brind on 20/02/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import Foundation

extension UserDefaults {

    static func clearStandard() {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
    }

}
