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

import SwiftUI
import UIKit

#if SUBSCRIPTION
import Subscription
@available(iOS 15.0, *)
struct SettingsSubscriptionView: View {
    
    @EnvironmentObject var viewModel: SettingsViewModel
    @StateObject var subscriptionFlowViewModel =  SubscriptionFlowViewModel()
    @StateObject var subscriptionRestoreViewModel =  SubscriptionRestoreViewModel()
    @State var isShowingSubscriptionFlow = false
    @State var isShowingSubscriptionRestoreFlow = false
    @State var isShowingDBP = false
    @State var isShowingITP = false
    
    enum Constants {
        static let purchaseDescriptionPadding = 5.0
        static let topCellPadding = 3.0
        static let noEntitlementsIconWidth = 20.0
        static let navigationDelay = 0.3
        static let infoIcon = "info-16"
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
    
    private var learnMoreView: some View {
        Text(UserText.settingsPProLearnMore)
            .daxBodyRegular()
            .foregroundColor(Color.init(designSystemColor: .accent))
    }
    
    private var iHaveASubscriptionView: some View {
        Text(UserText.settingsPProIHaveASubscription)
            .daxBodyRegular()
            .foregroundColor(Color.init(designSystemColor: .accent))
    }
    
    @ViewBuilder
    private var restorePurchaseView: some View {
        let text = !viewModel.isRestoringSubscription ? UserText.subscriptionActivateAppleIDButton : UserText.subscriptionRestoringTitle
        SettingsCustomCell(content: {
            Text(text)
                .daxBodyRegular()
                .foregroundColor(Color.init(designSystemColor: .accent)) },
                           action: {
                                Task { await viewModel.restoreAccountPurchase() }
                            },
                           isButton: !viewModel.isRestoringSubscription )
        .alert(isPresented: $viewModel.shouldDisplayRestoreSubscriptionError) {
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
            SettingsCustomCell(content: { learnMoreView },
                               action: { isShowingSubscriptionFlow = true },
                               isButton: true )
            
            // Subscription Purchase
            .sheet(isPresented: $isShowingSubscriptionFlow,
                   onDismiss: { Task { viewModel.onAppear() } },
                   content: {
                        SubscriptionFlowView(viewModel: subscriptionFlowViewModel).interactiveDismissDisabled()
                })
            
            SettingsCustomCell(content: { iHaveASubscriptionView },
                               action: {
                                    isShowingSubscriptionRestoreFlow = true
                                },
                               isButton: true )
            
            // Subscription Restore
            .sheet(isPresented: $isShowingSubscriptionRestoreFlow,
                   onDismiss: { Task { viewModel.onAppear() } },
                   content: {
                        SubscriptionRestoreView(viewModel: subscriptionRestoreViewModel).interactiveDismissDisabled()
                })
            
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
        Group {
            if viewModel.shouldShowNetP {
                SettingsCellView(label: UserText.settingsPProVPNTitle,
                                 subtitle: viewModel.state.networkProtection.status != "" ? viewModel.state.networkProtection.status : nil,
                                 action: { viewModel.presentLegacyView(.netP) },
                                 disclosureIndicator: true,
                                 isButton: true)
            }
            
            if viewModel.shouldShowDBP {
                SettingsCellView(label: UserText.settingsPProDBPTitle,
                                 subtitle: UserText.settingsPProDBPSubTitle,
                                 action: { isShowingDBP.toggle() }, isButton: true)
                
                .sheet(isPresented: $isShowingDBP) {
                    SubscriptionPIRView()
                }
                
            }
            
            if viewModel.shouldShowITP {
                SettingsCellView(label: UserText.settingsPProITRTitle,
                                 subtitle: UserText.settingsPProITRSubTitle,
                                 action: { isShowingITP.toggle() }, isButton: true)
                
                .sheet(isPresented: $isShowingITP) {
                    SubscriptionITPView()
                }
                
            }

            NavigationLink(destination: SubscriptionSettingsView()) {
                SettingsCustomCell(content: { manageSubscriptionView })
            }
           
        }

    }
    
    var body: some View {
        if viewModel.state.subscription.enabled {
            Section(header: Text(UserText.settingsPProSection)) {
                
                if viewModel.state.subscription.hasActiveSubscription {
                                        
                    if !viewModel.isLoadingSubscriptionState {
                        
                        // Allow managing the subscription if we have some entitlements
                        if viewModel.shouldShowDBP || viewModel.shouldShowITP || viewModel.shouldShowNetP {
                            subscriptionDetailsView
                            
                            // If no entitlements it should mean the backend is still out of sync
                        } else {
                            noEntitlementsAvailableView
                        }
                    }
                } else {
                    purchaseSubscriptionView
                    
                }
            
            }
            
            // Selected Feature handler for Subscription Flow
            .onChange(of: subscriptionFlowViewModel.selectedFeature) { value in
                guard let value else { return }
                viewModel.triggerDeepLinkNavigation(to: value)
            }
            
            // Selected Feature handler for Subscription Restore
            .onChange(of: subscriptionRestoreViewModel.emailViewModel.selectedFeature) { value in
                guard let value else { return }
                viewModel.triggerDeepLinkNavigation(to: value)
            }
            
             // Selected Feature handler for SubscriptionActivation
            .onChange(of: subscriptionFlowViewModel.state.shouldActivateSubscription) { value in
                if value {
                    viewModel.triggerDeepLinkNavigation(to: .subscriptionRestoreFlow)
                }
            }
            
            // Selected Feature handler for Show Plans
            .onChange(of: subscriptionRestoreViewModel.state.shouldShowPlans) { value in
                if value {
                   viewModel.triggerDeepLinkNavigation(to: .subscriptionFlow)
               }
            }
        }
    }
}
#endif
