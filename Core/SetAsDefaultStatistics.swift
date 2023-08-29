//
//  SetAsDefaultStatistics.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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

import Foundation

/// Measuring set as default usage.  To be removed mid-end October.
public class SetAsDefaultStatistics {

    @UserDefaultsWrapper(key: .defaultBrowserUsageLastSeen, defaultValue: nil)
    var defaultBrowserUsageLastSeen: Date?

    /// We assume we're default if we the app was launched with a URL in the last 7 days
    public var isDefault: Bool {
        guard let lastSeen = defaultBrowserUsageLastSeen,
              let days = Calendar.current.numberOfDaysBetween(lastSeen, and: Date()) else { return false }
        return (0...7).contains(days)
    }

    public init() { }

    public func openedAsDefault() {
        defaultBrowserUsageLastSeen = Date()
    }

    public func setAsDefaultOpened() {
        Pixel.fire(pixel: .onboardingSetDefaultOpened)
    }

    public func setAsDefaultSkipped() {
        Pixel.fire(pixel: .onboardingSetDefaultSkipped)
    }

    public func fireDailyActiveUser() {
        DailyPixel.fire(pixel: .dailyActiveUser, withAdditionalParameters: [
            PixelParameters.defaultBrowser: "\(isDefault)"
        ])
    }

}
