//
//  MockUsageSegmentation.swift
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
@testable import BrowserServicesKit

final class MockUsageSegmentation: UsageSegmenting {

    struct ProcessATBArgs {

        let atb: Atb
        let installAtb: Atb
        let activityType: UsageActivityType

    }

    var atbs: [ProcessATBArgs] = []

    func processATB(_ atb: Atb, withInstallAtb installAtb: Atb, andActivityType activityType: UsageActivityType) {
        atbs.append(ProcessATBArgs(atb: atb, installAtb: installAtb, activityType: activityType))
    }
}
