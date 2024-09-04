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

final class UsageSegmentation: UsageSegmenting {

    private let pixelFiring: PixelFiring.Type
    private let storage: UsageSegmentationStoring
    private let calculatorFactory: UsageSegmentationCalculatorMaking

    init(pixelFiring: PixelFiring.Type = Pixel.self,
         storage: UsageSegmentationStoring = UsageSegmentationStorage(),
         calculatorFactory: UsageSegmentationCalculatorMaking = DefaultCalculatorFactory()) {
        self.pixelFiring = pixelFiring
        self.storage = storage
        self.calculatorFactory = calculatorFactory
    }

    func processATB(_ atb: Atb, withInstallAtb installAtb: Atb, andActivityType activityType: UsageActivityType) {
        var atbs = activityType.atbsFromStorage(storage)

        guard !atbs.contains(where: { $0 == atb }) else { return }

        defer {
            activityType.updateStorage(storage, withAtbs: atbs)
        }

        if atbs.isEmpty {
           atbs.append(installAtb)
        }

        if installAtb != atb {
           atbs.append(atb)
        }

        var pixelInfo: [String: String]?
        let calculator = calculatorFactory.make(installAtb: installAtb)
        
        // The calculator updates its internal state starting from the first atb, so iterate over them all and take
        //  the last result.
        // 
        // This is pretty fast (see performance test) and consider that we'll have max 1 atb per day so over a few years it's up
        //  to the mid thousands so hardly taxing.
        for atb in atbs {
            pixelInfo = calculator.processAtb(atb, forActivityType: activityType)
        }

        if let pixelInfo {
            pixelFiring.fire(.usageSegments, withAdditionalParameters: pixelInfo, includedParameters: [], onComplete: { _ in })
        }
    }

}

private extension UsageActivityType {

    func atbsFromStorage(_ storage: UsageSegmentationStoring) -> [Atb] {
        switch self {
        case .appUse: return storage.appUseAtbs
        case .search: return storage.searchAtbs
        }
    }

    func updateStorage(_ storage: UsageSegmentationStoring, withAtbs atbs: [Atb]) {
        var storage = storage
        switch self {
        case .appUse:
            storage.appUseAtbs = atbs
        case .search:
            storage.searchAtbs = atbs
        }
    }

}
