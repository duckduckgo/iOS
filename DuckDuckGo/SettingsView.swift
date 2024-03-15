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
    
    @State private var shouldDisplayDeepLinkSheet: Bool = false
    @State private var shouldDisplayDeepLinkPush: Bool = false
    
    var body: some View {
        
        // Hidden navigationLink for programatic navigation
        if #available(iOS 15.0, *) {
            if let target = viewModel.deepLinkTarget {
                NavigationLink(destination: destinationView(for: target),
                               isActive: $shouldDisplayDeepLinkPush) {
                    EmptyView()
                }
            }
        }
        
        // Settings Sections
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
        
        // MARK: Deeplink Modifiers
        .sheet(isPresented: $shouldDisplayDeepLinkSheet,
               onDismiss: {
                   shouldDisplayDeepLinkSheet = false
               }) {
            if #available(iOS 15.0, *) {
                if let target = viewModel.deepLinkTarget {
                    destinationView(for: target)
                }
            }
        }
        .onChange(of: viewModel.deepLinkTarget) { target in
            guard target != nil else { return }

            // We need to wait for the view to render
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if viewModel.deepLinkTarget == .netP {
                    viewModel.presentLegacyView(.netP)
                } else {
                    switch target?.type {
                    case .sheet:
                        shouldDisplayDeepLinkSheet = true
                    case .push:
                        shouldDisplayDeepLinkPush = true
                    case .none:
                        break
                    }
                    
                }
            }
        }
    }
    
    // MARK: DeepLink Views
    @available(iOS 15.0, *)
    @ViewBuilder
    private func destinationView(for target: SettingsViewModel.SettingsDeepLinkSection) -> some View {
        switch target {
        case .dbp:
            SubscriptionPIRView()
        case .itr:
            SubscriptionITPView()
        case .subscriptionFlow:
            SubscriptionFlowView()
        case .subscriptionRestoreFlow:
            SubscriptionRestoreView()
        default:
            EmptyView()
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
