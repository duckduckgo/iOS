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

    /// Format is v&lt;week&gt;-&lt;day&gt;
    /// * day is `1...7` with 1 being Wednesday
    /// * note that week is NOT padded but ATBs older than week 100 should never be seen by the apps, ie no one has this installed before Feb 2018 and week 99 is Jan 2018
    /// * ATBs > 999 would be about 10 years in the future (Apr 2035), we can fix it nearer the time
    static let template = "v100-1"

    /// Same as `template` two characters on the end, e.g. `ma`
    static let templateWithVariant = template + "xx"

    let version: String
    let updateVersion: String?
    let numeric: AtbNumeric?

    init(version: String, updateVersion: String?) {
        self.version = version
        self.updateVersion = updateVersion
        self.numeric = AtbNumeric.makeFromVersion(version)
    }

    enum CodingKeys: CodingKey {
        case version
        case updateVersion
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.version = try container.decode(String.self, forKey: .version)
        self.updateVersion = try container.decodeIfPresent(String.self, forKey: .updateVersion)
        self.numeric = AtbNumeric.makeFromVersion(version)
    }

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
        version.count == Self.templateWithVariant.count && version.hasSuffix("ru")
    }

    struct AtbNumeric {

        let week: Int
        let day: Int
        let ageInDays: Int

        static func makeFromVersion(_ version: String) -> AtbNumeric? {
            let version = String(version.prefix(Atb.template.count))
            guard version.count == Atb.template.count,
                  let week = Int(version.substring(1...3)),
                  let day = Int(version.substring(5...5)),
                  (1...7).contains(day) else {

                if !ProcessInfo().arguments.contains("testing") {
                    assertionFailure("bad atb")
                }
                return nil
            }

            return AtbNumeric(week: week, day: day, ageInDays: (week * 7) + (day - 1))
        }

    }

}

extension Atb {

    var droppingVariant: String {
        return String(version.prefix(Atb.template.count))
    }

}

private extension String {

    func substring(_ range: ClosedRange<Int>) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: range.lowerBound)
        let endIndex = self.index(self.startIndex, offsetBy: min(self.count, range.upperBound + 1))
        let substring = self[startIndex..<endIndex]
        return String(substring)
    }

}
