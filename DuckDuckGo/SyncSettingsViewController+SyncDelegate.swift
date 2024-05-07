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
    var syncBookmarksPausedTitle: String {
        syncSettingsErrorHandler.syncBookmarksPausedMetadata.title
    }
    
    var syncCredentialsPausedTitle: String {
        syncSettingsErrorHandler.syncCredentialsPausedMetadata.title
    }
    
    var syncPausedTitle: String? {
        syncSettingsErrorHandler.syncPausedMetadata?.title
    }
    
    var syncBookmarksPausedDescription: String {
        syncSettingsErrorHandler.syncBookmarksPausedMetadata.message
    }
    
    var syncCredentialsPausedDescription: String {
        syncSettingsErrorHandler.syncCredentialsPausedMetadata.message
    }
    
    var syncPausedDescription: String? {
        syncSettingsErrorHandler.syncPausedMetadata?.message
    }
    
    var syncBookmarksPausedButtonTitle: String {
        syncSettingsErrorHandler.syncBookmarksPausedMetadata.buttonTitle
    }
    
    var syncCredentialsPausedButtonTitle: String {
        syncSettingsErrorHandler.syncCredentialsPausedMetadata.buttonTitle
    }
    

    func authenticateUser() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            authenticateUser { error in
                if let error {
                    switch error {
                    case .failedToAuthenticate:
                        continuation.resume(throwing: SyncSettingsViewModel.UserAuthenticationError.authFailed)
                    case .noAuthAvailable:
                        continuation.resume(throwing: SyncSettingsViewModel.UserAuthenticationError.authUnavailable)
                    }
                } else {
                    continuation.resume()
                }
            }
        }
    }

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
            syncService.scheduler.cancelSyncAndSuspendSyncQueue()
            do {
                let devices = try await syncService.updateDeviceName(name)
                mapDevices(devices)
            } catch {
                handleError(SyncErrorMessage.unableToUpdateDeviceName, error: error, event: .syncUpdateDeviceError)
            }
            syncService.scheduler.resumeSyncQueue()
        }
    }

    func createAccountAndStartSyncing(optionsViewModel: SyncSettingsViewModel) {
        authenticateUser { [weak self] error in
            guard error == nil, let self else { return }
            Task { @MainActor in
                do {
                    self.dismissPresentedViewController()
                    self.showPreparingSync()
                    try await self.syncService.createAccount(deviceName: self.deviceName, deviceType: self.deviceType)
                    Pixel.fire(pixel: .syncSignupDirect, includedParameters: [.appVersion])
                    self.rootView.model.syncEnabled(recoveryCode: self.recoveryCode)
                    self.refreshDevices()
                    self.navigationController?.topViewController?.dismiss(animated: true, completion: self.showRecoveryPDF)
                } catch {
                    self.handleError(SyncErrorMessage.unableToSyncToServer, error: error, event: .syncSignupError)
                }
            }
        }
    }

    @MainActor
    func handleError(_ type: SyncErrorMessage, error: Error?, event: Pixel.Event) {
        firePixelIfNeededFor(event: event, error: error)
        let alertController = UIAlertController(
            title: type.title,
            message: [type.description, error?.localizedDescription].compactMap({ $0 }).joined(separator: "\n"),
            preferredStyle: .alert)

        let okAction = UIAlertAction(title: UserText.syncPausedAlertOkButton, style: .default, handler: nil)
        alertController.addAction(okAction)

        if type == .unableToSyncToServer ||
            type == .unableToSyncWithDevice ||
            type == .unableToMergeTwoAccounts {
            // Gives time to the is syncing view to appear
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.dismissPresentedViewController { [weak self] in
                    self?.present(alertController, animated: true, completion: nil)
                }
            }
        } else {
            self.dismissPresentedViewController { [weak self] in
                self?.present(alertController, animated: true, completion: nil)
            }
        }
    }

    private func firePixelIfNeededFor(event: Pixel.Event, error: Error?) {
        guard let syncError = error as? SyncError else { return }
        if !syncError.isServerError {
            Pixel.fire(pixel: event, withAdditionalParameters: syncError.errorParameters)
        }
    }

    @MainActor
    func showSyncWithAnotherDevice() {
        collectCode(showConnectMode: true)
    }

    func showRecoverData() {
        authenticateUser { [weak self] error in
            guard error == nil, let self else { return }

            self.dismissPresentedViewController()
            self.collectCode(showConnectMode: false)
        }
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
            self.onConfirmSyncDisable = {
                   Task { @MainActor in
                       do {
                           try await self.syncService.disconnect()
                           self.rootView.model.isSyncEnabled = false
                           self.syncSettingsErrorHandler.syncDidTurnOff()
                           continuation.resume(returning: true)
                       } catch {
                           self.handleError(SyncErrorMessage.unableToTurnSyncOff, error: error, event: .syncLogoutError)
                           continuation.resume(returning: false)
                       }
                   }
               }
            let cancelAction = UIAlertAction(title: UserText.actionCancel, style: .cancel) { _ in
                continuation.resume(returning: false)
            }
            let confirmAction = UIAlertAction(title: UserText.syncTurnOffConfirmAction, style: .destructive) { _ in
                self.onConfirmSyncDisable?()
                continuation.resume(returning: true)
            }
            alert.addAction(cancelAction)
            alert.addAction(confirmAction)
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
            self.onConfirmAndDeleteAllData = {
                Task { @MainActor in
                    do {
                        try await self.syncService.deleteAccount()
                        self.rootView.model.isSyncEnabled = false
                        self.syncSettingsErrorHandler.syncDidTurnOff()
                        continuation.resume(returning: true)
                    } catch {
                        self.handleError(SyncErrorMessage.unableToDeleteData, error: error, event: .syncDeleteAccountError)
                        continuation.resume(returning: false)
                    }
                }
            }
            alert.addAction(title: UserText.syncDeleteAllConfirmAction, style: .destructive) {
                self.onConfirmAndDeleteAllData?()
                continuation.resume(returning: true)
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
                handleError(SyncErrorMessage.unableToRemoveDevice, error: error, event: .syncRemoveDeviceError)
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

enum SyncErrorMessage {
    case unableToSyncToServer
    case unableToSyncWithDevice
    case unableToMergeTwoAccounts
    case unableToUpdateDeviceName
    case unableToTurnSyncOff
    case unableToDeleteData
    case unableToRemoveDevice
    case unableToCreateRecoveryPdf

    var title: String {
        return UserText.syncErrorAlertTitle
    }

    var description: String {
        switch self {
        case .unableToSyncToServer:
            return UserText.unableToSyncToServerDescription
        case .unableToSyncWithDevice:
            return UserText.unableToSyncWithOtherDeviceDescription
        case .unableToMergeTwoAccounts:
            return UserText.unableToMergeTwoAccountsErrorDescription
        case .unableToUpdateDeviceName:
            return UserText.unableToUpdateDeviceNameDescription
        case .unableToTurnSyncOff:
            return UserText.unableToTurnSyncOffDescription
        case .unableToDeleteData:
            return UserText.unableToDeleteDataDescription
        case .unableToRemoveDevice:
            return UserText.unableToRemoveDeviceDescription
        case .unableToCreateRecoveryPdf:
            return UserText.unableToCreateRecoveryPDF
        }
    }
}
