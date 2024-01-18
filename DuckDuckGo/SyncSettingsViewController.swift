//
//  SyncSettingsViewController.swift
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

import SwiftUI
import Core
import Combine
import SyncUI
import DDGSync
import Common

@MainActor
class SyncSettingsViewController: UIHostingController<SyncSettingsView> {

    lazy var authenticator = Authenticator()

    let syncService: DDGSyncing
    let syncBookmarksAdapter: SyncBookmarksAdapter
    var connector: RemoteConnecting?

    var recoveryCode: String {
        guard let code = syncService.account?.recoveryCode else {
            return ""
        }

        return code
    }

    var deviceName: String {
        UIDevice.current.name
    }

    var deviceType: String {
        isPad ? "tablet" : "phone"
    }

    var cancellables = Set<AnyCancellable>()

    // For some reason, on iOS 14, the viewDidLoad wasn't getting called so do some setup here
    init(syncService: DDGSyncing, syncBookmarksAdapter: SyncBookmarksAdapter, appSettings: AppSettings = AppDependencyProvider.shared.appSettings) {
        self.syncService = syncService
        self.syncBookmarksAdapter = syncBookmarksAdapter

        let viewModel = SyncSettingsViewModel(
            isOnDevEnvironment: { syncService.serverEnvironment == .development },
            switchToProdEnvironment: {
                syncService.updateServerEnvironment(.production)
                UserDefaults.standard.set(ServerEnvironment.production.description, forKey: UserDefaultsWrapper<String>.Key.syncEnvironment.rawValue)
            }
        )

        super.init(rootView: SyncSettingsView(model: viewModel))

        setUpFaviconsFetcherSwitch(viewModel)
        setUpFavoritesDisplayModeSwitch(viewModel, appSettings)
        setUpSyncPaused(viewModel, appSettings)
        setUpSyncFeatureFlags(viewModel)
        refreshForState(syncService.authState)

        syncService.authStatePublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] authState in
                self?.refreshForState(authState)
            }
            .store(in: &cancellables)

        rootView.model.delegate = self
        navigationItem.title = SyncUI.UserText.syncTitle
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSyncFeatureFlags(_ viewModel: SyncSettingsViewModel) {
        syncService.featureFlagsPublisher.prepend(syncService.featureFlags)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { featureFlags in
                viewModel.isDataSyncingAvailable = featureFlags.contains(.dataSyncing)
                viewModel.isConnectingDevicesAvailable = featureFlags.contains(.connectFlows)
                viewModel.isAccountCreationAvailable = featureFlags.contains(.accountCreation)
                viewModel.isAccountRecoveryAvailable = featureFlags.contains(.accountRecovery)
            }
            .store(in: &cancellables)
    }

    private func setUpFaviconsFetcherSwitch(_ viewModel: SyncSettingsViewModel) {
        viewModel.isFaviconsFetchingEnabled = syncBookmarksAdapter.isFaviconsFetchingEnabled

        syncBookmarksAdapter.$isFaviconsFetchingEnabled
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { isFaviconsFetchingEnabled in
                if viewModel.isFaviconsFetchingEnabled != isFaviconsFetchingEnabled {
                    viewModel.isFaviconsFetchingEnabled = isFaviconsFetchingEnabled
                }
            }
            .store(in: &cancellables)

        viewModel.$devices
            .map { $0.count > 1 }
            .removeDuplicates()
            .sink { [weak self] hasMoreThanOneDevice in
                self?.syncBookmarksAdapter.isEligibleForFaviconsFetcherOnboarding = hasMoreThanOneDevice
            }
            .store(in: &cancellables)

        viewModel.$isFaviconsFetchingEnabled
            .sink { [weak self] isFaviconsFetchingEnabled in
                self?.syncBookmarksAdapter.isFaviconsFetchingEnabled = isFaviconsFetchingEnabled
                if isFaviconsFetchingEnabled {
                    self?.syncService.scheduler.notifyDataChanged()
                }
            }
            .store(in: &cancellables)
    }

    private func setUpFavoritesDisplayModeSwitch(_ viewModel: SyncSettingsViewModel, _ appSettings: AppSettings) {
        viewModel.isUnifiedFavoritesEnabled = appSettings.favoritesDisplayMode.isDisplayUnified

        viewModel.$isUnifiedFavoritesEnabled.dropFirst().removeDuplicates()
            .sink { [weak self] isEnabled in
                appSettings.favoritesDisplayMode = isEnabled ? .displayUnified(native: .mobile) : .displayNative(.mobile)
                NotificationCenter.default.post(name: AppUserDefaults.Notifications.favoritesDisplayModeChange, object: self)
                self?.syncService.scheduler.notifyDataChanged()
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: AppUserDefaults.Notifications.favoritesDisplayModeChange)
            .filter { [weak self] notification in
                guard let viewController = notification.object as? SyncSettingsViewController else {
                    return true
                }
                return viewController !== self
            }
            .receive(on: DispatchQueue.main)
            .sink { _ in
                viewModel.isUnifiedFavoritesEnabled = appSettings.favoritesDisplayMode.isDisplayUnified
            }
            .store(in: &cancellables)
    }

    private func setUpSyncPaused(_ viewModel: SyncSettingsViewModel, _ appSettings: AppSettings) {
        viewModel.isSyncBookmarksPaused = appSettings.isSyncBookmarksPaused
        viewModel.isSyncCredentialsPaused = appSettings.isSyncCredentialsPaused
        NotificationCenter.default.publisher(for: AppUserDefaults.Notifications.syncPausedStateChanged)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                viewModel.isSyncBookmarksPaused = appSettings.isSyncBookmarksPaused
                viewModel.isSyncCredentialsPaused = appSettings.isSyncCredentialsPaused
            }
            .store(in: &cancellables)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme(ThemeManager.shared.currentTheme)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        connector = nil
        syncService.scheduler.requestSyncImmediately()
    }

    func updateOptions() {
        syncService.scheduler.requestSyncImmediately()
    }

    func refreshForState(_ authState: SyncAuthState) {
        rootView.model.isSyncEnabled = authState != .inactive
        if authState != .inactive {
            rootView.model.syncEnabled(recoveryCode: recoveryCode)
            refreshDevices()
        }
    }

    func dismissPresentedViewController(completion: (() -> Void)? = nil) {
        guard let presentedViewController = navigationController?.presentedViewController,
              !(presentedViewController is UIHostingController<SyncSettingsView>) else {
            completion?()
            return
        }
        presentedViewController.dismiss(animated: true, completion: completion)
        endConnectMode()
    }

    func refreshDevices(clearDevices: Bool = true) {
        guard syncService.authState != .inactive else { return }

        Task { @MainActor in
            if clearDevices {
                rootView.model.devices = []
            }

            do {
                let devices = try await syncService.fetchDevices()
                mapDevices(devices)
            } catch {
                // Not displaying error since there is the spinner and it is called every few seconds
                os_log(error.localizedDescription, log: .syncLog, type: .error)
            }
        }
    }

    func mapDevices(_ devices: [RegisteredDevice]) {
        rootView.model.devices = devices.map {
            .init(id: $0.id, name: $0.name, type: $0.type, isThisDevice: $0.id == syncService.account?.deviceId)
        }.sorted(by: { lhs, _ in
            lhs.isThisDevice
        })
    }

}

