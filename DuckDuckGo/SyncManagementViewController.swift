//
//  SyncManagementViewController.swift
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

// Can this be re-used on macOS? 
typealias HostingController = UIHostingController
typealias Pasteboard = UIPasteboard

@MainActor
class SyncManagementViewController: HostingController<SyncManagementView> {

    let syncService: SyncService = FakeSyncService()

    convenience init() {
        self.init(rootView: SyncManagementView(model: SyncManagementViewModel()))

        // For some reason, on iOS 14, the viewDidLoad wasn't getting called
        rootView.model.delegate = self
        navigationItem.title = "Sync"
        applyTheme(ThemeManager.shared.currentTheme)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

extension SyncManagementViewController: Themable {

    func decorate(with theme: Theme) {
        view.backgroundColor = theme.backgroundColor
    }

}

extension SyncManagementViewController: SyncManagementViewModelDelegate {

    func createAccountAndStartSyncing() {
        Task { @MainActor in
            await syncService.createAccount()
            rootView.model.showDevices()
        }
    }

    func showSyncSetup() {
        print(#function)
        
        let model = SyncSetupViewModel { [weak self] model in
            print(#function, model.state, self?.navigationController?.topViewController.self as Any)
            assert(self?.navigationController?.visibleViewController is DismissibleHostingController<SyncSetupView>)
            self?.navigationController?.topViewController?.dismiss(animated: true)
            self?.rootView.model.setupFinished(model)
        }

        let controller = DismissibleHostingController(rootView: SyncSetupView(model: model)) { [weak self] in
            print(#function, "onDismiss", model)
            self?.rootView.model.setupFinished(model)
        }

        navigationController?.present(controller, animated: true) {
            print(#function, "completed")
        }
    }

    func showSyncWithAnotherDevice() {
        print(#function)
        collectCode(canShowQRCode: true)
    }

    func showRecoverData() {
        print(#function)
        collectCode(canShowQRCode: false)
    }

    func showDeviceConnected() {
        print(#function)

        let controller = HostingController(rootView: SyncDeviceConnectedView(showDeviceSynced: true))
        navigationController?.present(controller, animated: true) {
            print(#function, "completed")
        }
    }
    
    func showRecoveryPDF() {
        print(#function)
        let controller = HostingController(rootView: SyncDeviceConnectedView(showDeviceSynced: false))
        navigationController?.present(controller, animated: true) {
            print(#function, "completed")
        }
    }

    private func collectCode(canShowQRCode: Bool) {
        print(#function)

        let model = SyncCodeCollectionViewModel(canShowQRCode: canShowQRCode)
        model.delegate = self

        let controller = DismissibleHostingController(rootView: SyncCodeCollectionView(model: model)) { [weak self] in
            print(#function, "onDismiss", model)
            self?.rootView.model.codeCollectionCancelled()
        }

        let navController = UINavigationController(rootViewController: controller)
        navController.overrideUserInterfaceStyle = .dark
        navController.modalPresentationStyle = .fullScreen
        navigationController?.present(navController, animated: true) {
            print(#function, "completed")
            self.checkCameraPermission(model: model)
        }
    }

    func checkCameraPermission(model: SyncCodeCollectionViewModel) {
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

extension SyncManagementViewController: SyncCodeCollectionViewModelDelegate {

    var pasteboardString: String? {
        Pasteboard.general.string
    }

    func startConnectMode(_ model: SyncCodeCollectionViewModel) async -> String {
        return await syncService.retrieveConnectCode() ?? ""
    }

    func handleCode(_ model: SyncCodeCollectionViewModel, code: String) {
        navigationController?.topViewController?.dismiss(animated: true)
        showDeviceConnected()
    }

    func cancelled(_ model: SyncCodeCollectionViewModel) {
        print(#function, model, navigationController?.visibleViewController as Any)
        assert(navigationController?.visibleViewController is DismissibleHostingController<SyncCodeCollectionView>)
        navigationController?.topViewController?.dismiss(animated: true)
        rootView.model.codeCollectionCancelled()
    }

}

@MainActor
class DismissibleHostingController<Content: View>: HostingController<Content> {

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
