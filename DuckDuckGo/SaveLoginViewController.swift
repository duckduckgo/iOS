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
    func saveLoginViewController(_ viewController: SaveLoginViewController, didRequestNeverPromptForWebsite domain: String)
    func saveLoginViewController(_ viewController: SaveLoginViewController,
                                 didRequestPresentConfirmKeepUsingAlertController alertController: UIAlertController)
}

class SaveLoginViewController: UIViewController {
    weak var delegate: SaveLoginViewControllerDelegate?
    private let credentialManager: SaveAutofillLoginManager
    private let appSettings: AppSettings
    private let domainLastShownOn: String?
    var viewModel: SaveLoginViewModel?

    internal init(credentialManager: SaveAutofillLoginManager, appSettings: AppSettings, domainLastShownOn: String? = nil) {
        self.credentialManager = credentialManager
        self.appSettings = appSettings
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
        viewModel?.viewControllerDidAppear()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        guard let viewModel = viewModel else { return }
        
        if viewModel.didSave {
            return
        }
        switch viewModel.layoutType {
        case .newUser, .saveLogin:
            Pixel.fire(pixel: .autofillLoginsSaveLoginModalDismissed)
        case .savePassword:
            Pixel.fire(pixel: .autofillLoginsSavePasswordModalDismissed)
        case .updateUsername:
            Pixel.fire(pixel: .autofillLoginsUpdateUsernameModalDismissed)
        case .updatePassword:
            Pixel.fire(pixel: .autofillLoginsUpdatePasswordModalDismissed)
        }
        
        viewModel.viewControllerDidDisappear()
    }

    private func setupSaveLoginView() {
        let saveViewModel = SaveLoginViewModel(credentialManager: credentialManager, appSettings: appSettings, domainLastShownOn: domainLastShownOn)
        saveViewModel.delegate = self
        self.viewModel = saveViewModel

        let saveLoginView = SaveLoginView(viewModel: saveViewModel)
        let controller = UIHostingController(rootView: saveLoginView)
        controller.view.backgroundColor = .clear
        installChildViewController(controller)
        
        switch saveViewModel.layoutType {
        case .newUser, .saveLogin:
            Pixel.fire(pixel: .autofillLoginsSaveLoginModalDisplayed)
        case .savePassword:
            Pixel.fire(pixel: .autofillLoginsSavePasswordModalDisplayed)
        case .updateUsername:
            Pixel.fire(pixel: .autofillLoginsUpdateUsernameModalDisplayed)
        case .updatePassword:
            Pixel.fire(pixel: .autofillLoginsUpdatePasswordModalDisplayed)
        }
    }
}

extension SaveLoginViewController: SaveLoginViewModelDelegate {
    func saveLoginViewModelDidSave(_ viewModel: SaveLoginViewModel) {
        switch viewModel.layoutType {
        case .saveLogin, .savePassword, .newUser:
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
                Pixel.fire(pixel: .autofillLoginsUpdateUsernameModalConfirmed)
            }
            delegate?.saveLoginViewController(self, didUpdateCredentials: credentialManager.credentials)
        }
    }
    
    func saveLoginViewModelDidCancel(_ viewModel: SaveLoginViewModel) {
        delegate?.saveLoginViewControllerDidCancel(self)
    }

    func saveLoginViewModelNeverPrompt(_ viewModel: SaveLoginViewModel) {
        Pixel.fire(pixel: .autofillLoginsSaveLoginModalExcludeSiteConfirmed)
        delegate?.saveLoginViewController(self, didRequestNeverPromptForWebsite: viewModel.accountDomain)
    }

    func saveLoginViewModelConfirmKeepUsing(_ viewModel: SaveLoginViewModel, isAlreadyDismissed: Bool) {
        
        let isSelfPresentingAlert = !isAlreadyDismissed
        
        let alertController = UIAlertController(title: UserText.autofillKeepEnabledAlertTitle,
                                                message: UserText.autofillKeepEnabledAlertMessage,
                                                preferredStyle: .alert)
        alertController.overrideUserInterfaceStyle()

        let disableAction = UIAlertAction(title: UserText.autofillKeepEnabledAlertDisableAction, style: .cancel) { _ in
            Pixel.fire(pixel: .autofillLoginsFillLoginInlineDisablePromptAutofillDisabled)
            if isSelfPresentingAlert {
                self.delegate?.saveLoginViewControllerDidCancel(self)
            }
            AppDependencyProvider.shared.appSettings.autofillCredentialsEnabled = false
        }

        let keepUsingAction = UIAlertAction(title: UserText.autofillKeepEnabledAlertKeepUsingAction, style: .default) { _ in
            Pixel.fire(pixel: .autofillLoginsFillLoginInlineDisablePromptAutofillKept)
            if isSelfPresentingAlert {
                self.delegate?.saveLoginViewControllerDidCancel(self)
            }
        }

        alertController.addAction(disableAction)
        alertController.addAction(keepUsingAction)

        alertController.preferredAction = keepUsingAction

        if isAlreadyDismissed {
            delegate?.saveLoginViewController(self, didRequestPresentConfirmKeepUsingAlertController: alertController)
        } else {
            Pixel.fire(pixel: .autofillLoginsFillLoginInlineDisablePromptShown)
            present(alertController, animated: true)
        }
    }

    func saveLoginViewModelDidResizeContent(_ viewModel: SaveLoginViewModel, contentHeight: CGFloat) {
        if #available(iOS 16.0, *) {
            if let sheetPresentationController = self.presentationController as? UISheetPresentationController {
                sheetPresentationController.animateChanges {
                    sheetPresentationController.detents = [.custom(resolver: { _ in contentHeight })]
                }
            }
        }
    }
}
