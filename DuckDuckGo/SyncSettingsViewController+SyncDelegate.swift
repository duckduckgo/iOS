//
//  SyncSettingsViewController+SyncDelegate.swift
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

import Core
import UIKit
import SwiftUI
import SyncUI
import DDGSync
import AVFoundation

extension SyncSettingsViewController: SyncManagementViewModelDelegate {

    func launchAutofillViewController() {
        guard let mainVC = view.window?.rootViewController as? MainViewController else { return }
        dismiss(animated: true)
        mainVC.launchAutofillLogins()
    }

    func launchBookmarksViewController() {
        guard let mainVC = view.window?.rootViewController as? MainViewController else { return }
        dismiss(animated: true)
        mainVC.segueToBookmarks()
    }

    func updateDeviceName(_ name: String) {
        Task { @MainActor in
            rootView.model.devices = []
            do {
                let devices = try await syncService.updateDeviceName(name)
                mapDevices(devices)
            } catch {
                handleError(SyncError.unableToUpdateDeviceName, error: error)
            }
        }
    }

    func createAccountAndStartSyncing(optionsViewModel: SyncSettingsViewModel) {
        Task { @MainActor in
            do {
                self.dismissPresentedViewController()
                self.showPreparingSync()
                try await syncService.createAccount(deviceName: deviceName, deviceType: deviceType)
                Pixel.fire(pixel: .syncSignupDirect)
                self.rootView.model.syncEnabled(recoveryCode: recoveryCode)
                self.refreshDevices()
                navigationController?.topViewController?.dismiss(animated: true, completion: showRecoveryPDF)
            } catch {
                handleError(SyncError.unableToSync, error: error)
            }
        }
    }

    @MainActor
    func handleError(_ type: SyncError, error: Error) {
        self.dismissPresentedViewController()
        let alertController = UIAlertController(
            title: type.title,
            message: type.description + "\n" + error.localizedDescription,
            preferredStyle: .alert)

        let okAction = UIAlertAction(title: UserText.syncPausedAlertOkButton, style: .default, handler: nil)
        alertController.addAction(okAction)

        // Give time to the is syncing view to appear
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.dismissPresentedViewController { [weak self] in
                self?.navigationController?.topViewController?.present(alertController, animated: true, completion: nil)
            }
        }
    }

    func showSyncWithAnotherDevice() {
        collectCode(showConnectMode: true)
    }

    func showRecoverData() {
        dismissPresentedViewController()
        collectCode(showConnectMode: false)
    }

    func showDeviceConnected() {
        let controller = UIHostingController(
            rootView: DeviceConnectedView())
        navigationController?.present(controller, animated: true) { [weak self] in
            self?.rootView.model.syncEnabled(recoveryCode: self!.recoveryCode)
        }
    }

    func showPreparingSync() {
        let controller = UIHostingController(rootView: PreparingToSyncView())
        navigationController?.present(controller, animated: true)
    }

    @MainActor
    func showRecoveryPDF() {
        let model = SaveRecoveryKeyViewModel(key: recoveryCode) { [weak self] in
            self?.shareRecoveryPDF()
        } onDismiss: {
            self.showDeviceConnected()
        }
        let controller = UIHostingController(rootView: SaveRecoveryKeyView(model: model))
        navigationController?.present(controller, animated: true) { [weak self] in
            self?.rootView.model.syncEnabled(recoveryCode: self!.recoveryCode)
        }
    }

    private func collectCode(showConnectMode: Bool) {
        let model = ScanOrPasteCodeViewModel(showConnectMode: showConnectMode, recoveryCode: recoveryCode.isEmpty ? nil : recoveryCode)
        model.delegate = self

        var controller: UIHostingController<AnyView>
        if showConnectMode {
            controller = UIHostingController(rootView: AnyView(ScanOrSeeCode(model: model)))
        } else {
            controller = UIHostingController(rootView: AnyView(ScanOrEnterCodeToRecoverSyncedDataView(model: model)))
        }

        let navController = UIDevice.current.userInterfaceIdiom == .phone
        ? PortraitNavigationController(rootViewController: controller)
        : UINavigationController(rootViewController: controller)

        navController.overrideUserInterfaceStyle = .dark
        navController.setNeedsStatusBarAppearanceUpdate()
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
                    do {
                        self.rootView.model.isSyncEnabled = false
                        try await self.syncService.disconnect()
                        AppUserDefaults().isSyncBookmarksPaused = false
                        AppUserDefaults().isSyncCredentialsPaused = false
                    } catch {
                        self.handleError(SyncError.unableToTurnSyncOff, error: error)
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
                Task { @MainActor in
                    do {
                        self.rootView.model.isSyncEnabled = false
                        try await self.syncService.deleteAccount()
                        AppUserDefaults().isSyncBookmarksPaused = false
                        AppUserDefaults().isSyncCredentialsPaused = false
                    } catch {
                        self.handleError(SyncError.unableToDeleteData, error: error)
                    }
                    continuation.resume(returning: true)
                }
            }
            self.present(alert, animated: true)
        }
    }

    func copyCode() {
        UIPasteboard.general.string = recoveryCode
        ActionMessageView.present(message: UserText.syncCodeCopied,
                                  presentationLocation: .withoutBottomBar)
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

    func removeDevice(_ device: SyncSettingsViewModel.Device) {
        Task { @MainActor in
            do {
                try await syncService.disconnect(deviceId: device.id)
                refreshDevices()
            } catch {
                handleError(SyncError.unableToRemoveDevice, error: error)
            }
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

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        onDismiss()
    }
}

private class PortraitNavigationController: UINavigationController {

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        [.portrait, .portraitUpsideDown]
    }

}

enum SyncError {
    case unableToSync
    case unableToGetDevices
    case unableToUpdateDeviceName
    case unableToTurnSyncOff
    case unableToDeleteData
    case unableToRemoveDevice

    var title: String {
        return UserText.syncErrorAlertTitle
    }

    var description: String {
        switch self {
        case .unableToSync:
            return UserText.unableToSyncDescription
        case .unableToGetDevices:
            return UserText.unableToGetDevicesDescription
        case .unableToUpdateDeviceName:
            return UserText.unableToUpdateDeviceNameDescription
        case .unableToTurnSyncOff:
            return UserText.unableToTurnSyncOffDescription
        case .unableToDeleteData:
            return UserText.unableToDeleteDataDescription
        case .unableToRemoveDevice:
            return UserText.unableToRemoveDeviceDescription
        }
    }
}
