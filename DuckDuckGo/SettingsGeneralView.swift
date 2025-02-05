//
//  SettingsGeneralView.swift
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

struct SettingsGeneralView: View {

    @EnvironmentObject var viewModel: SettingsViewModel
    @State var shouldShowNoMicrophonePermissionAlert = false

    var body: some View {
        ScrollViewReader { proxy in
            List {
                // Application Lock
                Section(footer: Text(UserText.settingsAutoLockDescription)) {
                    SettingsCellView(label: UserText.settingsAutolock,
                                     accessory: .toggle(isOn: viewModel.applicationLockBinding))

                }

                Section(header: Text(UserText.privateSearch),
                        footer: Text(UserText.settingsAutocompleteSubtitle)) {
                    // Autocomplete Suggestions
                    SettingsCellView(label: UserText.settingsAutocompleteLabel,
                                     accessory: .toggle(isOn: viewModel.autocompleteGeneralBinding))
                }

                if viewModel.shouldShowRecentlyVisitedSites {
                    Section(footer: Text(UserText.settingsAutocompleteRecentlyVisitedSubtitle)) {
                        SettingsCellView(label: UserText.settingsAutocompleteRecentlyVisitedLabel,
                                         accessory: .toggle(isOn: viewModel.autocompleteRecentlyVisitedSitesBinding))
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

                Section(header: Text(UserText.settingsCustomizeSection),
                        footer: Text(UserText.settingsAssociatedAppsDescription)) {
                    // Keyboard
                    SettingsCellView(label: UserText.settingsKeyboard,
                                     action: { viewModel.presentLegacyView(.keyboard) },
                                     disclosureIndicator: true,
                                     isButton: true)

                    // Long-Press Previews
                    SettingsCellView(label: UserText.settingsPreviews,
                                     accessory: .toggle(isOn: viewModel.longPressBinding))

                    // Open Links in Associated Apps
                    SettingsCellView(label: UserText.settingsAssociatedApps,
                                     accessory: .toggle(isOn: viewModel.universalLinksBinding))
                }

                SettingsMaliciousProtectionSectionView(proxy: proxy, model: MaliciousSiteProtectionSettingsViewModel(manager: viewModel.maliciousSiteProtectionPreferencesManager))

            }
            .applySettingsListModifiers(title: UserText.general,
                                        displayMode: .inline,
                                        viewModel: viewModel)
            .onFirstAppear {
                Pixel.fire(pixel: .settingsGeneralOpen)
            }
        }
    }
}
