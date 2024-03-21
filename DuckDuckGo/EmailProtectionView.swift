//
//  EmailProtectionView.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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
import SwiftUI
import DesignResourcesKit

struct EmailProtectionView: View {

    @EnvironmentObject var viewModel: SettingsViewModel
    @State var shouldShowEmailAlert = false

    var description: PrivacyProtectionDescription {
        PrivacyProtectionDescription(imageName: "EmailProtectionContent",
                                     title: "Email Protection",
                                     status: viewModel.emailProtectionStatus,
                                     explanation: UserText.emailProtectionExplanation)
    }

    var body: some View {
        List {
            PrivacyProtectionDescriptionView(content: description)
            EmailProtectionViewSettings()
        }
        .applySettingsListModifiers(title: "Email Protection",
                                    displayMode: .inline,
                                    viewModel: viewModel)
        .onForwardNavigationAppear {
            Pixel.fire(pixel: .settingsEmailProtectionOpen,
                       withAdditionalParameters: PixelExperiment.parameters)
        }
        .alert(isPresented: $shouldShowEmailAlert) {
            Alert(title: Text("Disable Email Protection Autofill"),
                  message: Text(UserText.emailProtectionSigningOutAlert),
                  primaryButton: .default(Text(UserText.actionOK), action: {
                try? viewModel.emailManager.signOut()
                viewModel.shouldShowEmailAlert = false
            }),
                  secondaryButton: .cancel(Text("Cancel"), action: {
                viewModel.shouldShowEmailAlert = false
            })
            )
        }
        .onChange(of: viewModel.shouldShowEmailAlert) { value in
            shouldShowEmailAlert = value
        }
    }
}

struct EmailProtectionViewSettings: View {

    @EnvironmentObject var viewModel: SettingsViewModel

    var body: some View {
        if viewModel.emailManager.isSignedIn {
            let userEmail = viewModel.emailManager.userEmail ?? ""
            Section(header: Text(userEmail)) {
                SettingsCellView(label: "Manage Account",
                                 action: { viewModel.openEmailAccountManagement() },
                                 webLinkIndicator: true,
                                 isButton: true)
                SettingsCellView(label: "Disable Email Protection Autofill",
                                 action: { viewModel.shouldShowEmailAlert = true },
                                 isButton: true)
            }

            Section {
                SettingsCellView(label: "Support",
                                 action: { viewModel.openEmailSupport() },
                                 webLinkIndicator: true,
                                 isButton: true)
            }
        } else {
            Section {
                SettingsCellView(label: "Enable Email Protection",
                                 action: { viewModel.openEmailProtection() },
                                 webLinkIndicator: true,
                                 isButton: true)
            }
        }
    }
}
