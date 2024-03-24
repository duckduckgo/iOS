//
//  PrivateSearchView.swift
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

struct PrivateSearchView: View {

    @EnvironmentObject var viewModel: SettingsViewModel

    var description: PrivacyProtectionDescription {
        PrivacyProtectionDescription(imageName: "SettingsPrivateSearchContent",
                                     title: "Private Search",
                                     status: .alwaysOn,
                                     explanation: UserText.privateSearchExplanation)
    }

    var body: some View {
        List {
            PrivacyProtectionDescriptionView(content: description)
            PrivateSearchViewSettings()
        }
        .applySettingsListModifiers(title: "Private Search",
                                    displayMode: .inline,
                                    viewModel: viewModel)
        .onForwardNavigationAppear {
            Pixel.fire(pixel: .settingsPrivateSearchOpen,
                       withAdditionalParameters: PixelExperiment.parameters)
        }
    }
}

struct PrivateSearchViewSettings: View {

    @EnvironmentObject var viewModel: SettingsViewModel
    @State var shouldShowNoMicrophonePermissionAlert = false

    var body: some View {
        Section(header: Text("Search Settings")) {
            SettingsCellView(label: UserText.settingsAutocomplete,
                             subtitle: viewModel.autocompleteSubtitle,
                             accesory: .toggle(isOn: viewModel.autocompletePrivateSearchBinding))
            if viewModel.state.speechRecognitionAvailable {
                SettingsCellView(label: UserText.settingsVoiceSearch,
                                 subtitle: UserText.voiceSearchFooter,
                                 accesory: .toggle(isOn: viewModel.voiceSearchEnabledPrivateSearchBinding))
            }
            SettingsCellView(label: "More Search Settings",
                             subtitle: "Customize your language, region, and more",
                             action: { viewModel.openMoreSearchSettings() },
                             disclosureIndicator: true,
                             isButton: true)
        }
        .alert(isPresented: $shouldShowNoMicrophonePermissionAlert) {
            Alert(title: Text(UserText.noVoicePermissionAlertTitle),
                  message: Text(UserText.noVoicePermissionAlertMessage),
                  dismissButton: .default(Text(UserText.noVoicePermissionAlertOKbutton),
                  action: {
                    viewModel.shouldShowNoMicrophonePermissionAlert = false
                })
            )
        }
        .onChange(of: viewModel.shouldShowNoMicrophonePermissionAlert) { value in
            shouldShowNoMicrophonePermissionAlert = value
        }
    }
}

struct ForwardNavigationAppearModifier: ViewModifier {
    @State private var hasAppeared = false
    let action: () -> Void

    func body(content: Content) -> some View {
        content.onAppear {
            if !hasAppeared {
                action()
                hasAppeared = true
            }
        }
    }
}

extension View {
    func onForwardNavigationAppear(perform action: @escaping () -> Void) -> some View {
        self.modifier(ForwardNavigationAppearModifier(action: action))
    }
}
