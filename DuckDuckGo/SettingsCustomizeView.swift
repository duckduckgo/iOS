//  SettingsPrivacyView.swift
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
    @EnvironmentObject var viewProvider: SettingsLegacyViewProvider

    var body: some View {
        Section(header: Text("Customize"),
                footer: Text("Disable to prevent links from automatically opening in other installed apps")) {
            
            SettingsCellView(label: "Keyboard",
                             action: { viewModel.presentView(.keyboard) },
                             asLink: true,
                             disclosureIndicator: true)
            
            SettingsCellView(label: "Autocomplete Suggestions", accesory: .toggle(isOn: viewModel.autocompleteBinding))
            if viewModel.shouldShowSpeechRecognitionCell {
                SettingsCellView(label: "Private Voice Search", accesory: .toggle(isOn: viewModel.applicationLockBinding))
            }
            SettingsCellView(label: "Long-Press Previews", accesory: .toggle(isOn: viewModel.applicationLockBinding))
            SettingsCellView(label: "Open Links in Associated Apps", accesory: .toggle(isOn: viewModel.applicationLockBinding))
            
        }
         }
}
