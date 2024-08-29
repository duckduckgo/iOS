//
//  SecureVaultReporter.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
import BrowserServicesKit
import Core
import Common
import SecureStorage
import os.log

final class SecureVaultKeyStoreEventMapper: EventMapping<SecureStorageKeyStoreEvent> {
     public init() {
         super.init { event, _, _, _ in
             switch event {
             case .l1KeyMigration:
                 Pixel.fire(pixel: .secureVaultL1KeyMigration)
             case .l2KeyMigration:
                 Pixel.fire(pixel: .secureVaultL2KeyMigration)
             case .l2KeyPasswordMigration:
                 Pixel.fire(pixel: .secureVaultL2KeyPasswordMigration)
             }
         }
     }

     override init(mapping: @escaping EventMapping<SecureStorageKeyStoreEvent>.Mapping) {
         fatalError("Use init()")
     }
 }

final class SecureVaultReporter: SecureVaultReporting {
    private var keyStoreMapper: SecureVaultKeyStoreEventMapper
    init(keyStoreMapper: SecureVaultKeyStoreEventMapper = SecureVaultKeyStoreEventMapper()) {
        self.keyStoreMapper = keyStoreMapper
    }

    @MainActor
    func isAppBackgrounded() -> Bool {
        return UIApplication.shared.applicationState == .background
    }

    func secureVaultError(_ error: SecureStorageError) {
        #if DEBUG
        guard !ProcessInfo().arguments.contains("testing") else { return }
        #endif
        Task {
            let isBackgrounded = await isAppBackgrounded()
            // including the appVersion for debugging purposes, it should be removed before the feature is public
            let pixelParams = [PixelParameters.isBackgrounded: isBackgrounded ? "true" : "false",
                               PixelParameters.appVersion: AppVersion.shared.versionAndBuildNumber]
            switch error {
            case .initFailed(let error):
                // Silencing pixel reporting for error -25308 (attempt to access keychain while the device was locked)
                // as per https://app.asana.com/0/30173902528854/1204557908133145/f, at least temporarily
                if isBackgrounded,
                   let secureVaultError = error as? SecureStorageError,
                   let userInfo = secureVaultError.errorUserInfo["NSUnderlyingError"] as? NSError,
                   userInfo.code == -25308 {
                    Logger.general.error("SecureVault attempt to access keystore while device is locked: \(error.localizedDescription, privacy: .public)")
                    return
                }
                DailyPixel.fire(pixel: .secureVaultInitFailedError, error: error, withAdditionalParameters: pixelParams)
            case .failedToOpenDatabase(let error):
                DailyPixel.fire(pixel: .secureVaultFailedToOpenDatabaseError, error: error, withAdditionalParameters: pixelParams)
            default:
                DailyPixel.fire(pixel: .secureVaultError, error: error)

            }
        }
    }

    func secureVaultKeyStoreEvent(_ event: SecureStorageKeyStoreEvent) {
        keyStoreMapper.fire(event)
    }
}
