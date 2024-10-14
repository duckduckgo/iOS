//
//  PasswordGenerationPromptViewController.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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

class PasswordGenerationPromptViewController: UIViewController {

    typealias PasswordGenerationPromptViewControllerCompletion = (_ useGeneratedPassword: Bool) -> Void
    let completion: PasswordGenerationPromptViewControllerCompletion?

    private var viewModel: PasswordGenerationPromptViewModel?
    private let generatedPassword: String

    internal init(generatedPassword: String,
                  completion: PasswordGenerationPromptViewControllerCompletion? = nil) {
        self.generatedPassword = generatedPassword
        self.completion = completion

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(named: "AutofillPromptLargeBackground")

        setupPasswordGenerationPromptView()

        Pixel.fire(pixel: .autofillLoginsPasswordGenerationPromptDisplayed)
    }

    private func setupPasswordGenerationPromptView() {
        let passwordGenerationPromptViewModel = PasswordGenerationPromptViewModel(generatedPassword: generatedPassword)
        passwordGenerationPromptViewModel.delegate = self
        self.viewModel = passwordGenerationPromptViewModel

        let passwordPromptView = PasswordGenerationPromptView(viewModel: passwordGenerationPromptViewModel)
        let controller = UIHostingController(rootView: passwordPromptView)
        controller.view.backgroundColor = .clear
        presentationController?.delegate = self
        installChildViewController(controller)
    }

    /// This is to handle cases where a webpage may have also presented a context menu, which ends up getting dismissed instead of this sheet
    private func dismissSheetWithRetry(attempts: Int = 2, useGeneratedPassword: Bool) {
        dismiss(animated: true) { [weak self] in
            if self?.presentingViewController != nil && attempts > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self?.dismissSheetWithRetry(attempts: attempts - 1, useGeneratedPassword: useGeneratedPassword)
                }
            } else {
                self?.completion?(useGeneratedPassword)
            }
        }
    }
}

extension PasswordGenerationPromptViewController: UISheetPresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        Pixel.fire(pixel: .autofillLoginsPasswordGenerationPromptDismissed)

        self.completion?(false)
    }
}

extension PasswordGenerationPromptViewController: PasswordGenerationPromptViewModelDelegate {
    func passwordGenerationPromptViewModelDidSelect(_ viewModel: PasswordGenerationPromptViewModel) {
        Pixel.fire(pixel: .autofillLoginsPasswordGenerationPromptConfirmed)

        dismissSheetWithRetry(useGeneratedPassword: true)
    }

    func passwordGenerationPromptViewModelDidCancel(_ viewModel: PasswordGenerationPromptViewModel) {
        Pixel.fire(pixel: .autofillLoginsPasswordGenerationPromptDismissed)

        dismissSheetWithRetry(useGeneratedPassword: false)
    }

    func passwordGenerationPromptViewModelDidResizeContent(_ viewModel: PasswordGenerationPromptViewModel, contentHeight: CGFloat) {
        if #available(iOS 16.0, *) {
            if let sheetPresentationController = self.presentationController as? UISheetPresentationController {
                sheetPresentationController.animateChanges {
                    sheetPresentationController.detents = [.custom(resolver: { _ in contentHeight })]
                }
            }
        }
    }
}
