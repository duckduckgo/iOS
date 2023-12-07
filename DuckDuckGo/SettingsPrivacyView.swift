// TODO: Remove transition animation if showing a selected account//
//  GeneralSection.swift
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
    @EnvironmentObject var viewProvider: SettingsViewProvider
    @State var isPresentingGPCView = false

    var body: some View {
         Section(header: Text("Privacy"),
                 footer: Text("If Touch ID, Face ID or a system passcode is set, you'll be requested to unlock the app when opening.")) {
             
             NavigationLink(destination: viewProvider.doNotSell, isActive: $isPresentingGPCView) {
                 SettingsCellView(label: "Global Privacy Control (GPC)",
                                  accesory: .rightDetail(viewModel.state.general.sendDoNotSell
                                                         ? UserText.doNotSellEnabled
                                                         : UserText.doNotSellDisabled))
             }
             
             NavigationLink(destination: viewProvider.autoConsent) {
                 SettingsCellView(label: "Manage Cookie Popups",
                                  accesory: .rightDetail(viewModel.state.general.autoconsentEnabled
                                                         ? UserText.autoconsentEnabled
                                                         : UserText.autoconsentDisabled))
             }
             
             NavigationLink(destination: viewProvider.unprotectedSites) {
                 SettingsCellView(label: "Unprotected SItes")
             }
             
             NavigationLink(destination: viewProvider.fireproofSites) {
                 SettingsCellView(label: "Fireproof SItes")
             }
             
             NavigationLink(destination: viewProvider.autoclearData) {
                 SettingsCellView(label: "Automatically Clear Data",
                                  accesory: .rightDetail(viewModel.state.general.autoclearDataEnabled
                                                         ? UserText.autoClearAccessoryOn
                                                         : UserText.autoClearAccessoryOff))
             }
             
             SettingsCellView(label: "Application Lock", accesory: .toggle(isOn: viewModel.applicationLockBinding))
             
         }
        
         .onChange(of: isPresentingGPCView) { isActive in
             if isActive {
                 viewModel.gpcViewPresentationAction()
             }
         }

        
    }
}
