//
//  EmailSignupPromptViewController.swift
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
import Core

class EmailSignupPromptViewController: UIViewController {

    typealias EmailSignupPromptViewControllerCompletion = (_ continueSignup: Bool) -> Void
    let completion: EmailSignupPromptViewControllerCompletion

    private static let inContextEmailSignupPromptDismissedPermanentlyAtKey = "Autofill.InContextEmailSignup.dismissed.permanently.at"

    private var viewModel: EmailSignupPromptViewModel?

    private var inContextEmailSignupPromptDismissedPermanentlyAt: Double? {
        get {
            UserDefaults().object(forKey: Self.inContextEmailSignupPromptDismissedPermanentlyAtKey) as? Double ?? nil
        }

        set {
            UserDefaults().set(newValue, forKey: Self.inContextEmailSignupPromptDismissedPermanentlyAtKey)
        }
    }

    internal init(completion: @escaping EmailSignupPromptViewControllerCompletion) {
        self.completion = completion

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(designSystemColor: .surface)

        setupEmailSignupPromptView()

        Pixel.fire(pixel: .emailIncontextPromptDisplayed)
    }

    private func setupEmailSignupPromptView() {
        let emailSignupPromptViewModel = EmailSignupPromptViewModel()
        emailSignupPromptViewModel.delegate = self
        self.viewModel = emailSignupPromptViewModel

        let emailSignupPromptView = EmailSignupPromptView(viewModel: emailSignupPromptViewModel)
        let controller = UIHostingController(rootView: emailSignupPromptView)
        controller.view.backgroundColor = .clear
        presentationController?.delegate = self
        installChildViewController(controller)
    }

}

extension EmailSignupPromptViewController: UISheetPresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        Pixel.fire(pixel: .emailIncontextPromptDismissed)

        completion(false)
    }
}

extension EmailSignupPromptViewController: EmailSignupPromptViewModelDelegate {

    func emailSignupPromptViewModelDidSelect(_ viewModel: EmailSignupPromptViewModel) {
        Pixel.fire(pixel: .emailIncontextPromptConfirmed)

        dismiss(animated: true)
        completion(true)
    }

    func emailSignupPromptViewModelDidReject(_ viewModel: EmailSignupPromptViewModel) {
        inContextEmailSignupPromptDismissedPermanentlyAt = Date().timeIntervalSince1970
        Pixel.fire(pixel: .emailIncontextPromptDismissedPersistent)

        completion(false)
        dismiss(animated: true)
    }

    func emailSignupPromptViewModelDidClose(_ viewModel: EmailSignupPromptViewModel) {
        Pixel.fire(pixel: .emailIncontextPromptDismissed)

        completion(false)
        dismiss(animated: true)
    }

    func emailSignupPromptViewModelDidResizeContent(_ viewModel: EmailSignupPromptViewModel, contentHeight: CGFloat) {
        if #available(iOS 16.0, *) {
            if let sheetPresentationController = self.presentationController as? UISheetPresentationController {
                sheetPresentationController.animateChanges {
                    sheetPresentationController.detents = [.custom(resolver: { _ in contentHeight })]
                }
            }
        }
    }

}
