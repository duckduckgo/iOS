//
//  CookiePopUpProtectionView.swift
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

struct CookiePopUpProtectionView: View {

    @EnvironmentObject var viewModel: SettingsViewModel

    var description: PrivacyProtectionDescription {
        PrivacyProtectionDescription(imageName: "SettingsCookiePopUpProtectionContent",
                                     title: "Cookie Pop-Up Protection",
                                     status: viewModel.cookiePopUpProtectionStatus,
                                     explanation: UserText.cookiePopUpProtectionExplanation)
    }

    var body: some View {
        List {
            PrivacyProtectionDescriptionView(content: description)
            CookiePopUpProtectionViewSettings()
        }
        .applySettingsListModifiers(title: "Cookie Pop-Up Protection",
                                    displayMode: .inline,
                                    viewModel: viewModel)
        .onForwardNavigationAppear {
            Pixel.fire(pixel: .settingsAutoconsentShown,
                       withAdditionalParameters: PixelExperiment.parameters)
        }
    }
}

struct CookiePopUpProtectionViewSettings: View {

    @EnvironmentObject var viewModel: SettingsViewModel

    var body: some View {
        Section {
            SettingsCellView(label: "Let DuckDuckGo manage cookie consent pop-ups",
                             accesory: .toggle(isOn: viewModel.autoconsentBinding))
        }
    }
}
