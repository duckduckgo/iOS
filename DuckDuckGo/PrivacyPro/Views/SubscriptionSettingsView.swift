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

@available(iOS 15.0, *)
struct SubscriptionSettingsView: View {
    
    @ObservedObject var viewModel: SubscriptionSettingsViewModel
    @Environment(\.presentationMode) var presentationMode
    
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
                Section(header: Text(UserText.privacyProManageDevices)) {
                    
                    SettingsCustomCell(content: {
                        Text(UserText.privacyProAddDevice)
                            .daxBodyRegular()
                            .foregroundColor(Color.init(designSystemColor: .accent))
                    },
                                       action: {},
                                       asLink: true)
                    
                    SettingsCustomCell(content: {
                        Text(UserText.privacyProRemoveFromDevice)
                            .daxBodyRegular()
                            .foregroundColor(Color.init(designSystemColor: .accent))},
                                       action: {
                        viewModel.shouldDisplayRemovalNotice.toggle()
                        print(viewModel.shouldDisplayRemovalNotice)
                    },
                                       asLink: true)
                    
                }
                Section(header: Text(UserText.privacyProManagePlan)) {
                    SettingsCustomCell(content: {
                        Text(UserText.privacyProChangePlan)
                            .daxBodyRegular()
                    })
                }
                Section(header: Text(UserText.privacyProHelpAndSupport),
                        footer: Text(UserText.privacyProFAQFooter)) {
                    SettingsCustomCell(content: {
                        Text(UserText.privacyProFAQ)
                            .daxBodyRegular()
                    })
                }
            }
            .navigationTitle(UserText.settingsPProManageSubscription)
            
            // Remove subscription
            .alert(isPresented: $viewModel.shouldDisplayRemovalNotice) {
                Alert(
                    title: Text(UserText.privacyProRemoveFromDeviceConfirmTitle),
                    message: Text(UserText.privacyProRemoveFromDeviceConfirmText),
                    primaryButton: .cancel(Text(UserText.privacyProRemoveSubscriptionCancel)) {
                    },
                    secondaryButton: .destructive(Text(UserText.privacyProRemoveSubscription)) {
                        viewModel.removeSubscription()
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
}
