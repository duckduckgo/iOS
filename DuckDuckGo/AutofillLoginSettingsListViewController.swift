//
//  AutofillLoginSettingsListViewController.swift
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
import Combine
import Core
import BrowserServicesKit
import Common
import DDGSync
import DesignResourcesKit
import SwiftUI
import os.log

enum AutofillSettingsSource: String {
    case settings
    case overflow = "overflow_menu"
    case sync
    case appIconShortcut = "app_icon_shortcut"
    case homeScreenWidget = "home_screen_widget"
    case lockScreenWidget = "lock_screen_widget"
    case newTabPageShortcut = "new_tab_page_shortcut"
    case saveLoginDisablePrompt = "save_login_disable_prompt"
    case newTabPageToolbar = "new_tab_page_toolbar"
}

protocol AutofillLoginSettingsListViewControllerDelegate: AnyObject {
    func autofillLoginSettingsListViewControllerDidFinish(_ controller: AutofillLoginSettingsListViewController)
}

final class AutofillLoginSettingsListViewController: UIViewController {

    private enum Constants {
        static let padding: CGFloat = 16
    }

    weak var delegate: AutofillLoginSettingsListViewControllerDelegate?
    weak var detailsViewController: AutofillLoginDetailsViewController?
    private let viewModel: AutofillLoginListViewModel
    private lazy var emptyView: UIView = {
        let emptyView = AutofillItemsEmptyView { [weak self] in
            self?.segueToImport()
            Pixel.fire(pixel: .autofillLoginsImportNoPasswords)
        }

        let hostingController = UIHostingController(rootView: emptyView)
        var size = hostingController.sizeThatFits(in: UIScreen.main.bounds.size)
        size.height += 50
        hostingController.view.frame = CGRect(origin: .zero, size: size)
        hostingController.view.layoutIfNeeded()
        hostingController.view.backgroundColor = .clear

        self.tableView.tableFooterView?.frame.size.height = hostingController.view.frame.height

        return hostingController.view
    }()

    private let lockedView = AutofillItemsLockedView()
    private let enableAutofillFooterView = AutofillSettingsEnableFooterView()
    private let emptySearchView = AutofillEmptySearchView()
    private let noAuthAvailableView = AutofillNoAuthAvailableView()
    private let tld: TLD = AppDependencyProvider.shared.storageCache.tld
    private let syncService: DDGSyncing
    private var syncUpdatesCancellable: AnyCancellable?

    private lazy var addBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(image: UIImage(named: "Add-24"),
                        style: .plain,
                        target: self,
                        action: #selector(addButtonPressed))
    }()

