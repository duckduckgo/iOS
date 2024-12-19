//
//  CredentialProviderListDetailsViewController.swift
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
import BrowserServicesKit
import Common
import Combine
import Core

protocol CredentialProviderListDetailsViewControllerDelegate: AnyObject {
    func credentialProviderListDetailsViewControllerDidProvideText(_ controller: CredentialProviderListDetailsViewController, text: String)
}

class CredentialProviderListDetailsViewController: UIViewController {

    private enum Constants {
        static let padding: CGFloat = 16
    }

    weak var delegate: CredentialProviderListDetailsViewControllerDelegate?
    private let viewModel: CredentialProviderListDetailsViewModel
    private var cancellables: Set<AnyCancellable> = []
    private var contentView: UIView?

    init(account: SecureVaultModels.WebsiteAccount? = nil, tld: TLD, shouldProvideTextToInsert: Bool = false) {
        self.viewModel = CredentialProviderListDetailsViewModel(account: account,
                                                                tld: tld,
                                                                shouldProvideTextToInsert: shouldProvideTextToInsert)
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var account: SecureVaultModels.WebsiteAccount? {
        get {
            viewModel.account
        }
        set {
            if let newValue {
                viewModel.updateData(with: newValue)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        installSubviews()
        setupCancellables()
        setupNavigationBar()
    }

    private func installSubviews() {
        installContentView()
    }

    private func setupCancellables() {
        Publishers.MergeMany(
            viewModel.$title,
            viewModel.$username,
            viewModel.$password,
            viewModel.$address,
            viewModel.$notes)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.setupNavigationBar()
            }
            .store(in: &cancellables)

    }

    private func installContentView() {
        let contentView = CredentialProviderListDetailsView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: contentView)
        addChild(hostingController)
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostingController.view.frame = view.bounds
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        self.contentView = hostingController.view
    }

    private func setupNavigationBar() {
        title = viewModel.navigationTitle
    }

    func showActionMessage(_ message: String) {
        ActionMessageView.present(
            message: message,
            actionTitle: "",
            onAction: {},
            inView: self.view
        )
    }
}

extension CredentialProviderListDetailsViewController: CredentialProviderListDetailsViewModelDelegate {
    func credentialProviderListDetailsViewModelDidProvideText(text: String) {
        delegate?.credentialProviderListDetailsViewControllerDidProvideText(self, text: text)
    }

    func credentialProviderListDetailsViewModelShowActionMessage(message: String) {
        showActionMessage(message)
    }
}
