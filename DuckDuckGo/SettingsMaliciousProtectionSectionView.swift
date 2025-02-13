//
//  SettingsMaliciousProtectionSectionView.swift
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

struct SettingsMaliciousProtectionSectionView: View {
    private enum Constants {
        static let sectionIdentifier = "MaliciousSiteProtectionSettingsSection"
    }

    private let proxy: ScrollViewProxy
    @ObservedObject private var model: MaliciousSiteProtectionSettingsViewModel

    init(proxy: ScrollViewProxy, model: MaliciousSiteProtectionSettingsViewModel) {
        self.proxy = proxy
        self.model = model
    }

    var body: some View {
        if model.shouldShowMaliciousSiteProtectionSection {
            Section(
                header: Text(UserText.MaliciousSiteProtectionSettings.header),
                footer:
                    VStack(alignment: .leading, spacing: 10) {
                        Button(action: model.learnMoreAction) {
                            Text(UserText.MaliciousSiteProtectionSettings.footerLearnMore)
                                .foregroundColor(.blueBase)
                        }

                        Text(UserText.MaliciousSiteProtectionSettings.footerDisabledMessage)
                            .opacity(model.isMaliciousSiteProtectionOn ? 0 : 1)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
            ) {
                SettingsCellView(
                    label: UserText.MaliciousSiteProtectionSettings.toggleMessage,
                    accessory: .toggle(isOn: $model.isMaliciousSiteProtectionOn)
                )
            }
            .id(Constants.sectionIdentifier)
            .onChange(of: model.isMaliciousSiteProtectionOn) { isMaliciousSiteProtectionOn in
                if !isMaliciousSiteProtectionOn {
                    withAnimation {
                        proxy.scrollTo(Constants.sectionIdentifier, anchor: .top)
                    }
                }
            }
        } else {
            EmptyView()
        }
    }
}

#Preview {
    ScrollViewReader { proxy in
        SettingsMaliciousProtectionSectionView(
            proxy: proxy,
            model: MaliciousSiteProtectionSettingsViewModel(manager: MaliciousSiteProtectionPreferencesManager())
        )
    }
}
