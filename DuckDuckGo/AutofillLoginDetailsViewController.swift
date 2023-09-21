//
//  AutofillLoginDetailsViewController.swift
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
import Common
import Combine

protocol AutofillLoginDetailsViewControllerDelegate: AnyObject {
    func autofillLoginDetailsViewControllerDidSave(_ controller: AutofillLoginDetailsViewController, account: SecureVaultModels.WebsiteAccount?)
    func autofillLoginDetailsViewControllerDelete(account: SecureVaultModels.WebsiteAccount, title: String)
}

class AutofillLoginDetailsViewController: UIViewController {

    private enum Constants {
        static let padding: CGFloat = 16
    }

    weak var delegate: AutofillLoginDetailsViewControllerDelegate?
    private let viewModel: AutofillLoginDetailsViewModel
    private var cancellables: Set<AnyCancellable> = []
    private var authenticator = AutofillLoginListAuthenticator()
    private let lockedView = AutofillItemsLockedView()
    private let noAuthAvailableView = AutofillNoAuthAvailableView()
    private var contentView: UIView?
    private var authenticationNotRequired: Bool

    private lazy var saveBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        let attributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)]
        barButtonItem.setTitleTextAttributes(attributes, for: [.normal])
        barButtonItem.setTitleTextAttributes(attributes, for: [.disabled])
        return barButtonItem
    }()

    private lazy var editBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(toggleEditMode))
        let attributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)]
        barButtonItem.setTitleTextAttributes(attributes, for: .normal)
        return barButtonItem
    }()

    private lazy var lockedViewBottomConstraint: NSLayoutConstraint? = {
        guard let view = view else { return nil }
        return NSLayoutConstraint(item: view,
                                  attribute: .bottom,
                                  relatedBy: .equal,
                                  toItem: lockedView,
                                  attribute: .bottom,
                                  multiplier: 1,
                                  constant: 144)
    }()

    init(authenticator: AutofillLoginListAuthenticator, account: SecureVaultModels.WebsiteAccount? = nil, tld: TLD, authenticationNotRequired: Bool = false) {
        self.viewModel = AutofillLoginDetailsViewModel(account: account, tld: tld)
        self.authenticator = authenticator
        self.authenticationNotRequired = authenticationNotRequired
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
            } else if viewModel.viewMode == .view {
                navigationController?.dismiss(animated: true)
            } else {
                viewModel.viewMode = .new
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        installSubviews()
        setupCancellables()
        setupTableViewAppearance()
        applyTheme(ThemeManager.shared.currentTheme)
        installConstraints()
        configureNotifications()
        setupNavigationBar()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !authenticationNotRequired {
            authenticator.authenticate()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            AppDependencyProvider.shared.autofillLoginSession.lastAccessedAccount = nil
        } else if authenticator.canAuthenticate() && authenticator.state == .loggedIn {
            AppDependencyProvider.shared.autofillLoginSession.startSession()
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: nil) { _ in
            self.updateConstraintConstants()
            if self.view.subviews.contains(self.noAuthAvailableView) {
                self.noAuthAvailableView.refreshConstraints()
            }
        }
    }

    private func installSubviews() {
        installContentView()
        view.addSubview(lockedView)
        view.addSubview(noAuthAvailableView)
    }

    private func installConstraints() {
        lockedView.translatesAutoresizingMaskIntoConstraints = false
        noAuthAvailableView.translatesAutoresizingMaskIntoConstraints = false

        updateConstraintConstants()

        NSLayoutConstraint.activate([
            lockedView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lockedView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.padding),
            lockedView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.padding),

            noAuthAvailableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noAuthAvailableView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noAuthAvailableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.padding),
            noAuthAvailableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.padding)
        ])
    }

    private func updateConstraintConstants() {
        guard let lockedViewBottomConstraint = lockedViewBottomConstraint else { return }

        lockedViewBottomConstraint.isActive = true

        let isIPhoneLandscape = traitCollection.containsTraits(in: UITraitCollection(verticalSizeClass: .compact))
        if isIPhoneLandscape {
            lockedViewBottomConstraint.constant = (view.frame.height / 2.0 - max(lockedView.frame.height, 120.0) / 2.0)
        } else {
            lockedViewBottomConstraint.constant = view.frame.height * 0.15
        }
    }

    private func configureNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(appWillMoveToForegroundCallback),
                                       name: UIApplication.willEnterForegroundNotification, object: nil)

        notificationCenter.addObserver(self,
                                       selector: #selector(appWillMoveToBackgroundCallback),
                                       name: UIApplication.willResignActiveNotification, object: nil)
    }

    @objc private func appWillMoveToForegroundCallback() {
        if !authenticationNotRequired {
            authenticator.authenticate()
        }
    }

    @objc private func appWillMoveToBackgroundCallback() {
        if viewModel.viewMode != .new || viewModel.canSave {
            authenticationNotRequired = false
        }
        authenticator.logOut()
    }

    private func setupTableViewAppearance() {
        let appearance = UITableView.appearance(whenContainedInInstancesOf: [AutofillLoginDetailsViewController.self])
        appearance.backgroundColor = UIColor(named: "ListBackground")
    }
    
    private func setupCancellables() {
        viewModel.$viewMode
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.setupNavigationBar()
            }
            .store(in: &cancellables)
        
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
        
        authenticator.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateAuthViews()
            }
            .store(in: &cancellables)
    }

    private func updateAuthViews() {
        switch authenticator.state {
        case .loggedOut:
            lockedView.isHidden = authenticationNotRequired
            noAuthAvailableView.isHidden = true
            self.contentView?.isHidden = !authenticationNotRequired
        case .notAvailable:
            lockedView.isHidden = true
            noAuthAvailableView.isHidden = false
            self.contentView?.isHidden = true
        case .loggedIn:
            lockedView.isHidden = true
            noAuthAvailableView.isHidden = true
            self.contentView?.isHidden = false
        }
        updateNavigationBarButtons()
    }

    private func updateNavigationBarButtons() {
        switch authenticator.state {
        case .loggedOut:
            saveBarButtonItem.isEnabled = authenticationNotRequired && viewModel.canSave
            editBarButtonItem.isEnabled = authenticationNotRequired
        case .notAvailable:
            navigationItem.rightBarButtonItems?.forEach { $0.isEnabled = false }
        case .loggedIn:
            saveBarButtonItem.isEnabled = viewModel.canSave
            editBarButtonItem.isEnabled = true
        }
    }
    
    private func installContentView() {
        let contentView = AutofillLoginDetailsView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: contentView)
        installChildViewController(hostingController)
        self.contentView = hostingController.view
    }
    
    private func setupNavigationBar() {
        title = viewModel.navigationTitle
        switch viewModel.viewMode {
        case .edit, .new:
            saveBarButtonItem.isEnabled = viewModel.canSave
            navigationItem.rightBarButtonItem = saveBarButtonItem
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))

        case .view:
            navigationItem.rightBarButtonItem = editBarButtonItem
            navigationItem.leftBarButtonItem = nil
        }
    }

    @objc private func toggleEditMode() {
        viewModel.toggleEditMode()
    }
    
    @objc private func save() {
        viewModel.save()
    }
    
    @objc private func cancel() {
        if viewModel.viewMode == .new {
            dismiss(animated: true)
        } else {
            toggleEditMode()
        }
    }
}

