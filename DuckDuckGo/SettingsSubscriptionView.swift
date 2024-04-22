//
//  SettingsSubscriptionView.swift
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

import Core
import Subscription
import SwiftUI
import UIKit

@available(iOS 15.0, *)
struct SettingsSubscriptionView: View {
    
    @EnvironmentObject var viewModel: SettingsViewModel
    @EnvironmentObject var subscriptionNavigationCoordinator: SubscriptionNavigationCoordinator
    @State var isShowingDBP = false
    @State var isShowingITP = false
    @State var isShowingRestoreFlow = false
    @State var isShowingSubscribeFlow = false
    @State var isShowingGoogleView = false
    @State var isShowingStripeView = false
    @State var isShowingSubscriptionError = false
    
    enum Constants {
        static let purchaseDescriptionPadding = 5.0
        static let topCellPadding = 3.0
        static let noEntitlementsIconWidth = 20.0
        static let navigationDelay = 0.3
        static let infoIcon = "info-16"
        static let alertIcon = "Exclamation-Color-16"
    }

    private var subscriptionDescriptionView: some View {
        VStack(alignment: .leading) {
            Text(UserText.settingsPProSubscribe).daxBodyRegular()
            Group {
                Text(UserText.settingsPProDescription).daxFootnoteRegular().padding(.bottom, Constants.purchaseDescriptionPadding)
                Text(UserText.settingsPProFeatures).daxFootnoteRegular()
            }.foregroundColor(Color(designSystemColor: .textSecondary))
        }
    }
    
    @ViewBuilder
    private var restorePurchaseView: some View {
        let text = !viewModel.state.subscription.isRestoring ? UserText.subscriptionActivateAppleIDButton : UserText.subscriptionRestoringTitle
        SettingsCustomCell(content: {
            Text(text)
                .daxBodyRegular()
                .foregroundColor(Color.init(designSystemColor: .accent)) },
                           action: {
                                Task { await viewModel.restoreAccountPurchase() }
                            },
                           isButton: !viewModel.state.subscription.isRestoring )
        .alert(isPresented: $isShowingSubscriptionError) {
            Alert(
                title: Text(UserText.subscriptionAppStoreErrorTitle),
                message: Text(UserText.subscriptionAppStoreErrorMessage),
                dismissButton: .default(Text(UserText.actionOK)) {}
            )
        }
    }
    
    private var manageSubscriptionView: some View {
        Text(UserText.settingsPProManageSubscription)
            .daxBodyRegular()
    }
    
    @ViewBuilder
    private var purchaseSubscriptionView: some View {

        Group {
            SettingsCustomCell(content: { subscriptionDescriptionView })
            
            let subscribeView = SubscriptionContainerView(currentView: .subscribe)
                .navigationViewStyle(.stack)
                .environmentObject(subscriptionNavigationCoordinator)
            let restoreView = SubscriptionContainerView(currentView: .restore)
                .navigationViewStyle(.stack)
                .environmentObject(subscriptionNavigationCoordinator)
                .onFirstAppear {
                    Pixel.fire(pixel: .privacyProRestorePurchaseClick)
                }

            NavigationLink(destination: subscribeView,
                           isActive: $isShowingSubscribeFlow,
                           label: { SettingsCellView(label: UserText.settingsPProLearnMore ) })
            
            NavigationLink(destination: restoreView,
                           isActive: $isShowingRestoreFlow,
                           label: { SettingsCellView(label: UserText.settingsPProIHaveASubscription ) })
        }
    }

    @ViewBuilder
    private var subscriptionExpiredView: some View {
        Group {
            SettingsCustomCell(content: {
                HStack(alignment: .top) {
                    Image(Constants.alertIcon)
                        .frame(width: Constants.noEntitlementsIconWidth)
                        .padding(.top, Constants.topCellPadding)
                    VStack(alignment: .leading) {
                        Text(UserText.settingsPProSubscriptionExpiredTitle).daxBodyRegular()
                        Text(UserText.settingsPProSubscribeAgain).daxFootnoteRegular()
                            .padding(.bottom, Constants.purchaseDescriptionPadding)
                    }.foregroundColor(Color(designSystemColor: .textSecondary))
                }
            })
                        
            let subscribeView = SubscriptionContainerView(currentView: .subscribe)
                .navigationViewStyle(.stack)
                .environmentObject(subscriptionNavigationCoordinator)
            NavigationLink(
                destination: subscribeView,
                isActive: $isShowingSubscribeFlow,
                label: { SettingsCellView(label: UserText.subscriptionRestoreNotFoundPlans) })
            
            // Renew Subscription (Expired)
            let settingsView = SubscriptionSettingsView(viewPlans: {
                    isShowingSubscribeFlow = true
            })
                .environmentObject(subscriptionNavigationCoordinator)
            NavigationLink(destination: settingsView) {
                SettingsCustomCell(content: { manageSubscriptionView })
            }
        }
    }
    
