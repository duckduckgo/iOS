//
//  InterfaceMeasurement.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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


import UIKit
import CoreGraphics

// These are only used by the onboarding screens which should use safe area margins and/or size classes.
//  Leave for now as onboarding screens are going to be re-done anyway.
public struct InterfaceMeasurement {

    private static let iPhone4Size = CGSize(width: 320, height: 480)
    private static let iPhone5Size = CGSize(width: 320, height: 568)
    
    private let screen: UIScreen
    
    public init(forScreen screen: UIScreen) {
        self.screen = screen
    }
    
    public var isSmallScreenDevice: Bool {
        return hasiPhone4ScreenSize || hasiPhone5ScreenSize
    }

    public var hasiPhone4ScreenSize: Bool {
        return isNativeScaledSize(InterfaceMeasurement.iPhone4Size)
    }

    public var hasiPhone5ScreenSize: Bool {
        return isNativeScaledSize(InterfaceMeasurement.iPhone5Size)
    }

    private func isNativeScaledSize(_ size: CGSize) -> Bool {
        let scale = screen.scale
        let scaledWidth = screen.nativeBounds.size.width / scale
        let scaledHeight = screen.nativeBounds.size.height / scale
        let scaledSize = CGSize(width: scaledWidth, height: scaledHeight)
        return scaledSize == size
    }

}