extension SyncSettingsViewController: ScanOrPasteCodeViewModelDelegate {

    var pasteboardString: String? {
        UIPasteboard.general.string
    }

    func endConnectMode() {
        connector?.stopPolling()
        connector = nil
    }

    func startConnectMode() async -> String? {
        // Handle local authentication later
        do {
            self.connector = try syncService.remoteConnect()
            self.startPolling()
            return self.connector?.code
        } catch {
            self.handleError(SyncError.unableToSyncToServer, error: error)
            return nil
        }
    }

    func loginAndShowDeviceConnected(recoveryKey: SyncCode.RecoveryKey) async throws {
        let registeredDevices = try await syncService.login(recoveryKey, deviceName: deviceName, deviceType: deviceType)
        mapDevices(registeredDevices)
        Pixel.fire(pixel: .syncLogin, includedParameters: [.appVersion])
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.dismissVCAndShowRecoveryPDF()
        }
    }

    func startPolling() {
        Task { @MainActor in
            do {
                if let recoveryKey = try await connector?.pollForRecoveryKey() {
                    dismissPresentedViewController()
                    showPreparingSync()
                    try await loginAndShowDeviceConnected(recoveryKey: recoveryKey)
                } else {
                    // Likely cancelled elsewhere
                    return
                }
            } catch {
                handleError(SyncError.unableToSyncWithDevice, error: error)
            }
        }
    }

    func syncCodeEntered(code: String) async -> Bool {
        var shouldShowSyncEnabled = true
        guard let syncCode = try? SyncCode.decodeBase64String(code) else {
            return false
        }
        if let recoveryKey = syncCode.recovery {
            dismissPresentedViewController()
            showPreparingSync()
            do {
                try await loginAndShowDeviceConnected(recoveryKey: recoveryKey)
                return true
            } catch {
                if self.rootView.model.isSyncEnabled {
                    handleError(.unableToMergeTwoAccounts, error: nil)
                } else {
                    handleError(.unableToSyncToServer, error: error)
                }
            }
        } else if let connectKey = syncCode.connect {
            dismissPresentedViewController()
            showPreparingSync()
            if syncService.account == nil {
                do {
                    try await syncService.createAccount(deviceName: deviceName, deviceType: deviceType)
                    Pixel.fire(pixel: .syncSignupConnect, includedParameters: [.appVersion])
                    self.dismissVCAndShowRecoveryPDF()
                    shouldShowSyncEnabled = false
                    rootView.model.syncEnabled(recoveryCode: recoveryCode)
                } catch {
                    handleError(.unableToSyncToServer, error: error)
                }
            }
            do {
                try await syncService.transmitRecoveryKey(connectKey)
                self.rootView.model.$devices
                    .removeDuplicates()
                    .dropFirst()
                    .prefix(1)
                    .sink { [weak self] _ in
                        guard let self else { return }
                        if shouldShowSyncEnabled {
                            self.dismissVCAndShowRecoveryPDF()
                        }
                    }.store(in: &cancellables)
            } catch {
                handleError(.unableToSyncWithDevice, error: error)
            }

            return true
        }
        return false
    }

    func dismissVCAndShowRecoveryPDF() {
        self.navigationController?.topViewController?.dismiss(animated: true, completion: self.showRecoveryPDF)
    }

    func codeCollectionCancelled() {
        assert(navigationController?.visibleViewController is UIHostingController<AnyView>)
        dismissPresentedViewController()
    }

    func gotoSettings() {
        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
        }
    }

}
