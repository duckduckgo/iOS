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
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = SubscriptionSettingsViewModel()
    @StateObject var sceneEnvironment = SceneEnvironment()
    
    @ViewBuilder
    private var optionsView: some View {
        List {
            Section {
                VStack(alignment: .center, spacing: 7) {
                    Image("Privacy-Pro-96x96")
                    Text(UserText.subscriptionTitle).daxTitle2()
                    Text(viewModel.subscriptionType).daxHeadline()
                    Text(viewModel.subscriptionDetails)
                        .daxSubheadRegular()
                        .foregroundColor(Color(designSystemColor: .textSecondary))
                }
            }
            .listRowBackground(Color.clear)
            .frame(maxWidth: .infinity, alignment: .center)
            
            Section(header: Text(UserText.subscriptionManageTitle)) {
                SettingsCustomCell(content: {
                    Text(UserText.subscriptionChangePlan)
                        .daxBodyRegular()
                        .foregroundColor(Color.init(designSystemColor: .accent))
                },
                                   action: { Task { viewModel.manageSubscription() } },
                                   isButton: true)
            }
            
            Section(header: Text(UserText.subscriptionManageDevices)) {
                
                NavigationLink(destination: SubscriptionRestoreView()) {
                    SettingsCustomCell(content: {
                        Text(UserText.subscriptionAddDeviceButton)
                            .daxBodyRegular()
                    })
                }
                
                SettingsCustomCell(content: {
                    Text(UserText.subscriptionRemoveFromDevice)
                            .daxBodyRegular()
                            .foregroundColor(Color.init(designSystemColor: .accent))},
                                   action: { viewModel.shouldDisplayRemovalNotice.toggle() },
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
            
            NavigationLink(destination: SubscriptionGoogleView(), isActive: $viewModel.shouldDisplayGoogleView) {
                EmptyView()
            }
        }
        .navigationTitle(UserText.settingsPProManageSubscription)
        .applyInsetGroupedListStyle()
        
        .onChange(of: viewModel.shouldDismissView) { value in
            if value {
                dismiss()
            }
        }
        
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
        
        .onAppear {
            viewModel.fetchAndUpdateSubscriptionDetails()
        }
    }
    
    var body: some View {
        Group {
            if #available(iOS 16.0, *) {
                optionsView
                    .scrollDisabled(true)
            } else {
                optionsView
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        
        
    }
        
}
#endif


#if SUBSCRIPTION && DEBUG
@available(iOS 15.0, *)

struct SubscriptionSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SubscriptionSettingsView().navigationBarTitleDisplayMode(.inline)
        }
    }
}
#endif
