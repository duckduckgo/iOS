//
//  AutofillNeverPromptWebsitesManager.swift
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
import BrowserServicesKit
import Core

class AutofillNeverPromptWebsitesManager {

    public private(set) var neverPromptWebsites: [SecureVaultModels.NeverPromptWebsites] = []

    private let secureVault: (any AutofillSecureVault)?

    public init(secureVault: (any AutofillSecureVault)? = try? AutofillSecureVaultFactory.makeVault(errorReporter: SecureVaultErrorReporter.shared)) {
        self.secureVault = secureVault

        fetchNeverPromptWebsites()
    }

    public func hasNeverPromptWebsitesFor(domain: String) -> Bool {
        return neverPromptWebsites.contains { $0.domain == domain }
    }

    public func saveNeverPromptWebsite(_ domain: String) throws -> Int64? {
        guard let secureVault = secureVault else {
            return nil
        }

        do {
            let id = try secureVault.storeNeverPromptWebsites(SecureVaultModels.NeverPromptWebsites(domain: domain))

            fetchNeverPromptWebsites()
            return id
        } catch {
            Pixel.fire(pixel: .secureVaultError, error: error)
            throw error
        }
    }

    public func deleteAllNeverPromptWebsites() -> Bool {
        guard let secureVault = secureVault else {
            return false
        }

        do {
            try secureVault.deleteAllNeverPromptWebsites()

            fetchNeverPromptWebsites()
            return true
        } catch {
            Pixel.fire(pixel: .secureVaultError, error: error)
            return false
        }
    }

    private func fetchNeverPromptWebsites() {
        guard let secureVault = secureVault else {
            return
        }

        do {
            neverPromptWebsites = try secureVault.neverPromptWebsites()
        } catch {
            Pixel.fire(pixel: .secureVaultError, error: error)
            neverPromptWebsites = []
        }
    }
}
