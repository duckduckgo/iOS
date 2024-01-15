//
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

struct SettingsPrivacyView: View {
        
    @EnvironmentObject var viewModel: SettingsViewModel

    var body: some View {
        Section(header: Text(UserText.settingsPrivacySection),
                footer: Text(UserText.settingsAutoLockDescription)) {
             
            SettingsCellView(label: UserText.settingsGPC,
                          action: { viewModel.presentLegacyView(.gpc) },
                          accesory: .rightDetail(viewModel.state.sendDoNotSell
                                                 ? UserText.doNotSellEnabled
                                                 : UserText.doNotSellDisabled),
                          asLink: true,
                          disclosureIndicator: true)

            SettingsCellView(label: UserText.settingsCookiePopups,
                              action: { viewModel.presentLegacyView(.autoconsent) },
                              accesory: .rightDetail(viewModel.state.autoconsentEnabled
                                                     ? UserText.autoconsentEnabled
                                                     : UserText.autoconsentDisabled),
                              asLink: true,
                              disclosureIndicator: true)

            SettingsCellView(label: UserText.settingsUnprotectedSites,
                              action: { viewModel.presentLegacyView(.unprotectedSites) },
                              asLink: true,
                              disclosureIndicator: true)
             
            SettingsCellView(label: UserText.settingsFireproofSites,
                              action: { viewModel.presentLegacyView(.fireproofSites) },
                              asLink: true,
                              disclosureIndicator: true)
             
            SettingsCellView(label: UserText.settingsClearData,
                              action: { viewModel.presentLegacyView(.autoclearData) },
                              accesory: .rightDetail(viewModel.state.autoclearDataEnabled
                                                     ? UserText.autoClearAccessoryOn
                                                     : UserText.autoClearAccessoryOff),
                              asLink: true,
                              disclosureIndicator: true)
             
            SettingsCellView(label: UserText.settingsAutolock, accesory: .toggle(isOn: viewModel.applicationLockBinding))
             
        }
    }
}
