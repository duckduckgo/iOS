//
//  StorageInconsistencyMonitor.swift
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
    /// See `StorageInconsistencyMonitor` for details
    func didBecomeActive(isProtectedDataAvailable: Bool)
}

public protocol StatisticsStoreInconsistencyMonitoring {
    /// See `StorageInconsistencyMonitor` for details
    func statisticsDidLoad(hasFileMarker: Bool, hasInstallStatistics: Bool)
}

public protocol AdAttributionReporterInconsistencyMonitoring {
    /// See `StorageInconsistencyMonitor` for details
    func addAttributionReporter(hasFileMarker: Bool, hasCompletedFlag: Bool)
}

/// Takes care of reporting inconsistency in storage availability and/or state.
/// See https://app.asana.com/0/481882893211075/1208618515043198/f for details.
public struct StorageInconsistencyMonitor: AppActivationInconsistencyMonitoring & StatisticsStoreInconsistencyMonitoring & AdAttributionReporterInconsistencyMonitoring {

    public init() { }

    /// Reports a pixel if data is not available while app is active
    public func didBecomeActive(isProtectedDataAvailable: Bool) {
        if !isProtectedDataAvailable {
            Pixel.fire(pixel: .protectedDataUnavailableWhenBecomeActive)
            assertionFailure("This is unexpected state, debug if possible")
        }
    }

    /// Reports a pixel if file marker exists but installStatistics are missing
    public func statisticsDidLoad(hasFileMarker: Bool, hasInstallStatistics: Bool) {
        if hasFileMarker == true && hasInstallStatistics == false {
            Pixel.fire(pixel: .statisticsLoaderATBStateMismatch)
            assertionFailure("This is unexpected state, debug if possible")
        }
    }

    /// Reports a pixel if file marker exists but completion flag is false
    public func addAttributionReporter(hasFileMarker: Bool, hasCompletedFlag: Bool) {
        if hasFileMarker == true && hasCompletedFlag == false {
            Pixel.fire(pixel: .adAttributionReportStateMismatch)
            assertionFailure("This is unexpected state, debug if possible")
        }
    }
}
