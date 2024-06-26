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

    init(iPhone: T, iPad: T) {
        iPhoneValue = iPhone
        iPadValue = iPad
    }

    convenience init(value: T) {
        self.init(iPhone: value, iPad: value)
    }

    func smallIphone(_ value: T) -> Self {
        iPhoneSmallScreen = value
        return self
    }

    func build(v: UserInterfaceSizeClass?, h: UserInterfaceSizeClass?) -> T {
        if isIPad(v, h) {
            iPadValue
        } else {
            if isIPhoneSmallScreen(UIScreen.main.bounds.size) {
                iPhoneSmallScreen ?? iPhoneValue
            } else {
                iPhoneValue
            }
        }
    }

    private func isIPhonePortrait(_ verticalSizeClass: UserInterfaceSizeClass?, _ horizontalSizeClass: UserInterfaceSizeClass?) -> Bool {
        verticalSizeClass == .regular && horizontalSizeClass == .compact
    }

    private func isIPhoneLandscape(_ verticalSizeClass: UserInterfaceSizeClass?) -> Bool {
        verticalSizeClass == .compact
    }

    private func isIPhoneSmallScreen(_ frame: CGSize) -> Bool {
        frame.height > 0 && frame.height <= 667 //iPhone SE
    }

    private func isIPad(_ verticalSizeClass: UserInterfaceSizeClass?, _ horizontalSizeClass: UserInterfaceSizeClass?) -> Bool {
        verticalSizeClass == .regular && horizontalSizeClass == .regular
    }
}
