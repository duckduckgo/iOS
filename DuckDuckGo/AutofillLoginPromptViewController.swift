//
//  AutofillLoginPromptViewController.swift
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
import LocalAuthentication
import BrowserServicesKit
import Core

protocol AutofillLoginPromptViewControllerExpansionResponseDelegate: AnyObject {
    func autofillLoginPromptViewController(_ viewController: AutofillLoginPromptViewController, isExpanded: Bool)
}

class AutofillLoginPromptViewController: UIViewController {
    
    static var canAuthenticate: Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
    }
    
    weak var expansionResponseDelegate: AutofillLoginPromptViewControllerExpansionResponseDelegate?
    
    typealias AutofillLoginPromptViewControllerCompletion = ((SecureVaultModels.WebsiteAccount?) -> Void)
    let completion: AutofillLoginPromptViewControllerCompletion?
    
    private let accounts: [SecureVaultModels.WebsiteAccount]
    private let trigger: AutofillUserScript.GetTriggerType
    
    private lazy var blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        return blurEffectView
    }()
    
    private lazy var expandedBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "AutofillPromptLargeBackground")
        return view
    }()

    
    internal init(accounts: [SecureVaultModels.WebsiteAccount],
                  trigger: AutofillUserScript.GetTriggerType,
                  completion: AutofillLoginPromptViewControllerCompletion? = nil) {
        self.accounts = accounts
        self.trigger = trigger
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = UIColor.clear
        view.addSubview(blurView)
        view.addSubview(expandedBackgroundView)
        expandedBackgroundView.alpha = isExpanded ? 1 : 0
        
        let viewModel = AutofillLoginPromptViewModel(accounts: accounts, isExpanded: isExpanded)
        guard let viewModel = viewModel else {
            return
        }
        
        viewModel.delegate = self
        expansionResponseDelegate = viewModel
        
        let view = AutofillLoginPromptView(viewModel: viewModel)
        let controller = UIHostingController(rootView: view)
        controller.view.backgroundColor = .clear
        presentationController?.delegate = self
        installChildViewController(controller)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Pixel.fire(pixel: .autofillLoginsFillLoginInlineDisplayed)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        blurView.frame = self.view.frame
        expandedBackgroundView.frame = self.view.frame
    }
    
    private var isExpanded: Bool {
        if #available(iOS 15.0, *),
           let presentationController = presentationController as? UISheetPresentationController {
            if presentationController.selectedDetentIdentifier == nil &&
                presentationController.detents.contains(.medium()) {
                return false
            } else if presentationController.selectedDetentIdentifier == .medium {
                return false
            }
        }
        return true
    }
}

extension AutofillLoginPromptViewController: UISheetPresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        completion?(nil)
    }
    
    @available(iOS 15.0, *)
    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        UIView.animate(withDuration: 0.2) {
            self.expandedBackgroundView.alpha = self.isExpanded ? 1 : 0
        }
        expansionResponseDelegate?.autofillLoginPromptViewController(self, isExpanded: isExpanded)
    }
}

extension AutofillLoginPromptViewController: AutofillLoginPromptViewModelDelegate {
    func autofillLoginPromptViewModel(_ viewModel: AutofillLoginPromptViewModel, didSelectAccount account: SecureVaultModels.WebsiteAccount) {
        
        Pixel.fire(pixel: .autofillLoginsFillLoginInlineConfirmed)
        
        let context = LAContext()
        context.localizedCancelTitle = UserText.autofillLoginPromptAuthenticationCancelButton
        let reason = UserText.autofillLoginPromptAuthenticationReason
        context.localizedReason = reason
        
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let completion = self.completion
            dismiss(animated: true, completion: nil)
            let reason = reason
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { success, error in
            
                DispatchQueue.main.async {
                    if success {
                        Pixel.fire(pixel: .autofillLoginsFillLoginInlineAuthenticationDeviceAuthAuthenticated)
                        completion?(account)
                    } else {
                        Pixel.fire(pixel: .autofillLoginsFillLoginInlineAuthenticationDeviceAuthFailed)
                        print(error?.localizedDescription ?? "Failed to authenticate but error nil")
                        completion?(nil)
                    }
                }
            }
        } else {
            // When system authentication isn't available, for now just fail silently
            Pixel.fire(pixel: .autofillLoginsFillLoginInlineAuthenticationDeviceAuthUnavailable)
            dismiss(animated: true) {
                self.completion?(nil)
            }
        }
    }
    
    func autofillLoginPromptViewModelDidCancel(_ viewModel: AutofillLoginPromptViewModel) {
        dismiss(animated: true) {
            if self.trigger == AutofillUserScript.GetTriggerType.autoprompt {
                Pixel.fire(pixel: .autofillLoginsAutopromptDismissed)
            }
            
            self.completion?(nil)
        }
    }
    
    func autofillLoginPromptViewModelDidRequestExpansion(_ viewModel: AutofillLoginPromptViewModel) {
        if #available(iOS 15.0, *) {
            if let presentationController = presentationController as? UISheetPresentationController {
                presentationController.animateChanges {
                    presentationController.selectedDetentIdentifier = .large
                    expandedBackgroundView.alpha = 1
                }
                expansionResponseDelegate?.autofillLoginPromptViewController(self, isExpanded: true)
            }
        }
    }
}
