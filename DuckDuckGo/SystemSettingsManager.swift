//
//  SystemSettingsManager.swift
//  DuckDuckGo
//
//  Created by Firdavs Khaydarov on 16/10/19.
//  Copyright © 2019 DuckDuckGo. All rights reserved.
//

import Foundation

class SystemSettingsManager {
    struct Keys {
        static let version = "app_version"
    }
    
    static func updateSettingsValues() {
        // Update version value
        UserDefaults.standart.set(AppVersion.shared.majorVersionNumber, forKey: Keys.version)
    }
}
