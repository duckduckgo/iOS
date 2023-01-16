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

@MainActor
class SyncManagementViewController: UIHostingController<SyncManagementView> {

    convenience init() {
        self.init(rootView: SyncManagementView(model: SyncManagementViewModel()))
    }

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
        let controller = DismissibleUIHostingController(rootView: SyncSetupView(model: model)) {
            print(#function, "onDismiss", model)
            self.rootView.model.setupFinished(model)
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
    }

}

@MainActor
class DismissibleUIHostingController<Content: View>: UIHostingController<Content> {
    
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
