//
//  SettingsOthersView.swift
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
import UIKit
import Networking

struct SettingsOthersView: View {

    @EnvironmentObject var viewModel: SettingsViewModel

    var body: some View {
        Section {
            // About
            NavigationLink(destination: AboutView().environmentObject(viewModel)) {
                SettingsCellView(label: UserText.settingsAboutSection,
                                 image: Image("LogoIcon"))
            }

            // Share Feedback
            if viewModel.usesUnifiedFeedbackForm {
                let formViewModel = UnifiedFeedbackFormViewModel(subscriptionManager: viewModel.subscriptionManager,
                                                                 apiService: DefaultAPIService(),
                                                                 vpnMetadataCollector: DefaultVPNMetadataCollector(),
                                                                 source: .settings)
                NavigationLink {
                    UnifiedFeedbackCategoryView(UserText.subscriptionFeedback, options: UnifiedFeedbackFlowCategory.allCases, selection: $viewModel.selectedFeedbackFlow) {
                        if let selectedFeedbackFlow = viewModel.selectedFeedbackFlow {
                            switch UnifiedFeedbackFlowCategory(rawValue: selectedFeedbackFlow) {
                            case nil:
                                EmptyView()
                            case .browserFeedback:
                                LegacyFeedbackView()
                            case .ppro:
                                UnifiedFeedbackRootView(viewModel: formViewModel)
                            }
                        }
                    }
                    .onFirstAppear {
                        Task {
                            await formViewModel.process(action: .reportShow)
                        }
                    }
                } label: {
                    SettingsCellView(label: UserText.subscriptionFeedback,
                                     image: Image("SettingsFeedback"))
                }
            } else {
                SettingsCellView(label: UserText.settingsFeedback,
                                 image: Image("SettingsFeedback"),
                                 action: { viewModel.presentLegacyView(.feedback) },
                                 isButton: true)
            }

            // DuckDuckGo on Other Platforms
            SettingsCellView(label: UserText.duckduckgoOnOtherPlatforms,
                             image: Image("SettingsOtherPlatforms"),
                             action: { viewModel.openOtherPlatforms() },
                             webLinkIndicator: true,
                             isButton: true)
        }
    }

}

private struct LegacyFeedbackView: View {
    var body: some View {
        LegacyFeedbackViewRepresentable()
    }
}

// swiftlint:disable force_cast
private struct LegacyFeedbackViewRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        let storyboard = UIStoryboard(name: "Feedback", bundle: nil)
        let navigationController = storyboard.instantiateViewController(withIdentifier: "Feedback") as! UINavigationController
        return navigationController.viewControllers.first!
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}
// swiftlint:enable force_cast
