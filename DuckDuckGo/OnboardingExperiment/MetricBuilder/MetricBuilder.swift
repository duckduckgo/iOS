//
//  MetricBuilder.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import SwiftUI
import class UIKit.UIScreen

final class MetricBuilder<T> {
    private let iPhoneValue: T
    private let iPadValue: T
    private var iPhoneSmallScreen: T?
    private var iPadPortraitValue: T?
    private var iPadLandscapeValue: T?

    init(iPhone: T, iPad: T) {
        iPhoneValue = iPhone
        iPadValue = iPad
    }

    convenience init(value: T) {
        self.init(iPhone: value, iPad: value)
    }

    func iPad(portrait: T, landscape: T) -> Self {
        iPadPortraitValue = portrait
        iPadLandscapeValue = landscape
        return self
    }

    func iPad(landscape: T) -> Self {
        iPadLandscapeValue = landscape
        return self
    }

    func smallIphone(_ value: T) -> Self {
        iPhoneSmallScreen = value
        return self
    }

    func build(v: UserInterfaceSizeClass?, h: UserInterfaceSizeClass?) -> T {
        if isIPad(v: v, h: h) {
            if isIpadLandscape(v: v, h: h) {
                iPadLandscapeValue ?? iPadValue
            } else {
                iPadPortraitValue ?? iPadValue
            }
        } else {
            if isIPhoneSmallScreen(UIScreen.main.bounds.size) {
                iPhoneSmallScreen ?? iPhoneValue
            } else {
                iPhoneValue
            }
        }
    }
}

func isIphone(v: UserInterfaceSizeClass?, h: UserInterfaceSizeClass?) -> Bool {
    !isIPad(v: v, h: h)
}

func isIPhonePortrait(v: UserInterfaceSizeClass?, h: UserInterfaceSizeClass?) -> Bool {
    v == .regular && h == .compact
}

func isIPhoneLandscape(v: UserInterfaceSizeClass?) -> Bool {
    v == .compact
}

func isIPhoneSmallScreen(_ frame: CGSize) -> Bool {
    frame.height > 0 && frame.height <= 667 // iPhone SE
}

func isIPad(v: UserInterfaceSizeClass?, h: UserInterfaceSizeClass?) -> Bool {
    v == .regular && h == .regular
}

func isIpadLandscape(v: UserInterfaceSizeClass?, h: UserInterfaceSizeClass?) -> Bool {
    isIPad(v: v, h: h) && UIScreen.main.bounds.width > UIScreen.main.bounds.height
}
