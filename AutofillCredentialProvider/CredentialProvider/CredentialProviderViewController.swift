//
//  CredentialProviderViewController.swift
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

import AuthenticationServices
import SwiftUI
import BrowserServicesKit
import Core
import Common
import os.log

class CredentialProviderViewController: ASCredentialProviderViewController {

    private struct Constants {
        static let openPasswords = AppDeepLinkSchemes.openPasswords.url
    }

    private lazy var authenticator = UserAuthenticator(reason: UserText.credentialProviderListAuthenticationReason,
                                                       cancelTitle: UserText.credentialProviderListAuthenticationCancelButton)

    private lazy var credentialIdentityStoreManager: AutofillCredentialIdentityStoreManaging = AutofillCredentialIdentityStoreManager(
        credentialStore: ASCredentialIdentityStore.shared,
        vault: secureVault,
        reporter: SecureVaultReporter(),
        tld: tld)

    private lazy var secureVault: (any AutofillSecureVault)? = {
        if findKeychainItemsWithV4() {
            return try? AutofillSecureVaultFactory.makeVault(reporter: SecureVaultReporter())
        } else {
            return nil
        }
    }()

    private lazy var tld: TLD = TLD()

    private lazy var vaultCredentialManager: VaultCredentialManaging = VaultCredentialManager(secureVault: secureVault,
                                                                                              credentialIdentityStoreManager: credentialIdentityStoreManager)

    private lazy var autofillPixelReporter: AutofillPixelReporter? = {
        guard let sharedUserDefaults = UserDefaults(suiteName: "\(Global.groupIdPrefix).autofill"), sharedUserDefaults.bool(forKey: AutofillPixelReporter.Keys.autofillDauMigratedKey) else {
            return nil
        }

        return AutofillPixelReporter(
            standardUserDefaults: .standard,
            appGroupUserDefaults: UserDefaults(suiteName: "\(Global.groupIdPrefix).autofill"),
            autofillEnabled: true,
            eventMapping: EventMapping<AutofillPixelEvent> { event, _, params, _ in
                switch event {
                case .autofillActiveUser:
                    Pixel.fire(pixel: .autofillActiveUser)
                case .autofillLoginsStacked:
                    Pixel.fire(pixel: .autofillLoginsStacked, withAdditionalParameters: params ?? [:])
                default:
                    break
                }
            },
            installDate: StatisticsUserDefaults().installDate ?? Date())
    }()

    // MARK: - ASCredentialProviderViewController Overrides

