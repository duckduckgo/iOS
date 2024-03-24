//
//  WebTrackingProtectionView.swift
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

struct WebTrackingProtectionView: View {

    @EnvironmentObject var viewModel: SettingsViewModel

    var description: PrivacyProtectionDescription {
        PrivacyProtectionDescription(imageName: "SettingsWebTrackingProtectionContent",
                                     title: "Web Tracking Protection",
                                     status: .alwaysOn,
                                     explanation: UserText.webTrackingProtectionExplanation)
    }

    var body: some View {
        List {
            PrivacyProtectionDescriptionView(content: description)
            WebTrackingProtectionViewSettings()
        }
        .applySettingsListModifiers(title: "Web Tracking Protection",
                                    displayMode: .inline,
                                    viewModel: viewModel)
        .onForwardNavigationAppear {
            Pixel.fire(pixel: .settingsWebTrackingProtectionOpen,
                       withAdditionalParameters: PixelExperiment.parameters)
        }
    }
}

struct WebTrackingProtectionViewSettings: View {

    @EnvironmentObject var viewModel: SettingsViewModel

    var body: some View {
        Section {
            SettingsCellView(label: UserText.settingsGPC,
                             accesory: .toggle(isOn: viewModel.gpcBinding))
            SettingsCellView(label: UserText.settingsUnprotectedSites,
                              action: { viewModel.presentLegacyView(.unprotectedSites) },
                              disclosureIndicator: true,
                              isButton: true)
        }
    }
}
