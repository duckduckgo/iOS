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
    
    weak var expansionResponseDelegate: AutofillLoginPromptViewControllerExpansionResponseDelegate?
    
    typealias AutofillLoginPromptViewControllerCompletion = ((SecureVaultModels.WebsiteAccount?) -> Void)
    let completion: AutofillLoginPromptViewControllerCompletion?
    
    private let accounts: [SecureVaultModels.WebsiteAccount]
    private let trigger: AutofillUserScript.GetTriggerType
    
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
        view.backgroundColor = UIColor(named: "AutofillPromptLargeBackground")
        
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
        if trigger == AutofillUserScript.GetTriggerType.autoprompt {
            Pixel.fire(pixel: .autofillLoginsFillLoginInlineAutopromptDisplayed)
        } else {
            Pixel.fire(pixel: .autofillLoginsFillLoginInlineManualDisplayed)
        }
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
        if self.trigger == AutofillUserScript.GetTriggerType.autoprompt {
            Pixel.fire(pixel: .autofillLoginsAutopromptDismissed)
        } else {
            Pixel.fire(pixel: .autofillLoginsFillLoginInlineManualDismissed)
        }
        completion?(nil)
    }
    
    @available(iOS 15.0, *)
    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        expansionResponseDelegate?.autofillLoginPromptViewController(self, isExpanded: isExpanded)
    }
}

extension AutofillLoginPromptViewController: AutofillLoginPromptViewModelDelegate {
    func autofillLoginPromptViewModel(_ viewModel: AutofillLoginPromptViewModel, didSelectAccount account: SecureVaultModels.WebsiteAccount) {
        
        if trigger == AutofillUserScript.GetTriggerType.autoprompt {
            Pixel.fire(pixel: .autofillLoginsFillLoginInlineAutopromptConfirmed)
        } else {
            Pixel.fire(pixel: .autofillLoginsFillLoginInlineManualConfirmed)
        }

        if AppDependencyProvider.shared.autofillLoginSession.isValidSession {
            dismiss(animated: true, completion: nil)
            completion?(account)
            return
        }

        let context = LAContext()
        context.localizedCancelTitle = UserText.autofillLoginPromptAuthenticationCancelButton
        let reason = UserText.autofillLoginPromptAuthenticationReason
        context.localizedReason = reason
        
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let completion = self.completion
            dismiss(animated: true, completion: nil)
            let reason = reason
            Pixel.fire(pixel: .autofillLoginsFillLoginInlineAuthenticationDeviceDisplayed)
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { success, error in
            
                DispatchQueue.main.async {
                    if success {
                        Pixel.fire(pixel: .autofillLoginsFillLoginInlineAuthenticationDeviceAuthAuthenticated)
                        AppDependencyProvider.shared.autofillLoginSession.startSession()
                        completion?(account)
                    } else {
                        if let error = error as? NSError, error.code == LAError.userCancel.rawValue {
                            Pixel.fire(pixel: .autofillLoginsFillLoginInlineAuthenticationDeviceAuthCancelled)
                        } else {
                            Pixel.fire(pixel: .autofillLoginsFillLoginInlineAuthenticationDeviceAuthFailed)
                        }
                        print(error?.localizedDescription ?? "Failed to authenticate but error nil")
                        AppDependencyProvider.shared.autofillLoginSession.endSession()
                        completion?(nil)
                    }
                }
            }
        } else {
            // When system authentication isn't available, for now just fail silently
            // This should never happen since we check for auth avaiablity before showing anything
            // (or rarely if the user backgrounds the app, turns auth off, then comes back) 
            Pixel.fire(pixel: .autofillLoginsFillLoginInlineAuthenticationDeviceAuthUnavailable)
            AppDependencyProvider.shared.autofillLoginSession.endSession()
            dismiss(animated: true) {
                self.completion?(nil)
            }
        }
    }
    
    func autofillLoginPromptViewModelDidCancel(_ viewModel: AutofillLoginPromptViewModel) {
        dismiss(animated: true) {
            if self.trigger == AutofillUserScript.GetTriggerType.autoprompt {
                Pixel.fire(pixel: .autofillLoginsAutopromptDismissed)
            } else {
                Pixel.fire(pixel: .autofillLoginsFillLoginInlineManualDismissed)
            }
            
            self.completion?(nil)
        }
    }
    
    func autofillLoginPromptViewModelDidRequestExpansion(_ viewModel: AutofillLoginPromptViewModel) {
        if #available(iOS 15.0, *) {
            if let presentationController = presentationController as? UISheetPresentationController {
                presentationController.animateChanges {
                    presentationController.selectedDetentIdentifier = .large
                }
                expansionResponseDelegate?.autofillLoginPromptViewController(self, isExpanded: true)
            }
        }
    }
}