    private lazy var moreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "More-Apple-24"), for: .normal)
        button.showsMenuAsPrimaryAction = true
        button.menu = moreMenu
        return button
    }()

    private lazy var moreBarButtonItem = UIBarButtonItem(customView: moreButton)

    private lazy var moreMenu: UIMenu = {
        return UIMenu(children: [editAction(), importAction()])
    }()

    private lazy var deleteAllButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem(title: UserText.autofillLoginListToolbarDeleteAllButton,
                                     style: .plain,
                                     target: self,
                                     action: #selector(deleteAll))
        button.tintColor = .systemRed
        return button
    }()

    private lazy var accountsCountLabel: UILabel = {
        let label = UILabel()
        label.font = .daxCaption()
        label.textColor = UIColor(designSystemColor: .textSecondary)
        label.text = UserText.autofillLoginListToolbarPasswordsCount(viewModel.accountsCount)
        return label
    }()

    private lazy var accountsCountButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(customView: accountsCountLabel)
        return item
    }()

    private lazy var flexibleSpace: UIBarButtonItem = {
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        return space
    }()

    private var cancellables: Set<AnyCancellable> = []
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = UserText.autofillLoginListSearchPlaceholder
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        return searchController
    }()


    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 60
        tableView.estimatedSectionFooterHeight = 40
        tableView.registerCell(ofType: AutofillListItemTableViewCell.self)
        tableView.registerCell(ofType: EnableAutofillSettingsTableViewCell.self)
        tableView.registerCell(ofType: AutofillNeverSavedTableViewCell.self)
        tableView.registerCell(ofType: AutofillBreakageReportTableViewCell.self)
        return tableView
    }()

    private lazy var headerViewFactory: AutofillHeaderViewFactoryProtocol = AutofillHeaderViewFactory(delegate: self)
    private var currentHeaderHostingController: UIViewController?

    // This is used to prevent the Sync Promo from being displayed immediately after the Survey is dismissed
    private var surveyPromptPresented: Bool = false

    private lazy var lockedViewBottomConstraint: NSLayoutConstraint = {
        NSLayoutConstraint(item: tableView,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: lockedView,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 144)
    }()

    private lazy var emptySearchViewCenterYConstraint: NSLayoutConstraint = {
        NSLayoutConstraint(item: emptySearchView,
                           attribute: .centerY,
                           relatedBy: .equal,
                           toItem: tableView,
                           attribute: .top,
                           multiplier: 1,
                           constant: (tableView.frame.height / 2))
    }()

    var selectedAccount: SecureVaultModels.WebsiteAccount?
    var openSearch: Bool
    let source: AutofillSettingsSource

    init(appSettings: AppSettings,
         currentTabUrl: URL? = nil,
         currentTabUid: String? = nil,
         syncService: DDGSyncing,
         syncDataProviders: SyncDataProviders,
         selectedAccount: SecureVaultModels.WebsiteAccount?,
         openSearch: Bool = false,
         source: AutofillSettingsSource) {
        let secureVault = try? AutofillSecureVaultFactory.makeVault(reporter: SecureVaultReporter())
        if secureVault == nil {
            Logger.autofill.fault("Failed to make vault")
        }
        self.viewModel = AutofillLoginListViewModel(appSettings: appSettings, tld: tld, secureVault: secureVault, currentTabUrl: currentTabUrl, currentTabUid: currentTabUid, syncService: syncService)
        self.syncService = syncService
        self.selectedAccount = selectedAccount
        self.openSearch = openSearch
        self.source = source
        super.init(nibName: nil, bundle: nil)

        authenticate()

        syncUpdatesCancellable = syncDataProviders.credentialsAdapter.syncDidCompletePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.viewModel.updateData()
                self?.tableView.reloadData()
                if let detailsViewController = self?.detailsViewController, let accountId = detailsViewController.account?.id.flatMap(Int64.init) {
                    do {
                        detailsViewController.account = try secureVault?.websiteCredentialsFor(accountId: accountId)?.account
                    } catch {
                        Pixel.fire(pixel: .secureVaultError, error: error)
                    }
                }
            }

        Pixel.fire(pixel: .autofillManagementOpened, withAdditionalParameters: ["source": source.rawValue])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = UserText.autofillLoginListTitle
        extendedLayoutIncludesOpaqueBars = true
        navigationController?.presentationController?.delegate = self
        setupCancellables()
        installSubviews()
        installConstraints()
        decorate()
        updateViewState()
        configureNotification()
        registerForKeyboardNotifications()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            navigationController?.isToolbarHidden = true
        }
        if viewModel.authenticator.canAuthenticate() && viewModel.authenticator.state == .loggedIn {
            AppDependencyProvider.shared.autofillLoginSession.startSession()
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
            self.updateConstraintConstants()
            if self.view.subviews.contains(self.noAuthAvailableView) {
                self.noAuthAvailableView.refreshConstraints()
            }
            if !self.searchController.isActive {
                self.navigationItem.searchController = nil
            }
        }, completion: { _ in
            self.updateSearchController()
        })
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        tableView.setEditing(editing, animated: animated)

        // trigger re-build of table sections
        viewModel.isEditing = editing
        tableView.reloadData()

        updateNavigationBarButtons()
        updateSearchController()
        updateToolbar()
        updateTableHeaderView()
    }

    @objc
    func addButtonPressed() {
        let detailsController = AutofillLoginDetailsViewController(authenticator: viewModel.authenticator,
                                                                   syncService: syncService,
                                                                   tld: tld,
                                                                   authenticationNotRequired: viewModel.authenticationNotRequired)
        detailsController.delegate = self
        let detailsNavigationController = UINavigationController(rootViewController: detailsController)
        navigationController?.present(detailsNavigationController, animated: true)
        detailsViewController = detailsController
    }

    func makeAccountDetailsScreen(_ account: SecureVaultModels.WebsiteAccount) -> AutofillLoginDetailsViewController {
        let detailsController = AutofillLoginDetailsViewController(authenticator: viewModel.authenticator,
                                                                   syncService: syncService,
                                                                   account: account,
                                                                   tld: tld,
                                                                   authenticationNotRequired: viewModel.authenticationNotRequired)
        detailsController.delegate = self
        detailsViewController = detailsController
        return detailsController
    }
    
    func showAccountDetails(_ account: SecureVaultModels.WebsiteAccount, animated: Bool = true) {
        let detailsController = makeAccountDetailsScreen(account)
        navigationController?.pushViewController(detailsController, animated: animated)
        detailsViewController = detailsController
    }

    private func presentNeverPromptResetPromptAtIndexPath(_ indexPath: IndexPath) {
        let controller = UIAlertController(title: "",
                                           message: UserText.autofillResetNeverSavedActionTitle,
                                           preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: UserText.autofillResetNeverSavedActionConfirmButton, style: .destructive) { [weak self] _ in
            self?.viewModel.resetNeverPromptWebsites()
            self?.tableView.reloadData()
            Pixel.fire(pixel: .autofillLoginsSettingsResetExcludedConfirmed)
        })
        controller.addAction(UIAlertAction(title: UserText.autofillResetNeverSavedActionCancelButton, style: .cancel) { _ in
            Pixel.fire(pixel: .autofillLoginsSettingsResetExcludedDismissed)
        })
        present(controller: controller, fromView: tableView.cellForRow(at: indexPath) ?? tableView)
        Pixel.fire(pixel: .autofillLoginsSettingsResetExcludedDisplayed)
    }

    private func setupCancellables() {
        viewModel.$viewState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateViewState()
            }
            .store(in: &cancellables)
        
        viewModel.$sections
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.accountsCountPublisher
             .receive(on: DispatchQueue.main)
             .sink { [weak self] _ in
                 self?.updateToolbarLabel()
                 self?.updateTableHeaderView()
             }
             .store(in: &cancellables)

    }
    
    private func configureNotification() {
        addObserver(for: UIApplication.didBecomeActiveNotification, selector: #selector(appDidBecomeActiveCallback))
        addObserver(for: UIApplication.willResignActiveNotification, selector: #selector(appWillResignActiveCallback))
        addObserver(for: UIApplication.didEnterBackgroundNotification, selector: #selector(appWillResignActiveCallback))
        addObserver(for: AutofillLoginListAuthenticator.Notifications.invalidateContext, selector: #selector(authenticatorInvalidateContext))
    }

    private func addObserver(for notification: Notification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }

    private func removeObserver(for notification: Notification.Name) {
        NotificationCenter.default.removeObserver(self, name: notification, object: nil)
    }

    @objc private func appDidBecomeActiveCallback() {
        // AutofillLoginDetailsViewController will handle calling authenticate() if it is the top view controller
        guard navigationController?.topViewController is AutofillLoginDetailsViewController else {
            authenticate()
            return
        }
    }
    
    @objc private func appWillResignActiveCallback() {
        viewModel.lockUI()
    }

    @objc private func authenticatorInvalidateContext() {
        viewModel.authenticateInvalidateContext()
    }
    
    private func authenticate() {
        viewModel.authenticate {[weak self] error in
            guard let self = self else { return }
            self.viewModel.isAuthenticating = false
            
            if error != nil {
                if error != .noAuthAvailable {
                    self.delegate?.autofillLoginSettingsListViewControllerDidFinish(self)
                }
            } else {
                showSelectedAccountIfRequired()
                openSearchIfRequired()
                self.syncService.scheduler.requestSyncImmediately()
            }
        }
    }
    
    private func editAction() -> UIAction {
        return UIAction(title: UserText.actionGenericEdit) { [weak self] _ in
            self?.setEditing(true, animated: true)
        }
    }

    private func importAction() -> UIAction {
        return UIAction(title: UserText.autofillEmptyViewButtonTitle) { [weak self] _ in
            self?.segueToImport()
            Pixel.fire(pixel: .autofillLoginsImport)
        }
    }

    private func segueToImport() {
        let importController = ImportPasswordsViewController(syncService: syncService)
        importController.delegate = self
        navigationController?.pushViewController(importController, animated: true)
    }

    private func segueToSync(source: String? = nil) {
        if let settingsVC = self.navigationController?.children.first as? SettingsHostingController {
            navigationController?.popToRootViewController(animated: true)
            if let source = source {
                settingsVC.viewModel.shouldPresentSyncViewWithSource(source)
            } else {
                settingsVC.viewModel.presentLegacyView(.sync)
            }
        } else if let mainVC = self.presentingViewController as? MainViewController {
            dismiss(animated: true) {
                mainVC.segueToSettingsSync(with: source)
            }
        }
    }

    private func showSelectedAccountIfRequired() {
        if let account = selectedAccount {
            showAccountDetails(account)
            selectedAccount = nil
        }
    }

    private func openSearchIfRequired() {
        // Don't auto open search if user has selected an account
        guard selectedAccount == nil else { return }

        if openSearch {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.searchController.searchBar.searchTextField.becomeFirstResponder()
            }
            openSearch = false
        }
    }

    private func dismissSearchIfRequired() {
        guard searchController.isActive else { return }
        searchController.dismiss(animated: false)
    }

    private func presentDeleteConfirmation(for title: String, domain: String) {
        let message = title.isEmpty ? UserText.autofillLoginListLoginDeletedToastMessageNoTitle
                                    : UserText.autofillLoginListLoginDeletedToastMessage(for: title)

        ActionMessageView.present(message: message,
                                  actionTitle: UserText.actionGenericUndo,
                                  presentationLocation: .withoutBottomBar,
                                  onAction: {
            self.viewModel.undoLastDelete()
            self.syncService.scheduler.notifyDataChanged()
        }, onDidDismiss: {
            self.viewModel.clearUndoCache()
            NotificationCenter.default.post(name: FireproofFaviconUpdater.deleteFireproofFaviconNotification,
                                            object: nil,
                                            userInfo: [FireproofFaviconUpdater.UserInfoKeys.faviconDomain: domain])
            Pixel.fire(pixel: .autofillManagementDeleteLogin)
        })
    }

    @objc private func deleteAll() {
        let message = self.syncService.authState == .inactive ? UserText.autofillDeleteAllPasswordsActionMessage(for: viewModel.accountsCount)
                                                              : UserText.autofillDeleteAllPasswordsSyncActionMessage(for: viewModel.accountsCount)
        let alert = UIAlertController(title: UserText.autofillDeleteAllPasswordsActionTitle(for: viewModel.accountsCount),
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: UserText.actionCancel, style: .cancel))
        let deleteAllAction = UIAlertAction(title: UserText.actionDelete, style: .destructive) {[weak self] _ in
            self?.presentAuthConfirmationPrompt()
        }
        alert.addAction(deleteAllAction)
        alert.preferredAction = deleteAllAction
        present(controller: alert, fromView: tableView)
    }

    private func presentAuthConfirmationPrompt() {
        let authConfirmationPromptViewController = AuthConfirmationPromptViewController(
            didBeginAuthenticating: { [weak self] in
                self?.configureObserversBasedOnAuthConfirmationPrompt(isAuthenticating: true)
            }, authConfirmationCompletion: { [weak self] authenticated in
                self?.configureObserversBasedOnAuthConfirmationPrompt(isAuthenticating: false)

                if authenticated {
                    let accountsCount = self?.viewModel.accountsCount ?? 0
                    self?.viewModel.clearAllAccounts()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        self?.presentDeleteAllConfirmation(accountsCount)
                    })
                }
            }
        )

        if let presentationController = authConfirmationPromptViewController.presentationController as? UISheetPresentationController {
            if #available(iOS 16.0, *) {
                presentationController.detents = [.custom(resolver: { _ in
                    AutofillViews.deleteAllPromptMinHeight
                })]
            } else {
                presentationController.detents = [.medium()]
            }
        }

        present(authConfirmationPromptViewController, animated: true)
    }

    private func configureObserversBasedOnAuthConfirmationPrompt(isAuthenticating: Bool) {
        if isAuthenticating {
            addObserver(for: UIApplication.didEnterBackgroundNotification, selector: #selector(appWillResignActiveCallback))
            removeObserver(for: UIApplication.willResignActiveNotification)
        } else {
            addObserver(for: UIApplication.willResignActiveNotification, selector: #selector(appWillResignActiveCallback))
            removeObserver(for: UIApplication.didEnterBackgroundNotification)
        }
    }

    private func presentDeleteAllConfirmation(_ numberOfAccounts: Int) {
        var shouldDeleteAccounts = true

        ActionMessageView.present(message: UserText.autofillAllPasswordsDeletedToastMessage(for: numberOfAccounts),
                                  actionTitle: UserText.actionGenericUndo,
                                  presentationLocation: .withoutBottomBar,
                                  onAction: {
                                      shouldDeleteAccounts = false
                                  }, onDidDismiss: {
            if shouldDeleteAccounts {
                if self.viewModel.deleteAllCredentials() {
                    self.syncService.scheduler.notifyDataChanged()
                    self.viewModel.resetNeverPromptWebsites()
                    self.viewModel.updateData()
                    Pixel.fire(pixel: .autofillManagementDeleteAllLogins)
                }
            } else {
                self.viewModel.undoClearAllAccounts()
            }
        })
    }

    // MARK: Subviews Setup

    private func updateViewState() {
        
        switch viewModel.viewState {
        case .showItems:
            tableView.tableFooterView = nil
            tableView.isHidden = false
            lockedView.isHidden = true
            noAuthAvailableView.isHidden = true
            emptySearchView.isHidden = true
        case .noAuthAvailable:
            tableView.tableFooterView = nil
            tableView.isHidden = true
            lockedView.isHidden = true
            noAuthAvailableView.isHidden = false
            emptySearchView.isHidden = true
        case .authLocked:
            tableView.tableFooterView = nil
            tableView.isHidden = true
            lockedView.isHidden = false
            noAuthAvailableView.isHidden = true
            emptySearchView.isHidden = true
        case .empty:
            tableView.tableFooterView = emptyView
            tableView.isHidden = false
            setEditing(false, animated: false)
            lockedView.isHidden = true
            noAuthAvailableView.isHidden = true
            emptySearchView.isHidden = true
        case .searching:
            tableView.tableFooterView = nil
            tableView.isHidden = false
            lockedView.isHidden = true
            noAuthAvailableView.isHidden = true
            emptySearchView.isHidden = true
        case .searchingNoResults:
            tableView.tableFooterView = nil
            tableView.isHidden = false
            lockedView.isHidden = true
            noAuthAvailableView.isHidden = true
            emptySearchView.isHidden = false
        }
        updateNavigationBarButtons()
        updateSearchController()
        updateToolbar()
        updateTableHeaderView()
        tableView.reloadData()
    }

    private func updateNavigationBarButtons() {
        switch viewModel.viewState {
        case .showItems:
            if tableView.isEditing {
                navigationItem.rightBarButtonItems = [editButtonItem]
            } else {
                if viewModel.isAutofillEnabledInSettings || (!viewModel.isAutofillEnabledInSettings && viewModel.hasAccountsSaved) {
                    navigationItem.rightBarButtonItems = [moreBarButtonItem, addBarButtonItem]
                    moreBarButtonItem.isEnabled = true
                } else {
                    navigationItem.rightBarButtonItems = [addBarButtonItem]
                }
                addBarButtonItem.isEnabled = true
            }
        case .noAuthAvailable:
            navigationItem.rightBarButtonItems = [addBarButtonItem]
            addBarButtonItem.isEnabled = false
        case .authLocked:
            if viewModel.hasAccountsSaved {
                navigationItem.rightBarButtonItems = [moreBarButtonItem, addBarButtonItem]
                addBarButtonItem.isEnabled = false
                moreBarButtonItem.isEnabled = false
            } else {
                navigationItem.rightBarButtonItems = [addBarButtonItem]
                addBarButtonItem.isEnabled = false
            }
        case .empty:
            navigationItem.rightBarButtonItems = [addBarButtonItem]
            addBarButtonItem.isEnabled = true
        case .searching, .searchingNoResults:
            navigationItem.rightBarButtonItems = []
        }
    }

    private func updateSearchController() {
        switch viewModel.viewState {
        case .showItems:
            if tableView.isEditing {
                navigationItem.searchController = nil
            } else {
                navigationItem.searchController = searchController
            }
        case .searching, .searchingNoResults:
            navigationItem.searchController = searchController
        case .authLocked:
            navigationItem.searchController = viewModel.authenticationNotRequired && viewModel.hasAccountsSaved ? searchController : nil
        case .empty, .noAuthAvailable:
            navigationItem.searchController = nil
        }
    }

    private func updateToolbar() {
        if tableView.isEditing && viewModel.viewState == .showItems {
            updateToolbarLabel()
            navigationController?.isToolbarHidden = false
            toolbarItems = [deleteAllButtonItem, flexibleSpace, accountsCountButtonItem, flexibleSpace]
        } else {
            toolbarItems?.removeAll()
            navigationController?.isToolbarHidden = true
        }
    }

    private func updateToolbarLabel() {
        guard tableView.isEditing else { return }

        accountsCountLabel.text = UserText.autofillLoginListToolbarPasswordsCount(viewModel.accountsCount)
        accountsCountLabel.sizeToFit()
    }

    private func updateTableHeaderView() {
        guard tableView.frame != .zero else {
            return
        }

        if let survey = viewModel.getSurveyToPresent() {
            if shouldUpdateHeaderView(for: .survey(survey)) {
                configureTableHeaderView(for: .survey(survey))
                surveyPromptPresented = true
            }
            return
        }

        if viewModel.shouldShowSyncPromo() && !surveyPromptPresented {
            if shouldUpdateHeaderView(for: .syncPromo(.passwords)) {
                configureTableHeaderView(for: .syncPromo(.passwords))
            }
            return
        }

        // No header view is needed, clear the table header
        clearTableHeaderView()
    }

    private func shouldUpdateHeaderView(for type: AutofillHeaderViewFactory.ViewType) -> Bool {
        if let currentHeaderView = tableView.tableHeaderView,
           let headerView = currentHeaderHostingController?.view,
           currentHeaderView == headerView {
            return false
        }
        return true
    }

    private func configureTableHeaderView(for type: AutofillHeaderViewFactory.ViewType) {
        switch type {
        case .survey(let survey):
            currentHeaderHostingController = headerViewFactory.makeHeaderView(for: .survey(survey))
            if let hostingController = currentHeaderHostingController as? UIHostingController<AutofillSurveyView> {
                setupTableHeaderView(with: hostingController)
            }
        case .syncPromo(let promoType):
            currentHeaderHostingController = headerViewFactory.makeHeaderView(for: .syncPromo(promoType))
            if let hostingController = currentHeaderHostingController as? UIHostingController<SyncPromoView> {
                setupTableHeaderView(with: hostingController)
            }
        }
    }

    private func setupTableHeaderView(with hostingController: UIViewController) {
        addChild(hostingController)

        let viewWidth = tableView.bounds.width - tableView.layoutMargins.left - tableView.layoutMargins.right
        let viewHeight = hostingController.view.sizeThatFits(CGSize(width: viewWidth, height: CGFloat.greatestFiniteMagnitude)).height

        hostingController.view.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        tableView.tableHeaderView = hostingController.view

        hostingController.didMove(toParent: self)
    }

    private func clearTableHeaderView() {
        if tableView.tableHeaderView != nil {
            tableView.tableHeaderView = nil
        }
    }

    private func installSubviews() {
        view.addSubview(tableView)
        tableView.addSubview(emptySearchView)
        view.addSubview(lockedView)
        view.addSubview(noAuthAvailableView)
    }
    
    private func installConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        emptySearchView.translatesAutoresizingMaskIntoConstraints = false
        lockedView.translatesAutoresizingMaskIntoConstraints = false
        noAuthAvailableView.translatesAutoresizingMaskIntoConstraints = false

        updateConstraintConstants()

        NSLayoutConstraint.activate([
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptySearchView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptySearchViewCenterYConstraint,
            emptySearchView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.padding),
            emptySearchView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.padding),

            lockedView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lockedView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.padding),
            lockedView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.padding),
            lockedViewBottomConstraint,

            noAuthAvailableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noAuthAvailableView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noAuthAvailableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.padding),
            noAuthAvailableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.padding)
        ])
    }

    private func updateConstraintConstants() {
        let isIPhoneLandscape = traitCollection.containsTraits(in: UITraitCollection(verticalSizeClass: .compact))
        if isIPhoneLandscape {
            lockedViewBottomConstraint.constant = (view.frame.height / 2.0 - max(lockedView.frame.height, 120.0) / 2.0)
        } else {
            lockedViewBottomConstraint.constant = view.frame.height * 0.15
        }
    }

    // MARK: Cell Methods
    
    private func credentialCell(for tableView: UITableView, item: AutofillLoginItem, indexPath: IndexPath) -> AutofillListItemTableViewCell {
        let cell = tableView.dequeueCell(ofType: AutofillListItemTableViewCell.self, for: indexPath)
        cell.item = item
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = UIColor(designSystemColor: .surface)
        return cell
    }
    
    private func enableAutofillCell(for tableView: UITableView, indexPath: IndexPath) -> EnableAutofillSettingsTableViewCell {
        let cell = tableView.dequeueCell(ofType: EnableAutofillSettingsTableViewCell.self, for: indexPath)
        cell.delegate = self
        cell.isToggleOn = viewModel.isAutofillEnabledInSettings
        cell.theme = ThemeManager.shared.currentTheme
        return cell
    }

    private func neverSavedCell(for tableView: UITableView, indexPath: IndexPath) -> AutofillNeverSavedTableViewCell {
        let cell = tableView.dequeueCell(ofType: AutofillNeverSavedTableViewCell.self, for: indexPath)
        cell.theme = ThemeManager.shared.currentTheme
        return cell
    }

    private func reportCell(for tableView: UITableView, indexPath: IndexPath) -> AutofillBreakageReportTableViewCell {
        let cell = tableView.dequeueCell(ofType: AutofillBreakageReportTableViewCell.self, for: indexPath)
        let contentView = AutofillBreakageReportCellContentView(onReport: { [weak self] in

            guard let self = self, let alert = self.viewModel.createBreakageReporterAlert() else {
                return
            }

            self.present(controller: alert, fromView: self.tableView)

            Pixel.fire(pixel: .autofillLoginsReportConfirmationPromptDisplayed)
        })
        cell.embed(in: self, withView: contentView)
        cell.backgroundColor = UIColor(designSystemColor: .surface)
        cell.selectionStyle = .none
        return cell
    }
}

