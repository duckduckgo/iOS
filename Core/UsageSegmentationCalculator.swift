//
//  UsageSegmentationCalculator.swift
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

protocol UsageSegmentationCalculatorMaking {

    /// Creates a calculator with the provided initial state
    func make(installAtb: Atb) -> UsageSegmentationCalculating

}

protocol UsageSegmentationCalculating {

    func processAtb(_ atb: Atb, forActivityType activityType: UsageActivityType) -> [String: String]?

}

final class UsageSegmentationCalculatorFactory: UsageSegmentationCalculatorMaking {

    func make(installAtb: Atb) -> any UsageSegmentationCalculating {
        return DefaultCalculator(installAtb: installAtb)
    }

}

final class DefaultCalculatorFactory: UsageSegmentationCalculatorMaking {

    func make(installAtb: Atb) -> any UsageSegmentationCalculating {
        return DefaultCalculator(installAtb: installAtb)
    }

}

final class DefaultCalculator: UsageSegmentationCalculating {

    let installAtb: Atb
    var usageHistory = [Atb]()
    var previousAtb: Atb?
    var previousWAUSegments: Any?
    var previousMAUSegments = [Any]()

    init(installAtb: Atb) {
        self.installAtb = installAtb
    }

    func processAtb(_ atb: Atb, forActivityType activityType: UsageActivityType) -> [String: String]? {
        return [:]
    }

}
