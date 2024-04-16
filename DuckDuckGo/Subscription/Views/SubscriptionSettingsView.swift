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

@available(iOS 15.0, *)
struct SubscriptionSettingsView: View {
        
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = SubscriptionSettingsViewModel()
    @EnvironmentObject var subscriptionNavigationCoordinator: SubscriptionNavigationCoordinator
    
    @State var isShowingStripeView = false
    @State var isShowingGoogleView = false
    @State var isShowingRemovalNotice = false
    @State var isShowingFAQView = false
    @State var isShowingRestoreView = false
    
    enum Constants {
        static let alertIcon = "Exclamation-Color-16"
    }
    
    var body: some View {
        optionsView
            .onFirstAppear {
                Pixel.fire(pixel: .privacyProSubscriptionSettings, debounce: 1)
            }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: -
    
    private var headerSection: some View {
        Section {
            let active = viewModel.state.subscriptionInfo?.isActive ?? false
            VStack(alignment: .center, spacing: 7) {
                Image("Privacy-Pro-96x96")
                Text(UserText.subscriptionTitle).daxTitle2()
                if active {
                        Text(viewModel.state.subscriptionType).daxHeadline()
                }
                HStack {
                    if !active { Image(Constants.alertIcon) }
                    Text(viewModel.state.subscriptionDetails)
                        .daxSubheadRegular()
                        .foregroundColor(Color(designSystemColor: .textSecondary))
                }
            }
        }
        .listRowBackground(Color.clear)
        .frame(maxWidth: .infinity, alignment: .center)
        
    }
    
    private var manageSection: some View {
        Section(header: Text(UserText.subscriptionManageTitle)) {
            SettingsCustomCell(content: {
                let active = viewModel.state.subscriptionInfo?.isActive ?? false
                
                if active {
                    Text(UserText.subscriptionChangePlan)
                        .daxBodyRegular()
                        .foregroundColor(Color.init(designSystemColor: .accent))
                } else {
                    Text(UserText.subscriptionRestoreNotFoundPlans)
                        .daxBodyRegular()
                        .foregroundColor(Color.init(designSystemColor: .accent))
                }
            },
                               action: {
                Pixel.fire(pixel: .privacyProSubscriptionManagementPlanBilling, debounce: 1)
                Task { viewModel.manageSubscription() }
                                },
                               isButton: true)
                .sheet(isPresented: $isShowingStripeView) {
                    if let stripeViewModel = viewModel.state.stripeViewModel {
                        SubscriptionExternalLinkView(viewModel: stripeViewModel, title: UserText.subscriptionManagePlan)
                    }
                }
        }
    }
    
    private var devicesSection: some View {
        Section(header: Text(UserText.subscriptionManageDevices)) {
            
            NavigationLink(destination: SubscriptionContainerView(currentView: .restore)
                                            .environmentObject(subscriptionNavigationCoordinator),
                           isActive: $isShowingRestoreView) {
                SettingsCustomCell(content: {
                    Text(UserText.subscriptionAddDeviceButton)
                        .daxBodyRegular()
                })
            }.isDetailLink(false)

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
            
            
            SettingsCustomCell(content: {
                Text(UserText.subscriptionFAQ)
                    .daxBodyRegular()
                    .foregroundColor(Color(designSystemColor: .accent))
            },
                               action: { viewModel.displayFAQView(true) },
                               disclosureIndicator: false,
                               isButton: true)

        }
    }
    
    @ViewBuilder
    private var optionsView: some View {
        NavigationLink(destination: SubscriptionGoogleView(),
                       isActive: $isShowingGoogleView) {
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
        .onChange(of: viewModel.state.isShowingGoogleView) { value in
            isShowingGoogleView = value
        }
        .onChange(of: isShowingGoogleView) { value in
            viewModel.displayGoogleView(value)
        }
        
        // Stripe Binding
        .onChange(of: viewModel.state.isShowingStripeView) { value in
            isShowingStripeView = value
        }
        .onChange(of: isShowingStripeView) { value in
            viewModel.displayStripeView(value)
        }
        
        // Removal Notice
        .onChange(of: viewModel.state.isShowingRemovalNotice) { value in
            isShowingRemovalNotice = value
        }
        .onChange(of: isShowingRemovalNotice) { value in
            viewModel.displayRemovalNotice(value)
        }
        
        // Removal Notice
        .onChange(of: viewModel.state.isShowingFAQView) { value in
            isShowingFAQView = value
        }
        .onChange(of: isShowingFAQView) { value in
            viewModel.displayFAQView(value)
        }
        
        .onReceive(subscriptionNavigationCoordinator.$shouldPopToSubscriptionSettings) { shouldDismiss in
            if shouldDismiss {
                isShowingRestoreView = false
            }
        }

        
        // Remove subscription
        .alert(isPresented: $isShowingRemovalNotice) {
            Alert(
                title: Text(UserText.subscriptionRemoveFromDeviceConfirmTitle),
                message: Text(UserText.subscriptionRemoveFromDeviceConfirmText),
                primaryButton: .cancel(Text(UserText.subscriptionRemoveCancel)) {
                },
                secondaryButton: .destructive(Text(UserText.subscriptionRemove)) {
                    Pixel.fire(pixel: .privacyProSubscriptionManagementRemoval)
                    viewModel.removeSubscription()
                    dismiss()
                }
            )
        }
        
        .sheet(isPresented: $isShowingFAQView, content: {
            SubscriptionExternalLinkView(viewModel: viewModel.state.FAQViewModel, title: UserText.subscriptionFAQ)
        })
        
        .onFirstAppear {
            viewModel.onFirstAppear()
        }
    }
    
    @ViewBuilder
    private var stripeView: some View {
        if let stripeViewModel = viewModel.state.stripeViewModel {
            SubscriptionExternalLinkView(viewModel: stripeViewModel)
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