// MARK: UITableViewDelegate

extension AutofillLoginSettingsListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch viewModel.sections[indexPath.section] {
        case .enableAutofill:
            return 44
        case .suggestions, .credentials:
            return 60
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch viewModel.sections[indexPath.section] {
        case .enableAutofill:
            switch EnableAutofillRows(rawValue: indexPath.row) {
            case .resetNeverPromptWebsites:
                presentNeverPromptResetPromptAtIndexPath(indexPath)
            default:
                break
            }
        case .suggestions(_, let items):
            if indexPath.row < items.count {
                let item = items[indexPath.row]
                showAccountDetails(item.account)
            }
        case .credentials(_, let items):
            let item = items[indexPath.row]
            showAccountDetails(item.account)
        }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch viewModel.viewState {
        case .showItems, .empty:
            return viewModel.sections[section] == .enableAutofill ? enableAutofillFooterView : nil
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch viewModel.viewState {
        case .empty:
            if viewModel.sections[section] == .enableAutofill {
                return enableAutofillFooterView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            }
            return 0
        case .showItems:
            if viewModel.sections[section] == .enableAutofill {
                return enableAutofillFooterView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            }
            return 10.0
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            let theme = ThemeManager.shared.currentTheme
            view.textLabel?.textColor = theme.tableHeaderTextColor
        }
    }

    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            let theme = ThemeManager.shared.currentTheme
            view.textLabel?.textColor = theme.tableHeaderTextColor
        }
    }

}

