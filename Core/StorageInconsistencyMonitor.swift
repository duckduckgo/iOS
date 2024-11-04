//
//  StorageInconsistencyMonitoring.swift
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

import UIKit

public protocol AppActivationInconsistencyMonitoring {
    func didBecomeActive(isProtectedDataAvailable: Bool)
}

public protocol StatisticsStoreInconsistencyMonitoring {
    func statisticsDidLoad(hasFileMarker: Bool, hasInstallStatistics: Bool)
}

public protocol AdAttributionReporterInconsistencyMonitoring {
    func addAttributionReporter(hasFileMarker: Bool, hasCompletedFlag: Bool)
}

public struct StorageInconsistencyMonitor: AppActivationInconsistencyMonitoring & StatisticsStoreInconsistencyMonitoring & AdAttributionReporterInconsistencyMonitoring {

    public init() { }

    public func didBecomeActive(isProtectedDataAvailable: Bool) {
        if !isProtectedDataAvailable {
            Pixel.fire(pixel: .protectedDataUnavailableWhenBecomeActive)
            assertionFailure("This is unexpected state, debug if possible")
        }
    }

    public func statisticsDidLoad(hasFileMarker: Bool, hasInstallStatistics: Bool) {
        if hasFileMarker == true && hasInstallStatistics == false {
            Pixel.fire(pixel: .statisticsLoaderATBStateMismatch)
            assertionFailure("This is unexpected state, debug if possible")
        }
    }

    public func addAttributionReporter(hasFileMarker: Bool, hasCompletedFlag: Bool) {
        if hasFileMarker == true && hasCompletedFlag == false {
            Pixel.fire(pixel: .adAttributionReportStateMismatch)
            assertionFailure("This is unexpected state, debug if possible")
        }
    }
}
