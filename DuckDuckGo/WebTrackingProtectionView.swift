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

    var body: some View {
        List {
            WebTrackingProtectionViewText()
            WebTrackingProtectionViewSettings()
        }
        .applySettingsListModifiers(title: "Web Tracking Protection",
                                    displayMode: .inline,
                                    viewModel: viewModel)
    }
}

struct WebTrackingProtectionViewText: View {

    var body: some View {
        VStack(spacing: 8) {
            Image("WebTrackingProtectionContent")
                .resizable()
                .frame(width: 128, height: 96)

            Text("Web Tracking Protection")
                .font(.title3)

            StatusIndicatorView(status: .alwaysOn)
                .padding(.top, -4)

            Text("DuckDuckGo never tracks you and we aim to protect your privacy as much as possible. We continually maintain and develop layers of protection to keep up with new tracking methods and provide many protections that other browsers don’t offer by default.\n[Learn More](ddgQuickLink://duckduckgo.com/duckduckgo-help-pages/privacy/web-tracking-protections/)")
                .font(.system(size: 16))
                .lineLimit(nil)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .tintIfAvailable(Color(designSystemColor: .accent))
                .padding(.horizontal, 32)
                .padding(.top, 8)
                .padding(.bottom)

            Spacer()
        }
        .listRowInsets(EdgeInsets(top: -12, leading: -12, bottom: -12, trailing: -12))
        .listRowBackground(Color(designSystemColor: .background).edgesIgnoringSafeArea(.all))
        .frame(maxWidth: .infinity)
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
