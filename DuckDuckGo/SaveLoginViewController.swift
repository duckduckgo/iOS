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
    func saveLoginViewControllerConfirmKeepUsing(_ viewController: SaveLoginViewController)
}

class SaveLoginViewController: UIViewController {
    weak var delegate: SaveLoginViewControllerDelegate?
    private let credentialManager: SaveAutofillLoginManager
    private let appSettings: AppSettings
    private let domainLastShownOn: String?
    private let backfilled: Bool
    var viewModel: SaveLoginViewModel?

    internal init(credentialManager: SaveAutofillLoginManager, appSettings: AppSettings, domainLastShownOn: String? = nil, backfilled: Bool) {
        self.credentialManager = credentialManager
        self.appSettings = appSettings
        self.domainLastShownOn = domainLastShownOn
        self.backfilled = backfilled
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
        let backfilledParameter = [PixelParameters.backfilled: String(describing: backfilled)]

        switch viewModel.layoutType {
        case .newUser:
            Pixel.fire(pixel: .autofillLoginsSaveLoginOnboardingModalDismissed, withAdditionalParameters: backfilledParameter)
        case .saveLogin:
            Pixel.fire(pixel: .autofillLoginsSaveLoginModalDismissed, withAdditionalParameters: backfilledParameter)
        case .savePassword:
            Pixel.fire(pixel: .autofillLoginsSavePasswordModalDismissed, withAdditionalParameters: backfilledParameter)
        case .updateUsername:
            Pixel.fire(pixel: .autofillLoginsUpdateUsernameModalDismissed, withAdditionalParameters: backfilledParameter)
        case .updatePassword:
            let isBackfilled = viewModel.isUpdatingEmptyPassword
            Pixel.fire(pixel: .autofillLoginsUpdatePasswordModalDismissed, withAdditionalParameters: backfilledParameter)
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
        let backfilledParameter = [PixelParameters.backfilled: String(describing: backfilled)]

        switch saveViewModel.layoutType {
        case .newUser:
            Pixel.fire(pixel: .autofillLoginsSaveLoginOnboardingModalDisplayed, withAdditionalParameters: backfilledParameter)
        case .saveLogin:
            Pixel.fire(pixel: .autofillLoginsSaveLoginModalDisplayed, withAdditionalParameters: backfilledParameter)
        case .savePassword:
            Pixel.fire(pixel: .autofillLoginsSavePasswordModalDisplayed, withAdditionalParameters: backfilledParameter)
        case .updateUsername:
            Pixel.fire(pixel: .autofillLoginsUpdateUsernameModalDisplayed, withAdditionalParameters: backfilledParameter)
        case .updatePassword:
            Pixel.fire(pixel: .autofillLoginsUpdatePasswordModalDisplayed, withAdditionalParameters: backfilledParameter)
        }
    }
}

extension SaveLoginViewController: SaveLoginViewModelDelegate {
    func saveLoginViewModelDidSave(_ viewModel: SaveLoginViewModel) {
        let backfilledParameter = [PixelParameters.backfilled: String(describing: backfilled)]
        switch viewModel.layoutType {
        case .saveLogin, .savePassword, .newUser:
            if case .newUser = viewModel.layoutType {
                Pixel.fire(pixel: .autofillLoginsSaveLoginOnboardingModalConfirmed, withAdditionalParameters: backfilledParameter)
            } else if case .savePassword = viewModel.layoutType {
                Pixel.fire(pixel: .autofillLoginsSavePasswordModalConfirmed, withAdditionalParameters: backfilledParameter)
            } else {
                Pixel.fire(pixel: .autofillLoginsSaveLoginModalConfirmed, withAdditionalParameters: backfilledParameter)
            }
            delegate?.saveLoginViewController(self, didSaveCredentials: credentialManager.credentials)
        case .updatePassword, .updateUsername:
            if viewModel.layoutType == .updatePassword {
                Pixel.fire(pixel: .autofillLoginsUpdatePasswordModalConfirmed, withAdditionalParameters: backfilledParameter)
            } else {
                Pixel.fire(pixel: .autofillLoginsUpdateUsernameModalConfirmed, withAdditionalParameters: backfilledParameter)
            }
            delegate?.saveLoginViewController(self, didUpdateCredentials: credentialManager.credentials)
        }
    }
    
    func saveLoginViewModelDidCancel(_ viewModel: SaveLoginViewModel) {
        delegate?.saveLoginViewControllerDidCancel(self)
    }

    func saveLoginViewModelNeverPrompt(_ viewModel: SaveLoginViewModel) {
        if case .newUser = viewModel.layoutType {
            Pixel.fire(pixel: .autofillLoginsSaveLoginOnboardingModalExcludeSiteConfirmed)
        } else {
            Pixel.fire(pixel: .autofillLoginsSaveLoginModalExcludeSiteConfirmed)
        }
        delegate?.saveLoginViewController(self, didRequestNeverPromptForWebsite: viewModel.accountDomain)
    }

    func saveLoginViewModelConfirmKeepUsing(_ viewModel: SaveLoginViewModel) {
        delegate?.saveLoginViewControllerConfirmKeepUsing(self)
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
