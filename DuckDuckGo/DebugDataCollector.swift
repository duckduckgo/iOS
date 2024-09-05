//
//  DebugDataCollector.swift
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
import Persistence

public final class DebugDataCollector {

    public static let current = DebugDataCollector()

    private var application: UIApplication?
    private var launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    private var isRunningBGFetch = false
    private var didRunBGFetch = false
    private var isRunningAutoclear = false
    private var instanceUUID = UUID()

    public var debugParameters: [String: String] {

        let getParams: () -> [String: String] = {
            var params = [String: String]()
            if let application = self.application {
                params[PixelParameters.applicationState] = "\(application.applicationState.rawValue)"
                params[PixelParameters.isDataProtected] = "\(!application.isProtectedDataAvailable)"
                params[PixelParameters.backgroundRefreshStatus] = "\(application.backgroundRefreshStatus.rawValue)"
            }

            params[PixelParameters.didRunBGFetch] = "\(self.didRunBGFetch)"
            params[PixelParameters.isRunningBGFetch] = "\(self.isRunningBGFetch)"
            params[PixelParameters.isRunningAutoclear] = "\(self.isRunningAutoclear)"

            params[PixelParameters.launchOptions] = self.launchOptions?.description
            params[PixelParameters.instanceUUID] = self.instanceUUID.uuidString

            return params
        }

        if Thread.isMainThread {
            return getParams()
        } else {
            return DispatchQueue.main.sync {
                getParams()
            }
        }
    }

    public func isLaunching(_ application: UIApplication, with options: [UIApplication.LaunchOptionsKey: Any]?) {
        self.application = application
        self.launchOptions = options
        firePixel(PixelName.launchingEntry)
    }

    public func finishedLaunching() {
        firePixel(PixelName.launchingReturn)
    }

    public func startedBackgroundFetch() {
        isRunningBGFetch = true
        didRunBGFetch = true
        firePixel(PixelName.startedBGFetch)
    }

    public func finishedBackgroundFetch() {
        isRunningBGFetch = false
        firePixel(PixelName.finishedBGFetch)
    }

    public func loadingHistoryDB() {
        firePixel(PixelName.startedLoadingHistory)
    }

    public func loadingHistoryData() {
        firePixel(PixelName.loadingHistoryDataStarted)
    }

    public func finishedLoadingHistoryDB(_ error: Error?) {
        var params = [String: String]()
        if let error {
            let errorInfo = CoreDataErrorsParser.parse(error: error as NSError)
            params["cd_error"] = errorInfo.debugDescription
        }
        firePixel(PixelName.finishedLoadingHistory, params: params)
    }

    public func historyDataCleaningFinished(error: Error? = nil) {
        var params = [String: String]()
        if let error {
            let errorInfo = CoreDataErrorsParser.parse(error: error as NSError)
            params["cd_error"] = errorInfo.debugDescription
        }
        firePixel(PixelName.historyDataCleaningFinished)
    }

    public func startingAutoclear() {
        isRunningAutoclear = true
        firePixel(PixelName.staredAutoclear)
    }

    public func finishedAutoclear() {
        isRunningAutoclear = false
        firePixel(PixelName.finishedAutoclear)
    }

    private func firePixel(_ named: String, params: [String: String] = [:]) {
        Pixel.fire(pixelNamed: named, withAdditionalParameters: params)
    }

    private struct PixelName {
        static let launchingEntry = "debug_app_launching_entry"
        static let launchingReturn = "debug_app_launching_return"

        static let startedBGFetch = "debug_bg_fetch_start"
        static let finishedBGFetch = "debug_bg_fetch_start"

        static let staredAutoclear = "debug_ac_start"
        static let finishedAutoclear = "debug_ac_finish"

        static let startedLoadingHistory = "debug_loading_history_db_start"
        static let finishedLoadingHistory = "debug_loading_history_db_finish"

        static let loadingHistoryDataStarted = "debug_loading_history_data_start"
        static let historyDataCleaningFinished = "debug_history_data_cleaning_finished"
    }

    private struct PixelParameters {
        static let backgroundRefreshStatus = "bg_refresh_status"
        static let applicationState = "app_state"
        static let isDataProtected = Core.PixelParameters.isDataProtected
        static let launchOptions = "launch_options"
        static let instanceUUID = "instance_uuid"
        static let didRunBGFetch = "did_run_bg_fetch"
        static let isRunningBGFetch = "is_running_bg_fetch"
        static let isRunningAutoclear = "is_running_autoclear"
    }
}

private extension CoreDataErrorsParser.ErrorInfo {
    var debugDescription: String {
        "code: \(code); domain: \(domain); entity: \(entity); property: \(property))"
    }
}
