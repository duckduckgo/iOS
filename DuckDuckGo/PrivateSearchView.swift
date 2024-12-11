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
                                     title: UserText.privateSearch,
                                     status: .alwaysOn,
                                     explanation: UserText.privateSearchExplanation)
    }

    var body: some View {
        List {
            PrivacyProtectionDescriptionView(content: description)
            PrivateSearchViewSettings()
        }
        .applySettingsListModifiers(title: UserText.privateSearch,
                                    displayMode: .inline,
                                    viewModel: viewModel)
        .onFirstAppear {
            Pixel.fire(pixel: .settingsPrivateSearchOpen)
        }
    }
}

struct PrivateSearchViewSettings: View {

    @EnvironmentObject var viewModel: SettingsViewModel

    var body: some View {
        Section(footer: Text(UserText.settingsAutocompleteSubtitle)) {
            // Autocomplete Suggestions
            SettingsCellView(label: UserText.settingsAutocompleteLabel,
                             accessory: .toggle(isOn: viewModel.autocompletePrivateSearchBinding))
        }

        if viewModel.shouldShowRecentlyVisitedSites {
            Section(footer: Text(UserText.settingsAutocompleteRecentlyVisitedSubtitle)) {
                SettingsCellView(label: UserText.settingsAutocompleteRecentlyVisitedLabel,
                                 accessory: .toggle(isOn: viewModel.autocompleteRecentlyVisitedSitesBinding))
            }
        }

        Section {
            // More Search Settings
            SettingsCellView(label: UserText.moreSearchSettings,
                             subtitle: UserText.moreSearchSettingsExplanation,
                             action: { viewModel.openMoreSearchSettings() },
                             webLinkIndicator: true,
                             isButton: true)
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
