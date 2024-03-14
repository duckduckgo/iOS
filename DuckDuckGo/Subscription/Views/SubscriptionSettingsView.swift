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
import Core

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
    
    @State var shouldDisplayStripeView = false
    @State var shouldDisplayGoogleView = false
    @State var shouldDisplayRemovalNotice = false
    
    var body: some View {
        optionsView
            .onAppear(perform: {
                Pixel.fire(pixel: .privacyProSubscriptionSettings, debounce: 1)
        })
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: -
    
    private var headerSection: some View {
        Section {
            VStack(alignment: .center, spacing: 7) {
                Image("Privacy-Pro-96x96")
                Text(UserText.subscriptionTitle).daxTitle2()
                Text(viewModel.state.subscriptionType).daxHeadline()
                Text(viewModel.state.subscriptionDetails)
                    .daxSubheadRegular()
                    .foregroundColor(Color(designSystemColor: .textSecondary))
            }
        }
        .listRowBackground(Color.clear)
        .frame(maxWidth: .infinity, alignment: .center)
        
    }
    
    private var manageSection: some View {
        Section(header: Text(UserText.subscriptionManageTitle)) {
            SettingsCustomCell(content: {
                Text(UserText.subscriptionChangePlan)
                    .daxBodyRegular()
                    .foregroundColor(Color.init(designSystemColor: .accent))
            },
                               action: {
                Pixel.fire(pixel: .privacyProSubscriptionManagementPlanBilling, debounce: 1)
                Task { viewModel.manageSubscription() }
                                },
                               isButton: true)
                .sheet(isPresented: $shouldDisplayStripeView) {
                    if let stripeViewModel = viewModel.state.stripeViewModel {
                        SubscriptionExternalLinkView(viewModel: stripeViewModel, title: UserText.subscriptionManagePlan)
                    }
                }
        }
    }
    
    private var devicesSection: some View {
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
                               action: { viewModel.displayRemovalNotice(true) },
                               isButton: true)
            
        }
    }
    
    @ViewBuilder var helpSection: some View {
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
    
    @ViewBuilder
    private var optionsView: some View {
        NavigationLink(destination: SubscriptionGoogleView(),
                       isActive: $shouldDisplayGoogleView) {
            EmptyView()
        }
        
        List {
            headerSection
            manageSection
            devicesSection
            helpSection
            
        }
        .navigationTitle(UserText.settingsPProManageSubscription)
        .applyInsetGroupedListStyle()
        
        .onChange(of: viewModel.state.shouldDismissView) { value in
            if value {
                dismiss()
            }
        }
        
        // Google Binding
        .onChange(of: viewModel.state.shouldDisplayGoogleView) { value in
            shouldDisplayGoogleView = value
        }
        .onChange(of: shouldDisplayGoogleView) { value in
            viewModel.displayGoogleView(value)
        }
        
        // Stripe Binding
        .onChange(of: viewModel.state.shouldDisplayStripeView) { value in
            shouldDisplayStripeView = value
        }
        .onChange(of: shouldDisplayStripeView) { value in
            viewModel.displayStripeView(value)
        }
        
        // Removal Notice
        .onChange(of: viewModel.state.shouldDisplayRemovalNotice) { value in
            shouldDisplayRemovalNotice = value
        }
        .onChange(of: shouldDisplayRemovalNotice) { value in
            viewModel.displayRemovalNotice(value)
        }

        
        // Remove subscription
        .alert(isPresented: $shouldDisplayRemovalNotice) {
            Alert(
                title: Text(UserText.subscriptionRemoveFromDeviceConfirmTitle),
                message: Text(UserText.subscriptionRemoveFromDeviceConfirmText),
                primaryButton: .cancel(Text(UserText.subscriptionRemoveCancel)) {
                },
                secondaryButton: .destructive(Text(UserText.subscriptionRemove)) {
                    Pixel.fire(pixel: .privacyProSubscriptionManagementRemoval)
                    viewModel.removeSubscription()
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        
        .onAppear {
            viewModel.fetchAndUpdateSubscriptionDetails()
        }
    }
    
    @ViewBuilder
    private var stripeView: some View {
        if let stripeViewModel = viewModel.state.stripeViewModel {
            SubscriptionExternalLinkView(viewModel: stripeViewModel)
        }
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

// Commented out because CI fails if a SwiftUI preview is enabled https://app.asana.com/0/414709148257752/1206774081310425/f
// @available(iOS 15.0, *)
// struct SubscriptionSettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SubscriptionSettingsView()
//    }
// }

#endif
