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

@MainActor
class SyncManagementViewController: UIHostingController<SyncManagementView> {

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

    func showSyncSetup() {
        print(#function)
        
        let model = SyncSetupViewModel { [weak self] model in
            print(#function, model.state, self?.navigationController?.topViewController.self as Any)
            assert(self?.navigationController?.visibleViewController is DismissibleUIHostingController<SyncSetupView>)
            self?.navigationController?.topViewController?.dismiss(animated: true)
            self?.rootView.model.setupFinished(model)
        }

        let controller = DismissibleUIHostingController(rootView: SyncSetupView(model: model)) { [weak self] in
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
    }
    
    func showRecoveryPDF() {
        print(#function)
    }

    private func collectCode(canShowQRCode: Bool) {
        print(#function)

        let model = SyncCodeCollectionViewModel(canShowQRCode: canShowQRCode)
        model.delegate = self

        let controller = DismissibleUIHostingController(rootView: SyncCodeCollectionView(model: model)) { [weak self] in
            print(#function, "onDismiss", model)
            self?.rootView.model.codeCollectionCancelled()
        }

        let navController = UINavigationController(rootViewController: controller)
        navController.overrideUserInterfaceStyle = .dark
        navController.modalPresentationStyle = .fullScreen
        navigationController?.present(navController, animated: true) {
            print(#function, "completed")
            model.checkCameraPermission()
        }
    }
}

extension SyncManagementViewController: SyncCodeCollectionViewModelDelegate {

    func startConnectMode(_ model: SyncCodeCollectionViewModel) async -> String {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        Task {
            try await Task.sleep(nanoseconds: 1_000_000_000 * 10)
            showDeviceConnected()
        }
        #warning("This should be the code returned from the server")
        return "Connect Mode"
    }

    func handleScannedCode(_ model: SyncCodeCollectionViewModel, code: String) {
        #warning("Validate the code")
        showDeviceConnected()
    }

    func cancelled(_ model: SyncCodeCollectionViewModel) {
        print(#function, model, navigationController?.visibleViewController as Any)
        assert(navigationController?.visibleViewController is DismissibleUIHostingController<SyncCodeCollectionView>)
        navigationController?.topViewController?.dismiss(animated: true)
        rootView.model.codeCollectionCancelled()
    }

}
