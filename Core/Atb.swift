//
//  Atb.swift
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

import Foundation

public struct Atb: Decodable, Equatable {

    let version: String
    let updateVersion: String?

    /// Equality is about the version without any variants.  e.g. v100-1 == v100-1ma.  `updateVersion` is ignored because that's a signal from the server to update the locally stored Atb so not relevant to any calculation
    public static func == (lhs: Atb, rhs: Atb) -> Bool {
        return lhs.droppingVariant == rhs.droppingVariant
    }

    /// Subtracts one ATB from the other.
    ///  @return difference in days
    public static func - (lhs: Atb, rhs: Atb) -> Int {
        return lhs.ageInDays - rhs.ageInDays
    }

    /// Gives age in days since first ATB.  If badly formatted returns -1. Only the server should be giving us ATB values, so if it is giving us something wrong there are bigger problems in the world.
    var ageInDays: Int {
        numeric?.ageInDays ?? -1
    }

    /// Gives the current week or -1 if badly formatted
    var week: Int {
        numeric?.week ?? -1
    }

    var isReturningUser: Bool {
        version.count == 8 && version.hasSuffix("ru")
    }

    private var numeric: AtbNumeric? {
        guard let version = droppingVariant,
              let week = Int(version.substring(1...3)),
              let day = Int(version.substring(5...5)),
              (1...7).contains(day) else {
            return nil
        }

        return AtbNumeric(week: week, day: day, ageInDays: (week * 7) + (day - 1))
    }

    struct AtbNumeric {

        let week: Int
        let day: Int
        let ageInDays: Int

    }

}

extension Atb {

    var droppingVariant: String? {
        let minSize = "v111-1".count
        guard version.count >= minSize else { return nil }
        return String(version.prefix(minSize))
    }

}

private extension String {

    func substring(_ range: ClosedRange<Int>) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: range.lowerBound)
        let endIndex = self.index(self.startIndex, offsetBy: range.upperBound + 1)
        let substring = self[startIndex..<endIndex]
        return String(substring)
    }

}