    override func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier]) {
        loadCredentialsList(for: serviceIdentifiers)
    }

    override func provideCredentialWithoutUserInteraction(for credentialIdentity: ASPasswordCredentialIdentity) {
        // A quirk here is calling .canAuthenticate in this one scenario actually triggers the prompt to authentication
        // Calling .authenticate here results in the extension attempting to present a non-existent view controller causing weird UI
        if authenticator.canAuthenticateViaBiometrics() {
            provideCredential(for: credentialIdentity)
        } else {
            self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain,
                                                                   code: ASExtensionError.userInteractionRequired.rawValue))
        }
    }

    @available(iOS 17.0, *)
    override func provideCredentialWithoutUserInteraction(for credentialRequest: any ASCredentialRequest) {
        guard credentialRequest.type == .password else {
            self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain,
                                                                   code: ASExtensionError.credentialIdentityNotFound.rawValue))
            return
        }

        if authenticator.canAuthenticateViaBiometrics() {
            provideCredential(for: credentialRequest.credentialIdentity)
        } else {
            self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain,
                                                                   code: ASExtensionError.userInteractionRequired.rawValue))
        }
    }

    override func prepareInterfaceToProvideCredential(for credentialIdentity: ASPasswordCredentialIdentity) {
        let hostingController = UIHostingController(rootView: LockScreenView())
        installChildViewController(hostingController)

        authenticateAndHandleCredential {
            self.provideCredential(for: credentialIdentity)
        }
    }

    @available(iOS 17.0, *)
    override func prepareInterfaceToProvideCredential(for credentialRequest: any ASCredentialRequest) {
        let hostingController = UIHostingController(rootView: LockScreenView())
        installChildViewController(hostingController)

        authenticateAndHandleCredential {
            self.provideCredential(for: credentialRequest.credentialIdentity)
        }
    }

    override func prepareInterfaceForExtensionConfiguration() {
        let viewModel = CredentialProviderActivatedViewModel { [weak self] shouldLaunchApp in
            if shouldLaunchApp {
                self?.openUrl(Constants.openPasswords)
            }
            self?.extensionContext.completeExtensionConfigurationRequest()
        }

        let view = CredentialProviderActivatedView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        installChildViewController(hostingController)

        Task {
            if findKeychainItemsWithV4() {
                await credentialIdentityStoreManager.populateCredentialStore()
            }
        }

        Pixel.fire(pixel: .autofillExtensionEnabled)
    }

    @available(iOSApplicationExtension 18.0, *)
    override func prepareInterfaceForUserChoosingTextToInsert() {
        loadCredentialsList(for: [], shouldProvideTextToInsert: true)
    }

    // MARK: - Private

    private func loadCredentialsList(for serviceIdentifiers: [ASCredentialServiceIdentifier], shouldProvideTextToInsert: Bool = false) {
        let credentialProviderListViewController = CredentialProviderListViewController(serviceIdentifiers: serviceIdentifiers,
                                                                                        secureVault: secureVault,
                                                                                        credentialIdentityStoreManager: credentialIdentityStoreManager,
                                                                                        shouldProvideTextToInsert: shouldProvideTextToInsert,
                                                                                        tld: tld,
                                                                                        onRowSelected: { [weak self] item in
            guard let self = self else {
                self?.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain,
                                                                        code: ASExtensionError.failed.rawValue))
                return
            }

            let credential = self.vaultCredentialManager.fetchCredential(for: item.account)

            self.extensionContext.completeRequest(withSelectedCredential: credential, completionHandler: nil)
            reportFillEvent()

        }, onTextProvided: { [weak self] text in
            if #available(iOSApplicationExtension 18.0, *) {
                self?.extensionContext.completeRequest(withTextToInsert: text)
                self?.reportFillEvent()
            }
        }, onDismiss: {
            self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain,
                                                                   code: ASExtensionError.userCanceled.rawValue))
        })

        let navigationController = UINavigationController(rootViewController: credentialProviderListViewController)
        self.view.subviews.forEach { $0.removeFromSuperview() }
        addChild(navigationController)
        navigationController.view.frame = self.view.bounds
        navigationController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(navigationController.view)
        navigationController.didMove(toParent: self)
    }

    @available(iOS 17.0, *)
    private func provideCredential(for credentialIdentity: ASCredentialIdentity) {
        guard let passwordCredential = vaultCredentialManager.fetchCredential(for: credentialIdentity) else {
            self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain,
                                                                   code: ASExtensionError.credentialIdentityNotFound.rawValue))
            Pixel.fire(pixel: .autofillExtensionQuickTypeCancelled)
            return
        }

        self.extensionContext.completeRequest(withSelectedCredential: passwordCredential)
        Pixel.fire(pixel: .autofillExtensionQuickTypeConfirmed)
        reportFillEvent()
    }

    private func provideCredential(for credentialIdentity: ASPasswordCredentialIdentity) {
        guard let passwordCredential = vaultCredentialManager.fetchCredential(for: credentialIdentity) else {
            self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain,
                                                                   code: ASExtensionError.credentialIdentityNotFound.rawValue))
            Pixel.fire(pixel: .autofillExtensionQuickTypeCancelled)
            return
        }

        self.extensionContext.completeRequest(withSelectedCredential: passwordCredential)
        Pixel.fire(pixel: .autofillExtensionQuickTypeConfirmed)
        reportFillEvent()
    }

    private func authenticateAndHandleCredential(provideCredential: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.authenticator.authenticate { error in
                if error != nil {
                    if error != .noAuthAvailable {
                        self?.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain,
                                                                                code: ASExtensionError.userInteractionRequired.rawValue))
                    } else {
                        let alert = UIAlertController.makeDeviceAuthenticationAlert { [weak self] in
                            self?.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain,
                                                                                    code: ASExtensionError.userInteractionRequired.rawValue))
                        }
                        self?.present(alert, animated: true)
                    }
                } else {
                    provideCredential()
                }
            }
        }
    }

    private func findKeychainItemsWithV4() -> Bool {
        var itemsWithV4: [String] = []

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecReturnAttributes as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitAll
        ]

        var result: AnyObject?

        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess, let items = result as? [[String: Any]] {
            for item in items {
                if let service = item[kSecAttrService as String] as? String,
                   service.contains("v4") {
                    itemsWithV4.append(service)
                }
            }
        } else {
            Logger.autofill.debug("No items found or error: \(status)")
        }

        return !itemsWithV4.isEmpty
    }

    private func reportFillEvent() {
        guard let autofillPixelReporter = autofillPixelReporter else { return }

        NotificationCenter.default.post(name: .autofillFillEvent, object: nil)
    }
}
