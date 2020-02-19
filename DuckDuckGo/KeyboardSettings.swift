//
//  KeyboardSettings.swift
//  DuckDuckGo
//
//  Created by Christopher Brind on 19/02/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import Core

struct KeyboardSettings {

    @UserDefaultsWrapper(key: .keyboardOnNewTab, defaultValue: true)
    var onNewTab: Bool

    @UserDefaultsWrapper(key: .keyboardOnAppLaunch, defaultValue: false)
    var onAppLaunch: Bool

}
