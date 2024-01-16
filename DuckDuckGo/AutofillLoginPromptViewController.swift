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

class AutofillLoginPromptViewController: UIViewController {

    typealias AutofillLoginPromptViewControllerCompletion = (_ account: SecureVaultModels.WebsiteAccount?,
                                                             _ showExpanded: Bool) -> Void
    let completion: AutofillLoginPromptViewControllerCompletion?

    private let accounts: AccountMatches
    private let domain: String
    private let trigger: AutofillUserScript.GetTriggerType
    
    internal init(accounts: AccountMatches,
                  domain: String,
                  trigger: AutofillUserScript.GetTriggerType,
                  completion: AutofillLoginPromptViewControllerCompletion? = nil) {
        self.accounts = accounts
        self.domain = domain
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
        
        let viewModel = AutofillLoginPromptViewModel(accounts: accounts, domain: domain, isExpanded: isExpanded)
        viewModel.delegate = self

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
        if #available(iOS 16.0, *) {
            return true
        }
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
        completion?(nil, false)
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
            completion?(account, false)
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
                        completion?(account, false)
                    } else {
                        if let error = error as? NSError, error.code == LAError.userCancel.rawValue {
                            Pixel.fire(pixel: .autofillLoginsFillLoginInlineAuthenticationDeviceAuthCancelled)
                        } else {
                            Pixel.fire(pixel: .autofillLoginsFillLoginInlineAuthenticationDeviceAuthFailed)
                        }
                        print(error?.localizedDescription ?? "Failed to authenticate but error nil")
                        AppDependencyProvider.shared.autofillLoginSession.endSession()
                        completion?(nil, false)
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
                self.completion?(nil, false)
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
            
            self.completion?(nil, false)
        }
    }
    
    func autofillLoginPromptViewModelDidRequestExpansion(_ viewModel: AutofillLoginPromptViewModel) {
        if #available(iOS 15.0, *) {
            dismiss(animated: true) {
                self.completion?(nil, true)
            }
        }
    }

    func autofillLoginPromptViewModelDidResizeContent(_ viewModel: AutofillLoginPromptViewModel, contentHeight: CGFloat) {
        if #available(iOS 16.0, *) {
            if let sheetPresentationController = self.presentationController as? UISheetPresentationController {
                sheetPresentationController.animateChanges {
                    sheetPresentationController.detents = [.custom(resolver: { _ in contentHeight })]
                }
            }
        }
    }
}
