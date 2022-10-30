//
//  SaveLoginViewController.swift
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

import UIKit
import SwiftUI
import BrowserServicesKit
import Core

protocol SaveLoginViewControllerDelegate: AnyObject {
    func saveLoginViewController(_ viewController: SaveLoginViewController, didSaveCredentials credentials: SecureVaultModels.WebsiteCredentials)
    func saveLoginViewController(_ viewController: SaveLoginViewController, didUpdateCredentials credentials: SecureVaultModels.WebsiteCredentials)
    func saveLoginViewControllerDidCancel(_ viewController: SaveLoginViewController)
}

class SaveLoginViewController: UIViewController {
    weak var delegate: SaveLoginViewControllerDelegate?
    private let credentialManager: SaveAutofillLoginManager
    private let domainLastShownOn: String?

    internal init(credentialManager: SaveAutofillLoginManager, domainLastShownOn: String? = nil) {
        self.credentialManager = credentialManager
        self.domainLastShownOn = domainLastShownOn
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(named: "AutofillPromptLargeBackground")
        
        setupSaveLoginView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    private func setupSaveLoginView() {
        let saveViewModel = SaveLoginViewModel(credentialManager: credentialManager, domainLastShownOn: domainLastShownOn)
        saveViewModel.delegate = self

        let saveLoginView = SaveLoginView(viewModel: saveViewModel)
        let controller = UIHostingController(rootView: saveLoginView)
        controller.view.backgroundColor = .clear
        installChildViewController(controller)
        
        switch saveViewModel.layoutType {
        case .newUser:
            Pixel.fire(pixel: .autofillLoginsSaveLoginModalOnboardingDisplayed)
        case .saveLogin:
            Pixel.fire(pixel: .autofillLoginsSaveLoginModalDisplayed)
        case .savePassword:
            Pixel.fire(pixel: .autofillLoginsSavePasswordModalDisplayed)
        case .saveAdditionalLogin:
            Pixel.fire(pixel: .autofillLoginsSaveLoginModalDisplayed)
        case .updateUsername:
            Pixel.fire(pixel: .autofillLoginsUpdateUsernameModelDisplayed)
        case .updatePassword:
            Pixel.fire(pixel: .autofillLoginsUpdatePasswordModalDisplayed)
        }
    }
}

extension SaveLoginViewController: SaveLoginViewModelDelegate {
    func saveLoginViewModelDidSave(_ viewModel: SaveLoginViewModel) {
        switch viewModel.layoutType {
        case .saveAdditionalLogin, .saveLogin, .savePassword, .newUser:
            if viewModel.layoutType == .savePassword {
                Pixel.fire(pixel: .autofillLoginsSavePasswordModalConfirmed)
            } else {
                Pixel.fire(pixel: .autofillLoginsSaveLoginModalConfirmed)
            }
            delegate?.saveLoginViewController(self, didSaveCredentials: credentialManager.credentials)
        case .updatePassword, .updateUsername:
            if viewModel.layoutType == .updatePassword {
                Pixel.fire(pixel: .autofillLoginsUpdatePasswordModalConfirmed)
            } else {
                Pixel.fire(pixel: .autofillLoginsUpdateUsernameModelConfirmed)
            }
            delegate?.saveLoginViewController(self, didUpdateCredentials: credentialManager.credentials)
        }
    }
    
    func saveLoginViewModelDidCancel(_ viewModel: SaveLoginViewModel) {
        delegate?.saveLoginViewControllerDidCancel(self)
    }

    func saveLoginViewModelConfirmKeepUsing(_ viewModel: SaveLoginViewModel) {
        let alertController = UIAlertController(title: UserText.autofillKeepEnabledAlertTitle,
                                                message: UserText.autofillKeepEnabledAlertMessage,
                                                preferredStyle: .alert)
        alertController.overrideUserInterfaceStyle()

        let disableAction = UIAlertAction(title: UserText.autofillKeepEnabledAlertDisableAction, style: .cancel) { _ in
            Pixel.fire(pixel: .autofillLoginsFillLoginInlineDisablePromptAutofillDisabled)
            self.delegate?.saveLoginViewControllerDidCancel(self)
            AppDependencyProvider.shared.appSettings.autofillCredentialsEnabled = false
        }

        let keepUsingAction = UIAlertAction(title: UserText.autofillKeepEnabledAlertKeepUsingAction, style: .default) { _ in
            Pixel.fire(pixel: .autofillLoginsFillLoginInlineDisablePromptAutofillKept)
            self.delegate?.saveLoginViewControllerDidCancel(self)
        }

        alertController.addAction(disableAction)
        alertController.addAction(keepUsingAction)

        alertController.preferredAction = keepUsingAction

        Pixel.fire(pixel: .autofillLoginsFillLoginInlineDisablePromptShown)
        present(alertController, animated: true)
    }
}
