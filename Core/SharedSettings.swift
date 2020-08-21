//
//  SharedSettings.swift
//  Core
//
//  Created by Chris Brind on 21/08/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import Foundation

public class SharedSettings {

    public static let shared = SharedSettings()

    @UserDefaultsWrapper(key: .sharedAppIconName, defaultValue: nil, group: .shared)
    public var appIconName: String?

}
