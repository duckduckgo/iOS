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
import DesignResourcesKit

struct SettingsView: View {
    
    @StateObject var viewModel: SettingsViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        List {
            SettingsGeneralView()
            SettingsSyncView()
            SettingsLoginsView()
            SettingsAppeareanceView()
            SettingsPrivacyView()
#if SUBSCRIPTION
            if #available(iOS 15, *) {
                SettingsSubscriptionView()
            }
#endif
            SettingsCustomizeView()
            SettingsMoreView()
            SettingsAboutView()
            SettingsDebugView()
                        
        }
        .navigationBarTitle(UserText.settingsTitle, displayMode: .inline)
        .navigationBarItems(trailing: Button(UserText.navigationTitleDone) {
            viewModel.onRequestDismissSettings?()
        })
        .accentColor(Color(designSystemColor: .textPrimary))
        .environmentObject(viewModel)
        .conditionalInsetGroupedListStyle()
        .onAppear {
            viewModel.onAppear()
        }
    }
    
}

struct InsetGroupedListStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 15, *) {
            return AnyView(content.applyInsetGroupedListStyle())
        } else {
            return AnyView(content)
        }
    }
}
        
extension View {
    func conditionalInsetGroupedListStyle() -> some View {
        self.modifier(InsetGroupedListStyleModifier())
    }
}
