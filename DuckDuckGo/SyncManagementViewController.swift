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
    }

    var scannedCodeCancellable: AnyCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()
        rootView.model.delegate = self
        navigationItem.title = "Sync"
        applyTheme(ThemeManager.shared.currentTheme)
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
        let model = SyncSetupViewModel()
        let controller = DismissibleUIHostingController(rootView: SyncSetupView(model: model)) { [weak self] in
            print(#function, "onDismiss", model)
            self?.rootView.model.setupFinished(model)
        }

        navigationController?.present(controller, animated: true) {
            print(#function, "completed")
        }
    }

    func showRecoverData() {
        print(#function)
    }

    func showSyncWithAnotherDevice() {
        print(#function)

        let model = SyncCodeCollectionViewModel()
        let controller = DismissibleUIHostingController(rootView: SyncCodeCollectionView(model: model)) { [weak self] in
            print(#function, "onDismiss", model)
            self?.scannedCodeCancellable = nil
            self?.rootView.model.codeCollectionCancelled()
        }

        scannedCodeCancellable = model.$scannedCode.sink { [weak self] code in
            guard let code = code else { return }
            if self?.rootView.model.codeScanned(code) == .valid {
                self?.scannedCodeCancellable = nil
                controller.dismiss(animated: true)
            }
        }

        controller.modalPresentationStyle = .fullScreen
        navigationController?.present(controller, animated: true) {
            print(#function, "completed")
        }

    }

    func showDeviceConnected() {
        print(#function)
    }
    
    func showRecoveryPDF() {
        print(#function)
    }

}
