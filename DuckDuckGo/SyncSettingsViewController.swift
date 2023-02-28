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

@MainActor
class SyncSettingsViewController: UIHostingController<SyncSettingsScreenView> {

    let syncService: SyncService = FakeSyncService()

    lazy var authenticator = Authenticator()

    convenience init() {
        self.init(rootView: SyncSettingsScreenView(model: SyncSettingsScreenViewModel()))

        // For some reason, on iOS 14, the viewDidLoad wasn't getting called
        rootView.model.delegate = self
        navigationItem.title = "Sync"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme(ThemeManager.shared.currentTheme)
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
            await syncService.createAccount()
            rootView.model.showDevices()
        }
    }

    func showSyncSetup() {

        let model = TurnOnSyncViewModel { [weak self] model in
            assert(self?.navigationController?.visibleViewController is DismissibleHostingController<TurnOnSyncView>)
            self?.navigationController?.topViewController?.dismiss(animated: true)
            self?.rootView.model.setupFinished(model)
        }

        let controller = DismissibleHostingController(rootView: TurnOnSyncView(model: model)) { [weak self] in
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

    func shareRecoveryPDF() {
        guard let view = navigationController?.visibleViewController?.view,
              let url = Bundle.main.url(forResource: "DuckDuckGo Recovery Document", withExtension: "pdf") else {
            return
        }

        navigationController?.visibleViewController?.presentShareSheet(withItems: [url],
                                                                       fromView: view) { [weak self] _, success, _, _ in
            if success {
                self?.navigationController?.visibleViewController?.dismiss(animated: true)
            }
        }

    }

    func showDeviceConnected() {
        let controller = UIHostingController(rootView: DeviceConnectedView {
            self.shareRecoveryPDF()
        })
        navigationController?.present(controller, animated: true) {
            self.rootView.model.showDevices()
            self.rootView.model.appendDevice(.init(id: UUID().uuidString, name: "Another Device", isThisDevice: false))
        }

    }
    
    func showRecoveryPDF() {
        let controller = UIHostingController(rootView: SaveRecoveryPDFView {
            self.shareRecoveryPDF()
        })
        navigationController?.present(controller, animated: true)
    }

    private func collectCode(isInRecoveryMode: Bool) {
        let model = ScanOrPasteCodeViewModel(isInRecoveryMode: isInRecoveryMode)
        model.delegate = self

        let controller = DismissibleHostingController(rootView: ScanOrPasteCodeView(model: model)) { [weak self] in
            self?.rootView.model.codeCollectionCancelled()
        }

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

}

extension SyncSettingsViewController: ScanOrPasteCodeViewModelDelegate {

    var pasteboardString: String? {
        UIPasteboard.general.string
    }

    func startConnectMode() async -> String? {
        if await authenticator.authenticate(reason: "Generate QRCode to connect to other devices") {
            return await syncService.retrieveConnectCode()
        }
        return nil
    }

    func syncCodeEntered(code: String) -> Bool {
        navigationController?.topViewController?.dismiss(animated: true)
        showDeviceConnected()
        return true
    }

    func cancelled() {
        assert(navigationController?.visibleViewController is DismissibleHostingController<ScanOrPasteCodeView>)
        navigationController?.topViewController?.dismiss(animated: true)
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
