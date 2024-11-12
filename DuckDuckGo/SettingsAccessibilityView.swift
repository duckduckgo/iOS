//
//  SettingsAccessibilityView.swift
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

struct SettingsAccessibilityView: View {

    @EnvironmentObject var viewModel: SettingsViewModel
    @State var shouldShowNoMicrophonePermissionAlert = false

    var body: some View {
        List {
            if viewModel.state.textZoom.enabled {
                Section(footer: Text(UserText.textZoomDescription)) {
                    // Text Size
                    SettingsPickerCellView(label: UserText.settingsText,
                                           options: TextZoomLevel.allCases,
                                           selectedOption: viewModel.textZoomLevelBinding)
                }
            }

            if viewModel.state.speechRecognitionAvailable {
                Section(footer: Text(UserText.voiceSearchFooter)) {
                    // Private Voice Search
                    SettingsCellView(label: UserText.settingsVoiceSearch,
                                     accessory: .toggle(isOn: viewModel.voiceSearchEnabledBinding))
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
        .applySettingsListModifiers(title: UserText.accessibility,
                                    displayMode: .inline,
                                    viewModel: viewModel)
        .onForwardNavigationAppear {
            Pixel.fire(pixel: .settingsAccessibilityOpen)
        }
    }
}
