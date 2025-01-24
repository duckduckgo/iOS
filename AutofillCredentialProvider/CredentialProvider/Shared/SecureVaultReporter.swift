//
//  SecureVaultReporter.swift
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

import Common
import Core
import Foundation
import SecureStorage

final class SecureVaultReporter: SecureVaultReporting {

    func secureVaultError(_ error: SecureStorage.SecureStorageError) {
#if DEBUG
        guard !ProcessInfo().arguments.contains("testing") else { return }
#endif
        let pixelParams = [PixelParameters.isBackgrounded: "false",
                           PixelParameters.appVersion: AppVersion.shared.versionAndBuildNumber,
                           PixelParameters.isExtension: "true"]

        switch error {
        case .initFailed(let error):
            DailyPixel.fire(pixel: .secureVaultInitFailedError, error: error, withAdditionalParameters: pixelParams)
        case .failedToOpenDatabase(let error):
            DailyPixel.fire(pixel: .secureVaultFailedToOpenDatabaseError, error: error, withAdditionalParameters: pixelParams)
        default:
            DailyPixel.fire(pixel: .secureVaultError, error: error)
        }
    }

}