extension AutofillLoginDetailsViewController: AutofillLoginDetailsViewModelDelegate {
    func autofillLoginDetailsViewModelDidSave() {
        if viewModel.viewMode == .new {
            dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                self.delegate?.autofillLoginDetailsViewControllerDidSave(self, account: self.viewModel.account)
            }
        } else {
            delegate?.autofillLoginDetailsViewControllerDidSave(self, account: nil)
        }
    }
    
    func autofillLoginDetailsViewModelDidAttemptToSaveDuplicateLogin() {
        let alert = UIAlertController(title: UserText.autofillLoginDetailsSaveDuplicateLoginAlertTitle,
                                      message: UserText.autofillLoginDetailsSaveDuplicateLoginAlertMessage,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: UserText.autofillLoginDetailsSaveDuplicateLoginAlertAction, style: .default)
        alert.addAction(action)
        present(alert, animated: true)
    }

    func autofillLoginDetailsViewModelDelete(account: SecureVaultModels.WebsiteAccount, title: String) {
        delegate?.autofillLoginDetailsViewControllerDelete(account: account, title: title)
        navigationController?.popViewController(animated: true)
    }

    func autofillLoginDetailsViewModelDismiss() {
        navigationController?.dismiss(animated: true)
    }
}

// MARK: Themable

extension AutofillLoginDetailsViewController: Themable {

    func decorate(with theme: Theme) {
        lockedView.backgroundColor = theme.backgroundColor

        noAuthAvailableView.decorate(with: theme)

        view.backgroundColor = theme.backgroundColor

        navigationController?.navigationBar.barTintColor = theme.barBackgroundColor
        navigationController?.navigationBar.tintColor = theme.navigationBarTintColor

        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.shadowColor = .clear
            appearance.backgroundColor = theme.backgroundColor

            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
    }
}
