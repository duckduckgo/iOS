//
//  SecureVaultErrorReporter.swift
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

final class SecureVaultErrorReporter: SecureVaultErrorReporting {
    static let shared = SecureVaultErrorReporter()
    private init() {}

    func secureVaultInitFailed(_ error: SecureStorageError) {
#if DEBUG
        guard !ProcessInfo().arguments.contains("testing") else { return }
#endif
        let isBackgrounded = UIApplication.shared.applicationState == .background
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
                os_log("SecureVault attempt to access keystore while device is locked: %@",
                       log: .generalLog,
                       type: .debug,
                       error.localizedDescription)
                return
            }
            Pixel.fire(pixel: .secureVaultInitFailedError, error: error, withAdditionalParameters: pixelParams)
        case .failedToOpenDatabase(let error):
            Pixel.fire(pixel: .secureVaultFailedToOpenDatabaseError, error: error, withAdditionalParameters: pixelParams)
        default:
            Pixel.fire(pixel: .secureVaultError, error: error)

        }
    }
}
