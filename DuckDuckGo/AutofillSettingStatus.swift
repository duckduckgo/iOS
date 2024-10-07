//
//  AutofillSettingStatus.swift
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
import LocalAuthentication
import UIKit

protocol AutofillSettingStatusProtocol {
    var deviceAuthenticationEnabled: Bool { get }
    var isAutofillEnabledInSettings: Bool { get }
}

final class AutofillSettingStatus: AutofillSettingStatusProtocol {

    var deviceAuthenticationEnabled: Bool

    var isAutofillEnabledInSettings: Bool {
        return deviceAuthenticationEnabled && appSettings.autofillCredentialsEnabled
    }

    private let appSettings: AppSettings

    init(appSettings: AppSettings = AppDependencyProvider.shared.appSettings) {
        self.appSettings = appSettings

        self.deviceAuthenticationEnabled = Self.refreshDeviceAuthenticationStatus()
        registerForApplicationEvents()
    }

    private func registerForApplicationEvents() {
        _ = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification,
                                                   object: nil,
                                                   queue: .main) { [weak self] _ in
            self?.updateDeviceAuthenticationStatus()
        }
    }

    private static func refreshDeviceAuthenticationStatus() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
    }

    private func updateDeviceAuthenticationStatus() {
        deviceAuthenticationEnabled = Self.refreshDeviceAuthenticationStatus()
    }
}
