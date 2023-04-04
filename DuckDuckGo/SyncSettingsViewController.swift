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
import Combine
import AVFoundation
import SyncUI
import DDGSync

@MainActor
class SyncSettingsViewController: UIHostingController<SyncSettingsView> {

    lazy var authenticator = Authenticator()

    let syncService: DDGSyncing! = (UIApplication.shared.delegate as? AppDelegate)!.syncService
    var connector: RemoteConnecting?

    var recoveryCode: String {
        guard let code = syncService.account?.recoveryCode else {
            assertionFailure("No recovery code")
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

    convenience init() {
        self.init(rootView: SyncSettingsView(model: SyncSettingsViewModel()))

        // For some reason, on iOS 14, the viewDidLoad wasn't getting called so do some setup here
        if syncService.isAuthenticated {
            // TODO pass in the devices
            rootView.model.syncEnabled(recoveryCode: recoveryCode)
        }

        rootView.model.delegate = self
        navigationItem.title = "Sync" // TODO externalise
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme(ThemeManager.shared.currentTheme)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        connector = nil
    }

    func dismissPresentedViewController() {
        navigationController?.topViewController?.dismiss(animated: true)
    }
}

extension SyncSettingsViewController: Themable {

    func decorate(with theme: Theme) {
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

extension SyncSettingsViewController: SyncManagementViewModelDelegate {

    func createAccountAndStartSyncing() {
        Task { @MainActor in
            try await syncService.createAccount(deviceName: deviceName, deviceType: deviceType)
            rootView.model.syncEnabled(recoveryCode: recoveryCode)
            self.showRecoveryPDF()
        }
    }

    func showSyncSetup() {
        let model = TurnOnSyncViewModel { [weak self] in
            assert(self?.navigationController?.visibleViewController is DismissibleHostingController<TurnOnSyncView>)
            self?.dismissPresentedViewController()
            // Handle the finished logic in the closing of the view controller so that we also handle the
            //  user dismissing it (cancel, swipe down, etc)
        }

        let controller = DismissibleHostingController(rootView: TurnOnSyncView(model: model)) { [weak self] in
            assert(self?.navigationController?.visibleViewController is DismissibleHostingController<TurnOnSyncView>)
            self?.rootView.model.setupFinished(model)
        }

        navigationController?.present(controller, animated: true)
    }

    func showSyncWithAnotherDevice() {
        collectCode(isInRecoveryMode: false)
    }

    func showRecoverData() {
        collectCode(isInRecoveryMode: true)
    }

    func showDeviceConnected() {
        let model = SaveRecoveryKeyViewModel(key: recoveryCode) { [weak self] in
            self?.shareRecoveryPDF()
        }
        let controller = UIHostingController(rootView: DeviceConnectedView(saveRecoveryKeyViewModel: model))
        navigationController?.present(controller, animated: true) { [weak self] in
            self?.rootView.model.syncEnabled(recoveryCode: self!.recoveryCode)
            self?.rootView.model.appendDevice(.init(id: UUID().uuidString, name: "My MacBook Pro", type: "desktop", isThisDevice: false))
            self?.rootView.model.appendDevice(.init(id: UUID().uuidString, name: "My iPad", type: "tablet", isThisDevice: false))
            self?.rootView.model.appendDevice(.init(id: UUID().uuidString, name: "Unknown type", type: "linux", isThisDevice: false))
        }
    }
    
    func showRecoveryPDF() {
        let model = SaveRecoveryKeyViewModel(key: recoveryCode) { [weak self] in
            self?.shareRecoveryPDF()
        }
        let controller = UIHostingController(rootView: SaveRecoveryKeyView(model: model))
        navigationController?.present(controller, animated: true)
    }

    private func collectCode(isInRecoveryMode: Bool) {
        let model = ScanOrPasteCodeViewModel(isInRecoveryMode: isInRecoveryMode)
        model.delegate = self

        let controller = UIHostingController(rootView: ScanOrPasteCodeView(model: model))

        let navController = UIDevice.current.userInterfaceIdiom == .phone
            ? PortraitNavigationController(rootViewController: controller)
            : UINavigationController(rootViewController: controller)

        navController.overrideUserInterfaceStyle = .dark
        navController.modalPresentationStyle = .fullScreen
        navigationController?.present(navController, animated: true) {
            self.checkCameraPermission(model: model)
        }
    }

    func checkCameraPermission(model: ScanOrPasteCodeViewModel) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .notDetermined {
            Task { @MainActor in
                _ = await AVCaptureDevice.requestAccess(for: .video)
                self.checkCameraPermission(model: model)
            }
            return
        }

        switch status {
        case .denied: model.videoPermission = .denied
        case .authorized: model.videoPermission = .authorised
        default: assertionFailure("Unexpected status \(status)")
        }
    }

    func confirmAndDisableSync() async -> Bool {
        return await withCheckedContinuation { continuation in
            let alert = UIAlertController(title: UserText.syncTurnOffConfirmTitle,
                                          message: UserText.syncTurnOffConfirmMessage,
                                          preferredStyle: .alert)
            alert.addAction(title: UserText.actionCancel, style: .cancel) {
                continuation.resume(returning: false)
            }
            alert.addAction(title: UserText.syncTurnOffConfirmAction, style: .destructive) {
                Task { @MainActor in
                    // TODO handle error disconnecting
                    do {
                        try await self.syncService.disconnect()
                    } catch {
                        print(error.localizedDescription)
                    }
                    continuation.resume(returning: true)
                }
            }
            self.present(alert, animated: true)
        }
    }

    func confirmAndDeleteAllData() async -> Bool {
        return await withCheckedContinuation { continuation in
            let alert = UIAlertController(title: UserText.syncDeleteAllConfirmTitle,
                                          message: UserText.syncDeleteAllConfirmMessage,
                                          preferredStyle: .alert)
            alert.addAction(title: UserText.actionCancel, style: .cancel) {
                continuation.resume(returning: false)
            }
            alert.addAction(title: UserText.syncDeleteAllConfirmAction, style: .destructive) {
                continuation.resume(returning: true)
            }
            self.present(alert, animated: true)
        }
    }

    func copyCode() {
        UIPasteboard.general.string = recoveryCode
    }

    func confirmRemoveDevice(_ device: SyncSettingsViewModel.Device) async -> Bool {
        return await withCheckedContinuation { continuation in
            let alert = UIAlertController(title: UserText.syncRemoveDeviceTitle,
                                          message: UserText.syncRemoveDeviceMessage(device.name),
                                          preferredStyle: .alert)
            alert.addAction(title: UserText.actionCancel) {
                continuation.resume(returning: false)
            }
            alert.addAction(title: UserText.syncRemoveDeviceConfirmAction, style: .destructive) {
                continuation.resume(returning: true)
            }
            self.present(alert, animated: true)
        }
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
        if await authenticator.authenticate(reason: "Generate QRCode to connect to other devices") {
            do {
                self.connector = try syncService.remoteConnect()
                Task { @MainActor in
                    if let recoveryKey = try await connector?.pollForRecoveryKey() {
                        try await syncService.login(recoveryKey, deviceName: deviceName, deviceType: deviceType)
                    } else {
                        // Likely cancelled elsewhere
                        return
                    }
                    dismissPresentedViewController()
                    showDeviceConnected()
                }
                return self.connector?.code
            } catch {
                // TODO handle the error
                return nil
            }
        }
        return nil
    }

    func syncCodeEntered(code: String) async -> Bool {
        do {
            guard let syncCode = try? SyncCode.decodeBase64String(code) else {
                return false
            }

            if let recoveryKey = syncCode.recovery {
                try await syncService.login(recoveryKey, deviceName: deviceName, deviceType: deviceType)
                dismissPresentedViewController()
                showDeviceConnected()
                return true
            } else if let connectKey = syncCode.connect {
                try await syncService.transmitRecoveryKey(connectKey)
                dismissPresentedViewController()
                return true
            }

        } catch {
            if !(error is SyncError) {
                assertionFailure(error.localizedDescription)
            }
        }
        return false
    }

    func codeCollectionCancelled() {
        assert(navigationController?.visibleViewController is UIHostingController<ScanOrPasteCodeView>)
        dismissPresentedViewController()
        rootView.model.codeCollectionCancelled()
    }

    func gotoSettings() {
        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
        }
    }

}

private class DismissibleHostingController<Content: View>: UIHostingController<Content> {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.shared.currentTheme.statusBarStyle
    }

    let onDismiss: () -> Void

    init(rootView: Content, onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
        super.init(rootView: rootView)
    }

    required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        onDismiss()
    }
}

private class PortraitNavigationController: UINavigationController {

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        [.portrait, .portraitUpsideDown]
    }

}
