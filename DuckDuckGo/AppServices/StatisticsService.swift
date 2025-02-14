//
//  StatisticsService.swift
//  DuckDuckGo
//
//  Copyright © 2025 DuckDuckGo. All rights reserved.
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

public extension NSNotification.Name {

    static let didLoadStatisticsOnForeground = Notification.Name("com.duckduckgo.app.didLoadStatisticsOnForeground")

}

final class StatisticsService {

    private lazy var statisticsLoader: StatisticsLoader = .shared

    // MARK: - Resume

    func resume() {
        statisticsLoader.load {
            NotificationCenter.default.post(name: .didLoadStatisticsOnForeground, object: nil)
        }
    }

}
