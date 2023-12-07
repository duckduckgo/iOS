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
         Section(header: Text("Privacy"),
                 footer: Text("If Touch ID, Face ID or a system passcode is set, you'll be requested to unlock the app when opening.")) {
             
             SettingsCellView(label: "Global Privacy Control (GPC)",
                          action: { viewModel.presentView(.gpc) },
                          accesory: .rightDetail(viewModel.state.general.sendDoNotSell
                                                 ? UserText.doNotSellEnabled
                                                 : UserText.doNotSellDisabled),
                          asLink: true,
                          disclosureIndicator: true)

             SettingsCellView(label: "Manage Cookie Popups",
                              action: { viewModel.presentView(.autoconsent) },
                              accesory: .rightDetail(viewModel.state.general.autoconsentEnabled
                                                     ? UserText.autoconsentEnabled
                                                     : UserText.autoconsentDisabled),
                              asLink: true,
                              disclosureIndicator: true)

             SettingsCellView(label: "Unprotected SItes",
                              action: { viewModel.presentView(.unprotectedSites) },
                              asLink: true,
                              disclosureIndicator: true)
             
             SettingsCellView(label: "Fireproof Sites",
                              action: { viewModel.presentView(.fireproofSites) },
                              asLink: true,
                              disclosureIndicator: true)
             
             SettingsCellView(label: "Automatically Clear Data",
                              action: { viewModel.presentView(.autoclearData) },
                              accesory: .rightDetail(viewModel.state.general.autoclearDataEnabled
                                                     ? UserText.autoClearAccessoryOn
                                                     : UserText.autoClearAccessoryOff),
                              asLink: true,
                              disclosureIndicator: true)
             
             SettingsCellView(label: "Application Lock", accesory: .toggle(isOn: viewModel.applicationLockBinding))
             
         }
    }
}