// MARK: UITableViewDataSource

extension AutofillLoginSettingsListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.rowsInSection(section)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewModel.sections[indexPath.section] {
        case .enableAutofill:
            switch EnableAutofillRows(rawValue: indexPath.row) {
            case .toggleAutofill:
                return enableAutofillCell(for: tableView, indexPath: indexPath)
            case .resetNeverPromptWebsites:
                return neverSavedCell(for: tableView, indexPath: indexPath)
            default:
                fatalError("No cell for row at index \(indexPath.row)")
            }
        case .suggestions(_, let items):
            if indexPath.row == items.count {
                return reportCell(for: tableView, indexPath: indexPath)
            } else {
                return credentialCell(for: tableView, item: items[indexPath.row], indexPath: indexPath)
            }
        case .credentials(_, let items):
            return credentialCell(for: tableView, item: items[indexPath.row], indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        tableView.isEditing ? .delete : .none
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch viewModel.sections[indexPath.section] {
        case .credentials(_, let items), .suggestions(_, let items):
            if editingStyle == .delete {
                let title = items[indexPath.row].title
                let domain = items[indexPath.row].account.domain ?? ""
                let accountId = items[indexPath.row].account.id

                let tableContentToDelete = viewModel.tableContentsToDelete(accountId: accountId)

                let deletedSuccessfully = viewModel.delete(at: indexPath)

                if deletedSuccessfully {
                    tableView.beginUpdates()
                    if !tableContentToDelete.sectionsToDelete.isEmpty {
                        tableView.deleteSections(IndexSet(tableContentToDelete.sectionsToDelete), with: .automatic)
                    }
                    if !tableContentToDelete.rowsToDelete.isEmpty {
                        tableView.deleteRows(at: tableContentToDelete.rowsToDelete, with: .automatic)
                    }
                    tableView.endUpdates()

                    presentDeleteConfirmation(for: title, domain: domain)
                }
                syncService.scheduler.notifyDataChanged()
            }
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch viewModel.sections[section] {
        case .enableAutofill:
            return nil
        case .suggestions(let title, _), .credentials(let title, _):
            return title
        }
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        viewModel.viewState == .showItems ? UILocalizedIndexedCollation.current().sectionIndexTitles : []
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        var closestSoFar = 0
        var exactMatchIndex: Int?
        for (index, section) in viewModel.sections.enumerated() {
            if case .credentials(let sectionTitle, _) = section {
                
                if let first = title.first, !first.isLetter {
                    return viewModel.sections.count - 1
                }
                
                let result = sectionTitle.localizedCaseInsensitiveCompare(title)
                if result == .orderedSame {
                    exactMatchIndex = index
                    break
                } else if result == .orderedDescending {
                    break
                }
            }
            closestSoFar = index
        }
        return exactMatchIndex ?? closestSoFar
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch viewModel.sections[indexPath.section] {
        case .credentials, .suggestions:
            return true
        default:
            return false
        }
    }
}

// MARK: AutofillLoginDetailsViewControllerDelegate

extension AutofillLoginSettingsListViewController: AutofillLoginDetailsViewControllerDelegate {
    func autofillLoginDetailsViewControllerDidSave(_ controller: AutofillLoginDetailsViewController, account: SecureVaultModels.WebsiteAccount?) {
        viewModel.updateData()
        tableView.reloadData()
        syncService.scheduler.notifyDataChanged()

        if let account = account {
            showAccountDetails(account)
            Pixel.fire(pixel: .autofillManagementSaveLogin)
        } else {
            Pixel.fire(pixel: .autofillManagementUpdateLogin)
        }
    }

