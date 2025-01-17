//
//  PixelExperimentKitCutomMetrics.swift
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
import PixelExperimentKit
import PixelKit
import Configuration

//class BreakageExperimentMetrics {
//    func fireExperimentMetricPrivacyToggleUsed() {
//        for experiment in TdsExperimentType.allCases {
//            for day in 0...5 {
//                PixelKit.fireExperimentPixel(for: experiment.subfeature.rawValue, metric: "privacyToggleUsed", conversionWindowDays: day...day, value: "1")
//                UniquePixel.fireDebugBreakageExperiment()
//            }
//        }
//    }
//
//    
//}

public extension PixelKit {
    static func fireExperimentMetricPrivacyToggleUsed() {
        for experiment in TdsExperimentType.allCases {
            for day in 0...5 {
                PixelKit.fireExperimentPixel(for: experiment.subfeature.rawValue, metric: "privacyToggleUsed", conversionWindowDays: day...day, value: "1")
                UniquePixel.fireDebugBreakageExperiment()
            }
        }
    }
}

public extension UniquePixel {
    static func fireDebugBreakageExperiment(experiment: TdsExperimentType) {
        let parameters = [
            "experiment": experiment.subfeature.rawValue + AppDependencyProvider.shared.featureFlagger
        ]
        UniquePixel.fire(pixel: .debugBreakageExperiment, withAdditionalParameters: <#T##[String : String]#>)
    }
}
