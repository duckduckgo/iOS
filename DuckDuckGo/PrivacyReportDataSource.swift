//
//  PrivacyReportDataSource.swift
//  DuckDuckGo
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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
import Core

class PrivacyReportDataSource {
    
    private let networkLeaderboard = NetworkLeaderboard()
    
    var startDate: Date? {
        return networkLeaderboard.startDate
    }
    
    var trackersCount: Int {
        return networkLeaderboard.networksDetected().reduce(0, { $0 + ($1.detectedOnCount?.intValue ?? 0) })
    }
    
    var httpsUpgradesCount: Int {
        return networkLeaderboard.httpsUpgrades()
    }
}
