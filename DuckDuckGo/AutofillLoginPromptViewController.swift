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
import BrowserServicesKit

protocol AutofillLoginPromptViewControllerDelegate: AnyObject {
    func autofillLoginPromptViewController(_ viewController: AutofillLoginPromptViewController, didSelectAccount account: SecureVaultModels.WebsiteAccount)
    func autoFillLoginPromptViewControllerDidCancel(_ viewController: AutofillLoginPromptViewController)
}

class AutofillLoginPromptViewController: UIViewController {
    
    weak var delegate: AutofillLoginPromptViewControllerDelegate?
    
    private let accounts: [SecureVaultModels.WebsiteAccount]
    
    private lazy var blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemThinMaterial)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        return blurEffectView
    }()

    internal init(accounts: [SecureVaultModels.WebsiteAccount]) {
        self.accounts = accounts
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
        
        let viewModel = AutofillLoginPromptViewModel(accounts: accounts)
        guard let viewModel = viewModel else {
            return
        }
        
        viewModel.delegate = self
        
        let view = AutofillLoginPromptView(viewModel: viewModel)
        let controller = UIHostingController(rootView: view)
        controller.view.backgroundColor = .clear
        presentationController?.delegate = self
        installChildViewController(controller)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        blurView.frame = self.view.frame
    }
    
    deinit {
        print("bye")
    }
}

extension AutofillLoginPromptViewController: UISheetPresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        print("dismiss")
        delegate?.autoFillLoginPromptViewControllerDidCancel(self)
        //TODO probs need to call delegate here (and make sure happens in all cases
    }
}

extension AutofillLoginPromptViewController: AutofillLoginPromptViewModelDelegate {
    func autofillLoginPromptViewModel(_ viewModel: AutofillLoginPromptViewModel, didSelectAccount account: SecureVaultModels.WebsiteAccount) {
        delegate?.autofillLoginPromptViewController(self, didSelectAccount: account)
        dismiss(animated: true, completion: nil)
    }
    
    func autofillLoginPromptViewModelDidCancel(_ viewModel: AutofillLoginPromptViewModel) {
        delegate?.autoFillLoginPromptViewControllerDidCancel(self)
        dismiss(animated: true, completion: nil)
    }
}
