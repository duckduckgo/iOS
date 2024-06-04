//
//  SettingsHostingController.swift
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

import UIKit
import SwiftUI
import Core
import Subscription

class SettingsHostingController: UIHostingController<AnyView> {
    var viewModel: SettingsViewModel
    var viewProvider: SettingsLegacyViewProvider

    init(viewModel: SettingsViewModel, viewProvider: SettingsLegacyViewProvider) {
        self.viewModel = viewModel
        self.viewProvider = viewProvider
        super.init(rootView: AnyView(EmptyView()))

        viewModel.onRequestPushLegacyView = { [weak self] vc in
            self?.pushLegacyViewController(vc)
        }

        viewModel.onRequestPresentLegacyView = { [weak self] vc, modal in
            self?.presentLegacyViewController(vc, modal: modal)
        }

        viewModel.onRequestPopLegacyView = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }

        viewModel.onRequestDismissSettings = { [weak self] in
            self?.navigationController?.dismiss(animated: true)
        }

        self.rootView = AnyView(SettingsRootView(viewModel: viewModel))

        decorateNavigationBar()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // If this is not called, settings navigation bar (UIKIt) is going wild with colors after reopening settings (?!)
        // Root cause will be investigated later as part of https://app.asana.com/0/414235014887631/1207098219526666/f
        decorateNavigationBar()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func pushLegacyViewController(_ vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }

    func presentLegacyViewController(_ vc: UIViewController, modal: Bool = false) {
        if modal {
            vc.modalPresentationStyle = .fullScreen
        }
        navigationController?.present(vc, animated: true)
    }
}
