//
//  TabSwitcherOpenDailyPixel.swift
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

import Foundation

struct TabSwitcherOpenDailyPixel {
    func parameters(with tabs: [Tab]) -> [String: String] {
        var parameters = [String: String]()

        parameters[ParameterName.tabCount] = tabCountBucket(for: tabs)
        parameters[ParameterName.newTabCount] = newTabCountBucket(for: tabs)

        return parameters
    }

    private func tabCountBucket(for tabs: [Tab]) -> String? {
        let count = tabs.count

        switch count {
        case 0: return nil
        case 1...1: return "1"
        case 2...5: return "2-5"
        case 6...10: return "6-10"
        case 11...20: return "11-20"
        case 21...40: return "21-40"
        case 41...60: return "41-60"
        case 61...80: return "61-80"
        case 81...100: return "81-100"
        case 101...125: return "101-125"
        case 126...150: return "126-150"
        case 151...250: return "151-250"
        case 251...500: return "251-500"
        default: return "501+"
        }

    }

    private func newTabCountBucket(for tabs: [Tab]) -> String? {
        let count = tabs.count { $0.link == nil }

        switch count {
        case 0...1: return "0-1"
        case 2...10: return "2-10"
        default: return "11+"
        }
    }

    private enum ParameterName {
        static let tabCount = "tab_count"
        static let newTabCount = "new_tab_count"
    }
}
