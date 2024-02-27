//
//  AuthConfirmationPromptViewController.swift
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

import UIKit
import SwiftUI

final class AuthConfirmationPromptViewController: UIViewController {
    
    typealias AuthConfirmationCompletion = (_ authenticated: Bool) -> Void
    
    private let didBeginAuthenticating: () -> Void
    private let authConfirmationCompletion: AuthConfirmationCompletion
    
    private var viewModel: AuthConfirmationPromptViewModel?
    
    init(didBeginAuthenticating: @escaping () -> Void,
         authConfirmationCompletion: @escaping AuthConfirmationCompletion) {
        self.didBeginAuthenticating = didBeginAuthenticating
        self.authConfirmationCompletion = authConfirmationCompletion
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "AutofillPromptLargeBackground")
        
        setupAuthConfirmationPromptView()
    }
    
    private func setupAuthConfirmationPromptView() {
        let authConfirmationPromptViewModel = AuthConfirmationPromptViewModel()
        authConfirmationPromptViewModel.delegate = self
        viewModel = authConfirmationPromptViewModel
        
        let authConfirmationPromptView = AuthConfirmationPromptView(viewModel: authConfirmationPromptViewModel)
        let controller = UIHostingController(rootView: authConfirmationPromptView)
        controller.view.backgroundColor = .clear
        presentationController?.delegate = self
        installChildViewController(controller)
    }
    
}

// MARK: UISheetPresentationControllerDelegate

extension AuthConfirmationPromptViewController: UISheetPresentationControllerDelegate {
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        authConfirmationCompletion(false)
    }
    
}

// MARK: AuthConfirmationPromptViewModelDelegate

extension AuthConfirmationPromptViewController: AuthConfirmationPromptViewModelDelegate {

    func authConfirmationPromptViewModelDidBeginAuthenticating(_ viewModel: AuthConfirmationPromptViewModel) {
        didBeginAuthenticating()
    }
    
    func authConfirmationPromptViewModelDidAuthenticate(_ viewModel: AuthConfirmationPromptViewModel, success: Bool) {
        dismiss(animated: true) {
            self.authConfirmationCompletion(success)
        }
    }
    
    func authConfirmationPromptViewModelDidCancel(_ viewModel: AuthConfirmationPromptViewModel) {
        dismiss(animated: true) {
            self.authConfirmationCompletion(false)
        }
    }
    
    func authConfirmationPromptViewModelDidResizeContent(_ viewModel: AuthConfirmationPromptViewModel, contentHeight: CGFloat) {
        if #available(iOS 16.0, *) {
            if let sheetPresentationController = self.presentationController as? UISheetPresentationController {
                sheetPresentationController.animateChanges {
                    sheetPresentationController.detents = [.custom(resolver: { _ in contentHeight })]
                }
            }
        }
    }
    
}
