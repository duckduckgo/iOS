//
//  AboutView.swift
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

struct AboutView: View {

    @EnvironmentObject var viewModel: SettingsViewModel

    var body: some View {
        List {
            AboutViewText()
            AboutViewVersion()
        }
        .conditionalInsetGroupedListStyle()
    }
}

struct AboutViewText: View {

    var body: some View {
        VStack(spacing: 12) {
            Image("Logo")
                .resizable()
                .frame(width: 96, height: 96)
                .padding(.top)

            Image("TextDuckDuckGo")

            Text("Welcome to the Duck Side!")
                .daxHeadline()

            Rectangle()
                .frame(width: 80, height: 0.5)
                .foregroundColor(Color(designSystemColor: .lines))
                .padding()

            Text(LocalizedStringKey(UserText.aboutText))
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .foregroundColor(.primary)
                .tintIfAvailable(Color(designSystemColor: .accent))
                .padding(.horizontal, 32)
                .padding(.bottom)

            Spacer()
        }
        .listRowInsets(EdgeInsets(top: -12, leading: -12, bottom: -12, trailing: -12))
        .listRowBackground(Color(designSystemColor: .background).edgesIgnoringSafeArea(.all))
        .frame(maxWidth: .infinity)
    }
}

struct AboutViewVersion: View {

    @EnvironmentObject var viewModel: SettingsViewModel

    var body: some View {
        Section(header: Text("DuckDuckGo for iOS"), footer: Text(UserText.settingsSendCrashReportsDescription)) {
            SettingsCellView(label: UserText.settingsVersion,
                             accessory: .rightDetail(viewModel.state.version))

            // Send Crash Reports
            SettingsCellView(label: UserText.settingsSendCrashReports,
                             accessory: .toggle(isOn: viewModel.crashCollectionOptInStatusBinding))
        }
    }
}

extension View {
    
    @ViewBuilder func tintIfAvailable(_ color: Color) -> some View {
        if #available(iOS 16.0, *) {
            tint(color)
        } else {
            accentColor(color)
        }
    }
}