    func autofillLoginDetailsViewControllerDelete(account: SecureVaultModels.WebsiteAccount, title: String) {
        let deletedSuccessfully = viewModel.delete(account)

        if deletedSuccessfully {
            viewModel.updateData()
            tableView.reloadData()
            syncService.scheduler.notifyDataChanged()
            presentDeleteConfirmation(for: title, domain: account.domain ?? "")
        }
    }
}

// MARK: ImportPasswordsViewControllerDelegate

extension AutofillLoginSettingsListViewController: ImportPasswordsViewControllerDelegate {

    func importPasswordsViewControllerDidRequestOpenSync(_ viewController: ImportPasswordsViewController) {
        segueToSync()
    }

}

// MARK: EnableAutofillSettingsTableViewCellDelegate

extension AutofillLoginSettingsListViewController: EnableAutofillSettingsTableViewCellDelegate {
    func enableAutofillSettingsTableViewCell(_ cell: EnableAutofillSettingsTableViewCell, didChangeSettings value: Bool) {
        if value {
            Pixel.fire(pixel: .autofillLoginsSettingsEnabled)
        } else {
            Pixel.fire(pixel: .autofillLoginsSettingsDisabled, withAdditionalParameters: ["source": source.rawValue])
        }
        
        viewModel.isAutofillEnabledInSettings = value
        updateViewState()
    }
}

// MARK: Themable

extension AutofillLoginSettingsListViewController {

