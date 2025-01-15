//
//  ImportPasswordsViaSyncStatusHandler.swift
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
import Core
import DDGSync

class ImportPasswordsViaSyncStatusHandler {

    private let appSettings: AppSettings
    private let syncService: DDGSyncing

    init(appSettings: AppSettings = AppDependencyProvider.shared.appSettings,
         syncService: DDGSyncing) {
        self.appSettings = appSettings
        self.syncService = syncService
    }

    func setImportViaSyncStartDateIfRequired() {
        guard syncService.authState != .inactive else {
            appSettings.autofillImportViaSyncStart = Date()
            return
        }

        Task {
            if await !hasSyncedDesktopDevice(syncService: syncService) {
                appSettings.autofillImportViaSyncStart = Date()
            }
        }
    }

    func checkSyncSuccessStatus() {
        guard let importCheckStartDate = appSettings.autofillImportViaSyncStart else {
            return
        }
        
        if importCheckStartDate.isLessThan48HoursAgo() {
            guard syncService.authState != .inactive else {
                return
            }
            Task {
                if await hasSyncedDesktopDevice(syncService: syncService) {
                    clearSettingAndFirePixel(.autofillLoginsImportSuccess)
                }
            }
        } else {
            guard syncService.authState != .inactive else {
                clearSettingAndFirePixel(.autofillLoginsImportFailure)
                return
            }

            Task {
                if await hasSyncedDesktopDevice(syncService: syncService) {
                    appSettings.clearAutofillImportViaSyncStart()
                } else {
                    clearSettingAndFirePixel(.autofillLoginsImportFailure)
                }
            }
        }
    }

    func clearSettingAndFirePixel(_ type: Pixel.Event) {
        Pixel.fire(pixel: type)
        appSettings.clearAutofillImportViaSyncStart()
    }

    private func hasSyncedDesktopDevice(syncService: DDGSyncing) async -> Bool {
        guard let devices = try? await syncService.fetchDevices() else {
            return false
        }
        let desktopDevices = devices.filter { $0.type == "desktop" }
        return !desktopDevices.isEmpty
    }

}
