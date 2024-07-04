//
//  SettingsCustomizeView.swift
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

struct SettingsCustomizeView: View {
        
    @EnvironmentObject var viewModel: SettingsViewModel
    @State var shouldShowNoMicrophonePermissionAlert = false

    var body: some View {
        Section(header: Text(UserText.settingsCustomizeSection),
                footer: Text(UserText.settingsAssociatedAppsDescription)) {
            
            SettingsCellView(label: UserText.settingsKeyboard,
                             action: { viewModel.presentLegacyView(.keyboard) },
                             disclosureIndicator: true,
                             isButton: true)
            
            SettingsCellView(label: UserText.settingsAutocompleteLabel,
                             subtitle: UserText.settingsAutocompleteSubtitle,
                             accesory: .toggle(isOn: viewModel.autocompleteBinding))

            if viewModel.shouldShowRecentlyVisitedSites {
                SettingsCellView(label: UserText.settingsAutocompleteRecentlyVisitedLabel,
                                 subtitle: UserText.settingsAutocompleteRecentlyVisitedSubtitle,
                                 accesory: .toggle(isOn: viewModel.autocompleteRecentlyVisitedSitesBinding))
            }


            if viewModel.state.speechRecognitionAvailable {
                SettingsCellView(label: UserText.settingsVoiceSearch,
                                 accesory: .toggle(isOn: viewModel.voiceSearchEnabledBinding))
            }
            SettingsCellView(label: UserText.settingsPreviews,
                             accesory: .toggle(isOn: viewModel.longPressBinding))
            
            SettingsCellView(label: UserText.settingsAssociatedApps,
                             accesory: .toggle(isOn: viewModel.universalLinksBinding))
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