    private func decorate() {
        let theme = ThemeManager.shared.currentTheme

        view.backgroundColor = theme.backgroundColor
        tableView.backgroundColor = theme.backgroundColor
        tableView.separatorColor = UIColor(designSystemColor: .lines)
        tableView.sectionIndexColor = theme.buttonTintColor

        navigationController?.navigationBar.barTintColor = theme.barBackgroundColor
        navigationController?.navigationBar.tintColor = theme.navigationBarTintColor

        let appearance = UINavigationBarAppearance()
        appearance.shadowColor = .clear
        appearance.backgroundColor = theme.backgroundColor

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance

        tableView.reloadData()
    }
}

// MARK: UISearchControllerDelegate

extension AutofillLoginSettingsListViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        viewModel.isSearching = searchController.isActive

        if viewModel.isSearching {
            viewModel.isCancelingSearch = false
        }

        if !viewModel.isCancelingSearch, let query = searchController.searchBar.text {
            viewModel.filterData(with: query)
            emptySearchView.query = query
            tableView.reloadData()
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchController.searchBar.resignFirstResponder()
    }
}

extension AutofillLoginSettingsListViewController: UISearchBarDelegate {

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.isCancelingSearch = true
        viewModel.isSearching = false

        viewModel.filterData(with: "")
        tableView.reloadData()
    }
}

