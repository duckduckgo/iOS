//
//  SettingsPrivacyProtectionDescriptionView.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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
import DesignResourcesKit

struct PrivacyProtectionDescription {
    let imageName: String
    let title: String
    let status: StatusIndicator
    let explanation: String
}

// Universal protection description view
struct PrivacyProtectionDescriptionView: View {

    let content: PrivacyProtectionDescription
    @EnvironmentObject var viewModel: SettingsViewModel

    var body: some View {
        VStack(spacing: 8) {
            Image(content.imageName)
                .resizable()
                .frame(width: 128, height: 96)

            Text(content.title)
                .daxTitle2()
                .multilineTextAlignment(.center)
                .foregroundColor(.init(designSystemColor: .textPrimary))

            StatusIndicatorView(status: content.status)
                .padding(.top, -4)

            Text(LocalizedStringKey(content.explanation))
                .daxBodyRegular()
                .multilineTextAlignment(.center)
                .foregroundColor(.init(designSystemColor: .textSecondary))
                .tintIfAvailable(Color(designSystemColor: .accent))
                .padding(.horizontal, 32)
                .padding(.top, 8)

            Spacer()
        }
        .listRowInsets(EdgeInsets(top: -12, leading: -12, bottom: -12, trailing: -12))
        .listRowBackground(Color(designSystemColor: .background).edgesIgnoringSafeArea(.all))
        .frame(maxWidth: .infinity)
    }
}
