//
//  AutofillUsageMonitor.swift
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

import Core
import AuthenticationServices
import BrowserServicesKit

final class AutofillUsageMonitor {

    private lazy var credentialIdentityStoreManager: AutofillCredentialIdentityStoreManager = {
        return AutofillCredentialIdentityStoreManager(reporter: SecureVaultReporter(),
                                                      tld: AppDependencyProvider.shared.storageCache.tld)
    }()

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveSaveEvent), name: .autofillSaveEvent, object: nil)

        if autofillExtensionEnabled != nil {
            AutofillVaultKeychainMigrator().resetVaultMigrationIfRequired()
        }

        ASCredentialIdentityStore.shared.getState({ [weak self] state in
            if state.isEnabled {
                if self?.autofillExtensionEnabled == nil {
                    Task {
                        await self?.credentialIdentityStoreManager.populateCredentialStore()
                    }
                }
                self?.autofillExtensionEnabled = true
            } else {
                if self?.autofillExtensionEnabled == true {
                    Pixel.fire(pixel: .autofillExtensionDisabled)
                    self?.autofillExtensionEnabled = false
                }
            }
        })
    }

    @UserDefaultsWrapper(key: .autofillExtensionEnabled, defaultValue: nil)
    var autofillExtensionEnabled: Bool?

    @UserDefaultsWrapper(key: .autofillFirstTimeUser, defaultValue: true)
    private var autofillFirstTimeUser: Bool

    @objc private func didReceiveSaveEvent() {
        autofillFirstTimeUser = false
    }
}
