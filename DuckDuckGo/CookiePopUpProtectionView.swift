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

    var body: some View {
        List {
            CookiePopUpProtectionViewText()
            CookiePopUpProtectionViewSettings()
        }
        .applySettingsListModifiers(title: "Cookie Pop-Up Protection",
                                    displayMode: .inline,
                                    viewModel: viewModel)
    }
}

struct CookiePopUpProtectionViewText: View {

    @EnvironmentObject var viewModel: SettingsViewModel

    var body: some View {
        VStack(spacing: 8) {
            Image("CookiePopUpProtectionContent")
                .resizable()
                .frame(width: 128, height: 96)

            Text("Cookie Pop-Up Protection")
                .font(.title3)

            StatusIndicatorView(status: viewModel.cookiePopUpProtectionStatus)
                .padding(.top, -4)

            Text(UserText.cookiePopUpProtectionExplanation)
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

struct CookiePopUpProtectionViewSettings: View {

    @EnvironmentObject var viewModel: SettingsViewModel

    var body: some View {
        Section {
            SettingsCellView(label: "Let DuckDuckGo manage cookie consent pop-ups",
                             accesory: .toggle(isOn: viewModel.autoconsentBinding))
        }
    }
}