// MARK: UIAdaptivePresentationControllerDelegate

extension AutofillLoginSettingsListViewController: UIAdaptivePresentationControllerDelegate {

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        dismissSearchIfRequired()
    }

}

// MARK: Keyboard

extension AutofillLoginSettingsListViewController {

    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(adjustForKeyboard),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }

    @objc private func adjustForKeyboard(notification: NSNotification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        emptySearchViewCenterYConstraint.constant = min(
            (keyboardViewEndFrame.minY + emptySearchView.frame.height) / 2 - searchController.searchBar.frame.height,
            (tableView.frame.height / 2) - searchController.searchBar.frame.height
        )
    }
}

// MARK: AutofillHeaderViewDelegate

extension AutofillLoginSettingsListViewController: AutofillHeaderViewDelegate {

    func handlePrimaryAction(for headerType: AutofillHeaderViewFactory.ViewType) {
        switch headerType {
        case .survey(let survey):
            if let surveyURL = viewModel.surveyUrl(survey: survey.url) {
                LaunchTabNotification.postLaunchTabNotification(urlString: surveyURL.absoluteString)
                self.dismiss(animated: true)
            }
            viewModel.dismissSurvey(id: survey.id)
        case .syncPromo(let touchpoint):
            segueToSync(source: "promotion_passwords")
            Pixel.fire(.syncPromoConfirmed, withAdditionalParameters: ["source": touchpoint.rawValue])
        }
    }

    func handleDismissAction(for headerType: AutofillHeaderViewFactory.ViewType) {
        defer {
            updateTableHeaderView()
        }

        switch headerType {
        case .survey(let survey):
            viewModel.dismissSurvey(id: survey.id)
        case .syncPromo:
            viewModel.dismissSyncPromo()
        }
    }
}

extension NSNotification.Name {
    static let autofillFailureReport: NSNotification.Name = Notification.Name(rawValue: "com.duckduckgo.notification.autofillFailureReport")
}