    @ViewBuilder
    private var subscriptionManageCell: some View {
        Group {
            switch viewModel.state.subscription.platform {
            case .apple:
                
                let subscribeView = SubscriptionContainerView(currentView: .subscribe)
                    .navigationViewStyle(.stack)
                    .environmentObject(subscriptionNavigationCoordinator)
                NavigationLink(
                    destination: subscribeView,
                    isActive: $isShowingSubscribeFlow,
                    label: { SettingsCellView(label: UserText.subscriptionRestoreNotFoundPlans) })
            
            case .google:
                NavigationLink(
                    destination: SubscriptionGoogleView(),
                    isActive: $isShowingGoogleView,
                    label: { SettingsCellView(label: UserText.subscriptionRestoreNotFoundPlans) })
                
            case .stripe:
                SettingsCustomCell(content: { Text(UserText.subscriptionRestoreNotFoundPlans) },
                                   action: { Task { await viewModel.manageStripeSubscription() } },
                                   isButton: true).foregroundColor(Color(designSystemColor: .accent))
                    .sheet(isPresented: $isShowingStripeView, content: {
                        if let stripeViewModel = viewModel.subscriptionStripeViewModel {
                            SubscriptionExternalLinkView(viewModel: stripeViewModel, title: UserText.subscriptionManagePlan)
                        }
                    })
                    
            
            default:
                EmptyView()
            }
        }
    }
    
    @ViewBuilder
    private var noEntitlementsAvailableView: some View {
        Group {
            SettingsCustomCell(content: {
                HStack(alignment: .top) {
                    Image(Constants.infoIcon)
                        .frame(width: Constants.noEntitlementsIconWidth)
                        .padding(.top, Constants.topCellPadding)
                    VStack(alignment: .leading) {
                        Text(UserText.settingsPProActivationPendingTitle).daxBodyRegular()
                        Text(UserText.settingsPProActivationPendingDescription).daxFootnoteRegular()
                            .padding(.bottom, Constants.purchaseDescriptionPadding)
                    }.foregroundColor(Color(designSystemColor: .textSecondary))
                }
            })
            restorePurchaseView
        }
    }
    
    @ViewBuilder
    private var subscriptionDetailsView: some View {
        
        if viewModel.state.subscription.entitlements.contains(.networkProtection) {
            SettingsCellView(
                label: UserText.settingsPProVPNTitle,
                subtitle: viewModel.state.networkProtection.status != ""
                ? viewModel.state.networkProtection.status : nil,
                action: { viewModel.presentLegacyView(.netP) },
                disclosureIndicator: true,
                isButton: true)
        }
        
        if viewModel.state.subscription.entitlements.contains(.dataBrokerProtection) {
            NavigationLink(
                destination: SubscriptionPIRView(),
                isActive: $isShowingDBP,
                label: {
                    SettingsCellView(
                        label: UserText.settingsPProDBPTitle,
                        subtitle: UserText.settingsPProDBPSubTitle)
                })
            
        }
        
        if viewModel.state.subscription.entitlements.contains(.identityTheftRestoration) {
            NavigationLink(
                destination: SubscriptionITPView(),
                isActive: $isShowingITP,
                label: {
                    SettingsCellView(
                        label: UserText.settingsPProITRTitle,
                        subtitle: UserText.settingsPProITRSubTitle)
                })
            
        }
        
        NavigationLink(
            destination: SubscriptionSettingsView().environmentObject(subscriptionNavigationCoordinator)
        ) {
            SettingsCustomCell(content: { manageSubscriptionView })
        }
        
    }
    
    
    @ViewBuilder
    private var stripeView: some View {
        if let stripeViewModel = viewModel.subscriptionStripeViewModel {
            SubscriptionExternalLinkView(viewModel: stripeViewModel)
        }
    }
    
    var body: some View {
        if viewModel.state.subscription.enabled && viewModel.state.subscription.canPurchase {
            
            Section(header: Text(UserText.settingsPProSection)) {
                                
                switch (
                    viewModel.state.subscription.isSignedIn,
                    viewModel.state.subscription.hasActiveSubscription,
                    viewModel.state.subscription.entitlements.isEmpty
                ) {
                    
                    // Signed In, Subscription Expired
                case (true, false, _):
                    subscriptionExpiredView
                    
                    // Signed in, Subscription Active, Valid entitlements
                case (true, true, false):
                    subscriptionDetailsView  // View for valid subscription details
                    
                    // Signed in, Subscription Active, Empty Entitlements
                case (true, true, true):
                    noEntitlementsAvailableView  // View for no entitlements
                    
                    // Signed out
                case (false, _, _):
                    purchaseSubscriptionView  // View for signing up or purchasing a subscription
                }
            }
            
            .onChange(of: viewModel.state.subscription.shouldDisplayRestoreSubscriptionError) { value in
                if value {
                    isShowingSubscriptionError = true
                }
            }
            
            // Stripe Binding
            .onChange(of: viewModel.state.subscription.isShowingStripeView) { value in
                isShowingStripeView = value
            }
            .onChange(of: isShowingStripeView) { value in
                viewModel.displayStripeView(value)
            }
            
            .onReceive(subscriptionNavigationCoordinator.$shouldPopToAppSettings) { shouldDismiss in
                if shouldDismiss {
                    isShowingRestoreFlow = false
                    isShowingSubscribeFlow = false
                }
            }
            
        }
    }
}
