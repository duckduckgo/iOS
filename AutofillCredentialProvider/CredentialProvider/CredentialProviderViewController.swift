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

class CredentialProviderViewController: ASCredentialProviderViewController {
    
    private struct Constants {
        static let openPasswords = AppDeepLinkSchemes.openPasswords.url
    }
    
    private lazy var secureVault: (any AutofillSecureVault)? = {
        return try? AutofillSecureVaultFactory.makeVault(reporter: SecureVaultReporter())
    }()
    
    private lazy var passwordFetcher: CredentialFetcher = {
        return CredentialFetcher(secureVault: secureVault)
    }()
    
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
    }
    
    override func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier]) {
        loadCredentialsList(for: serviceIdentifiers)
    }
    
    private func loadCredentialsList(for serviceIdentifiers: [ASCredentialServiceIdentifier], returnString: Bool = false) {
        let credentialProviderListViewController = CredentialProviderListViewController(serviceIdentifiers: serviceIdentifiers,
                                                                                        secureVault: secureVault,
                                                                                        onRowSelected: { [weak self] item in
            guard let self = self else {
                self?.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain,
                                                                        code: ASExtensionError.failed.rawValue))
                return
            }
            
            let credential = self.passwordFetcher.fetchCredential(for: item.account)
            self.extensionContext.completeRequest(withSelectedCredential: credential, completionHandler: nil)
            
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
    
}
