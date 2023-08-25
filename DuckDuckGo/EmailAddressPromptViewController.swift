//
//  EmailAddressPromptViewController.swift
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

import BrowserServicesKit
import Core
import SwiftUI
import UIKit

class EmailAddressPromptViewController: UIViewController {

    typealias EmailAddressPromptViewControllerCompletion = (_ addressType: EmailManagerPermittedAddressType, _ autosave: Bool) -> Void
    let completion: EmailAddressPromptViewControllerCompletion

    private var viewModel: EmailAddressPromptViewModel?
    private let emailManager: EmailManager

    private var pixelParameters: [String: String] = [:]

    internal init(_ emailManager: EmailManager, completion: @escaping EmailAddressPromptViewControllerCompletion) {
        self.emailManager = emailManager
        self.completion = completion

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(designSystemColor: .surface)

        setupEmailAddressPromptView()

        if let cohort = emailManager.cohort {
            pixelParameters[PixelParameters.emailCohort] = cohort
        }
    }

    private func setupEmailAddressPromptView() {
        let emailAddressPromptViewModel = EmailAddressPromptViewModel(userEmail: emailManager.userEmail)
        emailAddressPromptViewModel.delegate = self
        self.viewModel = emailAddressPromptViewModel

        let emailAddressPromptView = EmailAddressPromptView(viewModel: emailAddressPromptViewModel)
        let controller = UIHostingController(rootView: emailAddressPromptView)
        controller.view.backgroundColor = .clear
        presentationController?.delegate = self
        installChildViewController(controller)
    }

}

extension EmailAddressPromptViewController: UISheetPresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        Pixel.fire(pixel: .emailTooltipDismissed, withAdditionalParameters: pixelParameters, includedParameters: [])

        completion(.none, false)
    }
}

extension EmailAddressPromptViewController: EmailAddressPromptViewModelDelegate {

    func emailAddressPromptViewModelDidSelectUserEmail(_ viewModel: EmailAddressPromptViewModel) {
        pixelParameters[PixelParameters.emailLastUsed] = emailManager.lastUseDate
        emailManager.updateLastUseDate()

        Pixel.fire(pixel: .emailUserPressedUseAddress, withAdditionalParameters: pixelParameters, includedParameters: [])

        completion(.user, false)

        dismiss(animated: true)
    }

    func emailAddressPromptViewModelDidSelectGeneratedEmail(_ viewModel: EmailAddressPromptViewModel) {
        pixelParameters[PixelParameters.emailLastUsed] = emailManager.lastUseDate
        emailManager.updateLastUseDate()

        Pixel.fire(pixel: .emailUserPressedUseAlias, withAdditionalParameters: pixelParameters, includedParameters: [])

        completion(.generated, true)

        dismiss(animated: true)
    }

    func emailAddressPromptViewModelDidClose(_ viewModel: EmailAddressPromptViewModel) {
        Pixel.fire(pixel: .emailTooltipDismissed, withAdditionalParameters: pixelParameters, includedParameters: [])

        completion(.none, false)

        dismiss(animated: true)
    }

    func emailAddressPromptViewModelDidResizeContent(_ viewModel: EmailAddressPromptViewModel, contentHeight: CGFloat) {
        if #available(iOS 16.0, *) {
            if let sheetPresentationController = self.presentationController as? UISheetPresentationController {
                sheetPresentationController.animateChanges {
                    sheetPresentationController.detents = [.custom(resolver: { _ in contentHeight })]
                }
            }
        }
    }

}
