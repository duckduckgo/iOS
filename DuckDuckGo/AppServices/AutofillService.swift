//
//  AutofillService.swift
//  DuckDuckGo
//
//  Copyright © 2025 DuckDuckGo. All rights reserved.
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

final class AutofillService {

    private let autofillLoginSession = AppDependencyProvider.shared.autofillLoginSession
    private let autofillUsageMonitor = AutofillUsageMonitor()
    private lazy var autofillPixelReporter = AutofillPixelReporter(
        userDefaults: .standard,
        autofillEnabled: AppDependencyProvider.shared.appSettings.autofillCredentialsEnabled,
        eventMapping: EventMapping<AutofillPixelEvent> { [weak self] event, _, params, _ in
            switch event {
            case .autofillActiveUser:
                Pixel.fire(pixel: .autofillActiveUser)
            case .autofillEnabledUser:
                Pixel.fire(pixel: .autofillEnabledUser)
            case .autofillOnboardedUser:
                Pixel.fire(pixel: .autofillOnboardedUser)
            case .autofillToggledOn:
                Pixel.fire(pixel: .autofillToggledOn, withAdditionalParameters: params ?? [:])
                if let autofillExtensionToggled = self?.autofillUsageMonitor.autofillExtensionEnabled {
                    Pixel.fire(pixel: autofillExtensionToggled ? .autofillExtensionToggledOn : .autofillExtensionToggledOff,
                               withAdditionalParameters: params ?? [:])
                }
            case .autofillToggledOff:
                Pixel.fire(pixel: .autofillToggledOff, withAdditionalParameters: params ?? [:])
                if let autofillExtensionToggled = self?.autofillUsageMonitor.autofillExtensionEnabled {
                    Pixel.fire(pixel: autofillExtensionToggled ? .autofillExtensionToggledOn : .autofillExtensionToggledOff,
                               withAdditionalParameters: params ?? [:])
                }
            case .autofillLoginsStacked:
                Pixel.fire(pixel: .autofillLoginsStacked, withAdditionalParameters: params ?? [:])
            default:
                break
            }
        },
        installDate: StatisticsUserDefaults().installDate ?? Date()
    )

    func onLaunching() {
        if AppDependencyProvider.shared.appSettings.autofillIsNewInstallForOnByDefault == nil {
            AppDependencyProvider.shared.appSettings.setAutofillIsNewInstallForOnByDefault()
        }
        registerForAutofillEnabledChanges()
    }

    func onBackground() {
        autofillLoginSession.endSession()
    }

    private func registerForAutofillEnabledChanges() {
        NotificationCenter.default.addObserver(forName: AppUserDefaults.Notifications.autofillEnabledChange,
                                               object: nil,
                                               queue: nil) { _ in
            self.autofillPixelReporter.updateAutofillEnabledStatus(AppDependencyProvider.shared.appSettings.autofillCredentialsEnabled)
        }
    }

}
