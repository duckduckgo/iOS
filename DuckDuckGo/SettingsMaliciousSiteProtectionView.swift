//
//  SettingsMaliciousSiteProtectionView.swift
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
import DuckUI

struct SettingsMaliciousProtectionView: View {
    @StateObject private var maliciousSiteProtectionSettingsModel = MaliciousSiteProtectionSettingsViewModel()

    var body: some View {
        if maliciousSiteProtectionSettingsModel.shouldShowMaliciousSiteProtectionSection {
            Section(
                header: Text(UserText.MaliciousSiteProtectionSettings.header),
                footer:
                    VStack(alignment: .leading, spacing: 10) {
                        Button(action: maliciousSiteProtectionSettingsModel.learnMoreAction) {
                            Text(UserText.MaliciousSiteProtectionSettings.footerLearnMore)
                                .foregroundColor(.blueBase)
                        }

                        Text(UserText.MaliciousSiteProtectionSettings.footerDisabledMessage)
                            .opacity(maliciousSiteProtectionSettingsModel.maliciousSiteProtectionBinding.wrappedValue ? 0 : 1)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
            ) {
                SettingsCellView(
                    label: UserText.MaliciousSiteProtectionSettings.toggleMessage,
                    accessory: .toggle(isOn: maliciousSiteProtectionSettingsModel.maliciousSiteProtectionBinding)
                )
            }
        } else {
            EmptyView()
        }
    }
}

#Preview {
    SettingsMaliciousProtectionView()
}
