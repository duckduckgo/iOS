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
import Core

public extension PixelKit {
    static func fireTdsExperimentMetricPrivacyToggleUsed() {
        for experiment in TdsExperimentType.allCases {
            for day in 0...5 {
                PixelKit.fireExperimentPixel(for: experiment.subfeature.rawValue, metric: "privacyToggleUsed", conversionWindowDays: day...day, value: "1")
                UniquePixel.fireDebugBreakageExperiment(experimentType: experiment)
            }
        }
    }

    static func fireTdsExperimentMetric2XRefresh() {
        for experiment in TdsExperimentType.allCases {
            for day in 0...5 {
                PixelKit.fireExperimentPixel(for: experiment.subfeature.rawValue, metric: "privacyToggleUsed", conversionWindowDays: day...day, value: "1")
                UniquePixel.fireDebugBreakageExperiment(experimentType: experiment)
            }
        }
    }

    static func fireTdsExperimentMetric3XRefresh() {
        for experiment in TdsExperimentType.allCases {
            for day in 0...5 {
                PixelKit.fireExperimentPixel(for: experiment.subfeature.rawValue, metric: "privacyToggleUsed", conversionWindowDays: day...day, value: "1")
                UniquePixel.fireDebugBreakageExperiment(experimentType: experiment)
            }
        }
    }
}

private extension UniquePixel {
    static func fireDebugBreakageExperiment(experimentType: TdsExperimentType) {
        let featureFlagger = AppDependencyProvider.shared.featureFlagger
        let subfeatureID = experimentType.subfeature.rawValue
        let wasCohortAssigned = featureFlagger.getAllActiveExperiments().contains(where: { $0.key == subfeatureID })
        guard let experimentData = featureFlagger.getAllActiveExperiments()[subfeatureID] else { return }
        guard wasCohortAssigned else { return }
        let experimentName: String = subfeatureID + experimentData.cohortID
        let enrolmentDate = experimentData.enrollmentDate.toYYYYMMDDInET()
        let parameters = [
            "experiment": experimentName,
            "enrolmentDate": enrolmentDate,
            "tdsEtag": ConfigurationStore().loadEtag(for: .trackerDataSet) ?? ""
        ]
        UniquePixel.fire(pixel: .debugBreakageExperiment, withAdditionalParameters: parameters)
    }
}
