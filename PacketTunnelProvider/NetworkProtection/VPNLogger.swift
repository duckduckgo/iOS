//
//  VPNLogger.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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
import NetworkProtection
// swiftlint:disable:next enforce_os_log_wrapper
import OSLog

/// Logger for the VPN
///
/// Since we'll want to ensure this adheres to our privacy standards, grouping the logging logic to be mostly
/// handled by a single class sounds like a good approach to be able to review what's being logged..
///
public final class VPNLogger {
    public typealias AttemptStep = PacketTunnelProvider.AttemptStep
    public typealias ConnectionAttempt = PacketTunnelProvider.ConnectionAttempt
    public typealias ConnectionTesterStatus = PacketTunnelProvider.ConnectionTesterStatus
    public typealias LogCallback = (OSLogType, OSLogMessage) -> Void

    public init() {}

    public func logStartingWithoutAuthToken() {
        os_log("🔴 Starting tunnel without an auth token", log: .networkProtection, type: .error)
    }

    public func log(_ step: AttemptStep, named name: String) {
        let log = OSLog.networkProtection

        switch step {
        case .begin:
            os_log("🔵 %{public}@ attempt begins", log: log, name)
        case .failure(let error):
            os_log("🔴 %{public}@ attempt failed with error: %{public}@", log: log, type: .error, name, error.localizedDescription)
        case .success:
            os_log("🟢 %{public}@ attempt succeeded", log: log, name)
        }
    }

    public func log(_ step: ConnectionAttempt) {
        let log = OSLog.networkProtection

        switch step {
        case .connecting:
            os_log("🔵 Connection attempt detected", log: log)
        case .failure:
            os_log("🔴 Connection attempt failed", log: log, type: .error)
        case .success:
            os_log("🟢 Connection attempt successful", log: log)
        }
    }

    public func log(_ status: ConnectionTesterStatus) {
        let log = OSLog.networkProtectionConnectionTesterLog

        switch status {
        case .failed(let duration):
            os_log("🔴 Connection tester (%{public}@) failure", log: log, type: .error, duration.rawValue)
        case .recovered(let duration, let failureCount):
            os_log("🟢 Connection tester (%{public}@) recovery (after %{public}@ failures)", log: log, duration.rawValue, String(failureCount))
        }
    }

    public func log(_ step: FailureRecoveryStep) {
        let log = OSLog.networkProtectionTunnelFailureMonitorLog

        switch step {
        case .started:
            os_log("🔵 Failure Recovery attempt started", log: log)
        case .failed(let error):
            os_log("🔴 Failure Recovery attempt failed with error: %{public}@", log: log, type: .error, error.localizedDescription)
        case .completed(let health):
            switch health {
            case .healthy:
                os_log("🟢 Failure Recovery attempt completed", log: log)
            case .unhealthy:
                os_log("🔴 Failure Recovery attempt ended as unhealthy", log: log, type: .error)
            }
        }
    }

    public func log(_ step: NetworkProtectionTunnelFailureMonitor.Result) {
        let log = OSLog.networkProtectionTunnelFailureMonitorLog

        switch step {
        case .failureDetected:
            os_log("🔴 Tunnel failure detected", log: log, type: .error)
        case .failureRecovered:
            os_log("🟢 Tunnel failure recovered", log: log)
        case .networkPathChanged:
            os_log("🔵 Tunnel recovery detected path change", log: log)
        }
    }

    public func log(_ result: NetworkProtectionLatencyMonitor.Result) {
        let log = OSLog.networkProtectionLatencyMonitorLog

        switch result {
        case .error:
            os_log("🔴 There was an error logging the latency", log: log, type: .error)
        case .quality(let quality):
            os_log("Connection quality is: %{public}@", log: log, quality.rawValue)
        }
    }
}
