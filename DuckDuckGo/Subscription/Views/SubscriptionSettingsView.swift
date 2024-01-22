//
//  SubscriptionSettingsView.swift
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

import Foundation
import SwiftUI
import DesignResourcesKit

class SceneEnvironment: ObservableObject {
    weak var windowScene: UIWindowScene?
}

#if SUBSCRIPTION
@available(iOS 15.0, *)
struct SubscriptionSettingsView: View {
    
    @ObservedObject var viewModel: SubscriptionSettingsViewModel
    @Environment(\.presentationMode) var presentationMode
    @StateObject var sceneEnvironment = SceneEnvironment()
    @State private var isActivatingSubscription = false
    
    var body: some View {
            List {
                Section(header: Text(viewModel.subscriptionDetails)
                                    .lineLimit(nil)
                                    .daxBodyRegular()
                                    .fixedSize(horizontal: false, vertical: true)) {
                    EmptyView()
                    .frame(height: 0)
                    .hidden()
                }.textCase(nil)
                Section(header: Text(UserText.subscriptionManageDevices)) {
                    
                    NavigationLink(destination: SubscriptionRestoreView(viewModel: SubscriptionRestoreViewModel(isAddingDevice: true), isActivatingSubscription: $isActivatingSubscription)) {
                        SettingsCustomCell(content: {
                            Text(UserText.subscriptionAddDeviceButton)
                                .daxBodyRegular()
                                .foregroundColor(Color.init(designSystemColor: .accent))
                        })
                    }
                    
                    SettingsCustomCell(content: {
                        Text(UserText.subscriptionRemoveFromDevice)
                                .daxBodyRegular()
                                .foregroundColor(Color.init(designSystemColor: .accent))},
                                       action: { viewModel.shouldDisplayRemovalNotice.toggle() },
                                       isButton: true)
                    
                }
                Section(header: Text(UserText.subscriptionManagePlan)) {
                    SettingsCustomCell(content: {
                        Text(UserText.subscriptionChangePlan)
                            .daxBodyRegular()
                    },
                                       action: { Task { viewModel.manageSubscription() } },
                                       isButton: true)
                }
                Section(header: Text(UserText.subscriptionHelpAndSupport),
                        footer: Text(UserText.subscriptionFAQFooter)) {
                    NavigationLink(destination: Text(UserText.subscriptionFAQ)) {
                        SettingsCustomCell(content: {
                            Text(UserText.subscriptionFAQ)
                                .daxBodyRegular()
                        })
                    }
                }
            }
            .navigationTitle(UserText.settingsPProManageSubscription)
            .applyInsetGroupedListStyle()
            
            // Remove subscription
            .alert(isPresented: $viewModel.shouldDisplayRemovalNotice) {
                Alert(
                    title: Text(UserText.subscriptionRemoveFromDeviceConfirmTitle),
                    message: Text(UserText.subscriptionRemoveFromDeviceConfirmText),
                    primaryButton: .cancel(Text(UserText.subscriptionRemoveCancel)) {
                    },
                    secondaryButton: .destructive(Text(UserText.subscriptionRemove)) {
                        viewModel.removeSubscription()
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
}
#endif
