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

    private lazy var blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        return blurEffectView
    }()

    internal init(credentialManager: SaveAutofillLoginManager) {
        self.credentialManager = credentialManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clear
        
        setupBlurBackgroundView()
        setupSaveLoginView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        blurView.frame = self.view.frame
    }
    
    private func setupBlurBackgroundView() {
        view.addSubview(blurView)
    }

    private func setupSaveLoginView() {
        let saveViewModel = SaveLoginViewModel(credentialManager: credentialManager)
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
}
