//
//  SettingsView.swift
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

struct SettingsView: View {
    
    @StateObject var viewModel: SettingsViewModel
    @StateObject var viewProvider: SettingsViewProvider
    
    var body: some View {
        List {
            SettingsGeneralView()
            SettingsSyncView()
            SettingsLoginsView()
            SettingsAppeareanceView()
            SettingsPrivacyView()
        }
        .navigationBarTitle(UserText.settingsTitle, displayMode: .inline)
        .navigationBarItems(trailing: Button(UserText.navigationTitleDone) {
        })
        .environmentObject(viewModel)
        .environmentObject(viewProvider)
        
        .onAppear {
            viewModel.initializeState()
        }
    }
    
}
            
            
            /*
             Section(header: Text("Privacy"),
                     footer: Text("If Touch ID, Face ID or a system passcode is set, you'll be requested to unlock the app when opening.")) {
                 RightDetailCell(label: "Global Privacy Control (GMC)", value: "Enabled")
                 RightDetailCell(label: "Manage Cookie Popups", value: "Disabled")
                 PlainCell(label: "Set as Default Browser")
                 PlainCell(label: "Fireproof Sites")
                 RightDetailCell(label: "Automatically Clear Data", value: "Off")
                 ToggleCell(label: "Application Lock", value: false)
             }
             
             
            Section(header: Text("Customize"),
                    footer: Text("Disable to prevent links from automatically opening in other installed apps.")) {
                PlainCell(label: "Keyboard")
                ToggleCell(label: "Autocomplete Suggestions", value: false)
                ToggleCell(label: "Private Voice Search", value: false)
                ToggleCell(label: "Long Press Previews", value: false)
                ToggleCell(label: "Open Links in Associated Apps", value: false)
            }
            Section(header: Text("More from DuckDuckGo")) {
                SubtitleCell(label: "Email Protection", subtitle: "Block Email Trackers and hide your address")
                SubtitleCell(label: "DuckDuckGo Mac App", subtitle: "Browse privaly with our app for Mac")
                SubtitleCell(label: "DuckDuckGo Windows App", subtitle: "Browse privaly with our app for Windows")
                SubtitleCell(label: "Network Protection", subtitle: "Join the private waitlist")
            }
            Section(header: Text("About")) {
                PlainCell(label: "About DuckDuckGo")
                RightDetailCell(label: "Version", value: "7.99.0.2")
                PlainCell(label: "Share Feedback")
            }
            Section {
                PlainCell(label: "Debug Menu")
            }
             */


/*
struct SettingsAppeareanceView: View {
    
    @EnvironmentObject var viewModel: SettingsViewModel
    
    var body: some View {
        Section(header: Text("Appeareance")) {
            RightDetailCell(label: "Theme",
                            value: "System",
                            action: viewModel.showTheme)
            ImageCell(label: "App Icon",
                      image: Image(systemName: "photo"),
                      action: viewModel.selectIcon)
            RightDetailCell(label: "Fire Button Animation",
                            value: "Inferno",
                            action: viewModel.selectFireAnimation)
            RightDetailCell(label: "Text Size",
                            value: "100%",
                            action: viewModel.selectTextSize)
            
            RightDetailCell(label: "Address Bar Position",
                            value: "Top",
                            action: viewModel.selectBarPosition)
        }
    }
}
*/
