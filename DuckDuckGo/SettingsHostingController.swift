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
#if SUBSCRIPTION
import Subscription
#endif

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

        // TODO: Select view based on the cohort
//        let settingsView = SettingsView(viewModel: viewModel)
        let settingsRootView = SettingsRootView(viewModel: viewModel)
        self.rootView = AnyView(settingsRootView)
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

extension SettingsHostingController: Themable {
    
    func decorate(with theme: Theme) {
        // Apply Theme
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
