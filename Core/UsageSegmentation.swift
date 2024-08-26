//
//  UsageSegmentation.swift
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

enum UsageActivityType: String {

    case search
    case appUse = "app_use"

}

protocol UsageSegmenting {

    func processATB(_ atb: Atb, withInstallAtb installAtb: Atb, andActivityType activityType: UsageActivityType)

}

class UsageSegmentation: UsageSegmenting {

    private let pixelFiring: DailyPixelFiring.Type
    private let storage: UsageSegmentationStoring
    private let calculatorFactory: UsageSegmentationCalculatorMaking

    init(pixelFiring: DailyPixelFiring.Type = DailyPixel.self,
         storage: UsageSegmentationStoring = UsageSegmentationStorage(),
         calculatorFactory: UsageSegmentationCalculatorMaking = DefaultCalculatorFactory()) {
        self.pixelFiring = pixelFiring
        self.storage = storage
        self.calculatorFactory = calculatorFactory
    }

    func processATB(_ atb: Atb, withInstallAtb installAtb: Atb, andActivityType activityType: UsageActivityType) {

        guard !storage.atbs.reversed().contains(where: { $0 == atb }) else {
            return
        }

        var storage = storage
        if storage.atbs.isEmpty {
            storage.atbs.append(installAtb)
        }

        if installAtb != atb {
            storage.atbs.append(atb)
        }

        // TODO write a stateful calculator
        //  * should return no parameters unless a pixel should be fired
        var pixelInfo: [String: String]?
        let calculator = calculatorFactory.make(installAtb: installAtb)
        for atb in storage.atbs {
            pixelInfo = calculator.processAtb(atb, forActivityType: activityType)
        }

        if let pixelInfo {
            pixelFiring.fireDaily(.usageSegments, withAdditionalParameters: pixelInfo)
        }
    }

}
