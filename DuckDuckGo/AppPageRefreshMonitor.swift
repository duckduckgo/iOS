//
//  AppPageRefreshMonitor.swift
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

import Core
import Common
import PageRefreshMonitor
import PixelExperimentKit

extension PageRefreshMonitor {

    static let onDidDetectRefreshPattern: (NumberOfRefreshes) -> Void = { numberOfRefreshes in
        let tdsEtag = AppDependencyProvider.shared.configurationStore.loadEtag(for: .trackerDataSet) ?? ""
        switch numberOfRefreshes {
        case 2:
            TDSOverrideExperimentMetrics.fireTDSExperimentMetric(metricType: .refresh2X, etag: tdsEtag, fireDebugExperiment: { parameters in
                UniquePixel.fire(pixel: .debugBreakageExperiment, withAdditionalParameters: parameters)
            })
        case 3:
            Pixel.fire(pixel: .pageRefreshThreeTimesWithin20Seconds)
            TDSOverrideExperimentMetrics.fireTDSExperimentMetric(metricType: .refresh3X, etag: tdsEtag, fireDebugExperiment: { parameters in
                UniquePixel.fire(pixel: .debugBreakageExperiment, withAdditionalParameters: parameters)
            })
        default:
            return
        }
    }

}
