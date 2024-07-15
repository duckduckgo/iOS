//
//  UniquePixel.swift
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

/// A variant of pixel that is fired just once. Ever.
///
/// The 'fire' method mimics standard Pixel API.
/// The 'onComplete' closure is always called - even when no pixel is fired.
/// In those scenarios a 'UniquePixelError' is returned denoting the reason.
///
public final class UniquePixel {

    public enum Error: Swift.Error {

        case alreadyFired

    }

    private enum Constant {

        static let uniquePixelStorageIdentifier = "com.duckduckgo.unique.pixel.storage"

    }

    public static let storage = UserDefaults(suiteName: Constant.uniquePixelStorageIdentifier)!
    private static let calendar: Calendar = {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }()

    private static let weeksToCoalesceCohort = 6

    /// Sends a unique Pixel
    /// This requires the pixel name to end with `_u`
    public static func fire(pixel: Pixel.Event,
                            withAdditionalParameters params: [String: String] = [:],
                            includedParameters: [Pixel.QueryParameters] = [.appVersion],
                            onComplete: @escaping (Swift.Error?) -> Void = { _ in }) {
        guard pixel.name.hasSuffix("_u") || pixel.name.hasSuffix("_unique") else {
            assertionFailure("Unique pixel: must end with _u or _unique")
            return
        }

        if !pixel.hasBeenFiredEver(uniquePixelStorage: storage) {
            Pixel.fire(pixel: pixel, withAdditionalParameters: params, includedParameters: includedParameters, onComplete: onComplete)
            storage.set(Date(), forKey: pixel.name)
        } else {
            onComplete(Error.alreadyFired)
        }
    }

    public static func cohort(from cohortLocalDate: Date?) -> String {
        guard let cohortLocalDate,
              let baseDate = calendar.date(from: .init(year: 2023, month: 1, day: 1)),
              let weeksSinceCohortAssigned = calendar.dateComponents([.weekOfYear], from: cohortLocalDate, to: Date()).weekOfYear,
              let assignedCohort = calendar.dateComponents([.weekOfYear], from: baseDate, to: cohortLocalDate).weekOfYear else {
            return ""
        }

        if weeksSinceCohortAssigned > Self.weeksToCoalesceCohort {
            return ""
        } else {
            return "week-" + String(assignedCohort + 1)
        }
    }
}

extension Pixel.Event {

    public func lastFireDate(uniquePixelStorage: UserDefaults) -> Date? {
        uniquePixelStorage.object(forKey: name) as? Date
    }

    func hasBeenFiredEver(uniquePixelStorage: UserDefaults) -> Bool {
        lastFireDate(uniquePixelStorage: uniquePixelStorage) != nil
    }

}
