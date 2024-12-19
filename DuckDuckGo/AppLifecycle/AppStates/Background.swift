//
//  Background.swift
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
import Core

struct Background: AppState {

    let timestamp = Date()

    init(application: UIApplication) {

    }

}

struct DoubleBackground: AppState {

    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    let firstTimeBackgroundTimestamp: Date
    var consecutiveTimestamps: [Date]

    init(firstTimeBackgroundTimestamp: Date) {
        self.firstTimeBackgroundTimestamp = firstTimeBackgroundTimestamp
        let lastTimestamp = Date()
        consecutiveTimestamps.append(lastTimestamp)

        var parameters = [PixelParameters.firstBackgroundTimestamp: dateFormatter.string(from: firstTimeBackgroundTimestamp)]

        let formattedConsecutiveTimestamps = consecutiveTimestamps.map { dateFormatter.string(from: $0) }
        parameters[PixelParameters.consecutiveBackgroundTimestamps] = formattedConsecutiveTimestamps.joined(separator: ",")

        func isValid(timestamp: Date) -> Bool {
            timestamp >= firstTimeBackgroundTimestamp && timestamp <= lastTimestamp
        }

        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            if let didReceiveMemoryWarningTimestamp = appDelegate.didReceiveMemoryWarningTimestamp,
                isValid(timestamp: didReceiveMemoryWarningTimestamp) {
                parameters[PixelParameters.didReceiveMemoryWarningTimestamp] = dateFormatter.string(from: didReceiveMemoryWarningTimestamp)
            }
            if let didReceiveMXPayloadTimestamp = appDelegate.didReceiveMXPayloadTimestamp,
                isValid(timestamp: didReceiveMXPayloadTimestamp) {
                parameters[PixelParameters.didReceiveMXPayloadTimestamp] = dateFormatter.string(from: didReceiveMXPayloadTimestamp)
            }
            if let didReceiveUNNotification = appDelegate.didReceiveUNNotification,
                isValid(timestamp: didReceiveUNNotification) {
                parameters[PixelParameters.didReceiveUNNotification] = dateFormatter.string(from: didReceiveUNNotification)
            }
            if let didStartRemoteMessagingClientBackgroundTask = appDelegate.didStartRemoteMessagingClientBackgroundTask,
                isValid(timestamp: didStartRemoteMessagingClientBackgroundTask) {
                parameters[PixelParameters.didStartRemoteMessagingClientBackgroundTask] = dateFormatter.string(from: didStartRemoteMessagingClientBackgroundTask)
            }
            if let didStartAppConfigurationFetchBackgroundTask = appDelegate.didStartAppConfigurationFetchBackgroundTask,
                isValid(timestamp: didStartAppConfigurationFetchBackgroundTask) {
                parameters[PixelParameters.didStartAppConfigurationFetchBackgroundTask] = dateFormatter.string(from: didStartAppConfigurationFetchBackgroundTask)
            }
        }
        Pixel.fire(pixel: .appDidBackgroundTwice, withAdditionalParameters: parameters)
    }

}
