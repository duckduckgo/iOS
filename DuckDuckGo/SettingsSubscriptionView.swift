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

enum SettingsSubscriptionViewConstants {
    static let purchaseDescriptionPadding = 5.0
    static let topCellPadding = 3.0
    static let noEntitlementsIconWidth = 20.0
    static let navigationDelay = 0.3
    static let infoIcon = "info-16"
    static let alertIcon = "Exclamation-Color-16"

    static let privacyPolicyURL = URL(string: "https://duckduckgo.com/pro/privacy-terms")!
}

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
    @State var isShowingPrivacyPro = false
    
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
        SettingsCellView(
            label: UserText.settingsPProManageSubscription,
            image: Image("SettingsPrivacyPro")
        )
    }

    private var subscriptionManager: SubscriptionManager {
        AppDependencyProvider.shared.subscriptionManager
    }

    @ViewBuilder
    private var purchaseSubscriptionView: some View {
        Group {
            SettingsCellView(label: UserText.settingsPProSubscribe,
                             subtitle: UserText.settingsPProDescription,
                             image: Image("SettingsPrivacyPro"))

            let subscribeView = SubscriptionContainerViewFactory.makeSubscribeFlow(origin: nil,
                                                                                   navigationCoordinator: subscriptionNavigationCoordinator,
                                                                                   subscriptionManager: subscriptionManager,
                                                                                   privacyProDataReporter: viewModel.privacyProDataReporter
            ).navigationViewStyle(.stack)
            let restoreView = SubscriptionContainerViewFactory.makeRestoreFlow(navigationCoordinator: subscriptionNavigationCoordinator,
                                                                               subscriptionManager: subscriptionManager)
                .navigationViewStyle(.stack)
                .onFirstAppear {
                    Pixel.fire(pixel: .privacyProRestorePurchaseClick)
                }
            NavigationLink(destination: subscribeView,
                           isActive: $isShowingSubscribeFlow) {
                SettingsCellView(label: UserText.settingsPProLearnMore).padding(.leading, 32.0)
            }

            NavigationLink(destination: restoreView,
                           isActive: $isShowingRestoreFlow) {
                SettingsCellView(label: UserText.settingsPProIHaveASubscription).padding(.leading, 32.0)
            }
        }
    }

    @ViewBuilder
    private var subscriptionExpiredView: some View {
        if viewModel.state.subscription.entitlements.contains(.networkProtection) {
            SettingsCellView(label: UserText.settingsPProVPNTitle,
                             image: Image("SettingsPrivacyProVPN"),
                             statusIndicator: StatusIndicatorView(status: .off),
                             isGreyedOut: true
            )
        }

        if viewModel.state.subscription.entitlements.contains(.dataBrokerProtection) {
            SettingsCellView(
                label: UserText.settingsPProDBPTitle,
                image: Image("SettingsPrivacyProPIR"),
                statusIndicator: StatusIndicatorView(status: .off),
                isGreyedOut: true
            )
        }

        if viewModel.state.subscription.entitlements.contains(.identityTheftRestoration) {
            SettingsCellView(
                label: UserText.settingsPProITRTitle,
                image: Image("SettingsPrivacyProITP"),
                statusIndicator: StatusIndicatorView(status: .off),
                isGreyedOut: true
            )
        }

        // Renew Subscription (Expired)
        let settingsView = SubscriptionSettingsView(viewPlans: { isShowingSubscribeFlow = true })
            .environmentObject(subscriptionNavigationCoordinator)
        NavigationLink(destination: settingsView) {
            SettingsCellView(
                label: UserText.settingsPProManageSubscription,
                subtitle: "Your Privacy Pro subscription expired",
                image: Image("SettingsPrivacyPro"),
                accessory: .image(Image("SettingsPrivacyProWarning"))
            )
        }
    }

//    @ViewBuilder
//    private var noEntitlementsAvailableView: some View {
//        Group {
//            SettingsCustomCell(content: {
//                HStack(alignment: .top) {
//                    Image(SettingsSubscriptionViewConstants.infoIcon)
//                        .frame(width: SettingsSubscriptionViewConstants.noEntitlementsIconWidth)
//                        .padding(.top, SettingsSubscriptionViewConstants.topCellPadding)
//                    VStack(alignment: .leading) {
//                        Text(UserText.settingsPProActivationPendingTitle).daxBodyRegular()
//                        Text(UserText.settingsPProActivationPendingDescription).daxFootnoteRegular()
//                            .padding(.bottom, SettingsSubscriptionViewConstants.purchaseDescriptionPadding)
//                    }.foregroundColor(Color(designSystemColor: .textSecondary))
//                }
//            })
//            restorePurchaseView
//        }
//    }

    @ViewBuilder
    private var noEntitlementsAvailableView: some View {
        if viewModel.state.subscription.entitlements.contains(.networkProtection) {
            SettingsCellView(label: UserText.settingsPProVPNTitle,
                             image: Image("SettingsPrivacyProVPN"),
                             statusIndicator: StatusIndicatorView(status: .off),
                             isGreyedOut: true
            )
        }

        if viewModel.state.subscription.entitlements.contains(.dataBrokerProtection) {
            SettingsCellView(
                label: UserText.settingsPProDBPTitle,
                image: Image("SettingsPrivacyProPIR"),
                statusIndicator: StatusIndicatorView(status: .off),
                isGreyedOut: true
            )
        }

        if viewModel.state.subscription.entitlements.contains(.identityTheftRestoration) {
            SettingsCellView(
                label: UserText.settingsPProITRTitle,
                image: Image("SettingsPrivacyProITP"),
                statusIndicator: StatusIndicatorView(status: .off),
                isGreyedOut: true
            )
        }

        // Renew Subscription (Expired)
        let settingsView = SubscriptionSettingsView(viewPlans: { isShowingSubscribeFlow = true })
            .environmentObject(subscriptionNavigationCoordinator)
        NavigationLink(destination: settingsView) {
            SettingsCellView(
                label: UserText.settingsPProManageSubscription,
                subtitle: "Activating",
                image: Image("SettingsPrivacyPro")
            )
        }
    }

    @ViewBuilder
    private var subscriptionDetailsView: some View {
        
        if viewModel.state.subscription.entitlements.contains(.networkProtection) {
            SettingsCellView(label: UserText.settingsPProVPNTitle,
                             image: Image("SettingsPrivacyProVPN"),
                             action: { viewModel.presentLegacyView(.netP) },
                             statusIndicator: StatusIndicatorView(status: viewModel.state.networkProtection.enabled ? .on : .off),
                             disclosureIndicator: true,
                             isButton: true)
        }
        
        if viewModel.state.subscription.entitlements.contains(.dataBrokerProtection) {
            NavigationLink(destination: SubscriptionPIRView(), isActive: $isShowingDBP) {
                SettingsCellView(
                    label: UserText.settingsPProDBPTitle,
                    image: Image("SettingsPrivacyProPIR"),
                    statusIndicator: StatusIndicatorView(status: .on)
                )
            }
        }
        
        if viewModel.state.subscription.entitlements.contains(.identityTheftRestoration) {
            NavigationLink(
                destination: SubscriptionITPView(),
                isActive: $isShowingITP) {
                    SettingsCellView(
                        label: UserText.settingsPProITRTitle,
                        image: Image("SettingsPrivacyProITP"),
                        statusIndicator: StatusIndicatorView(status: .on)
                    )
            }
        }
        
        NavigationLink(
            destination: SubscriptionSettingsView().environmentObject(subscriptionNavigationCoordinator)
        ) {
            SettingsCustomCell(content: { manageSubscriptionView })
        }
        
    }
        
    var body: some View {
        Group {
            if isShowingPrivacyPro {

                let isSignedIn = viewModel.state.subscription.isSignedIn
                let hasActiveSubscription = viewModel.state.subscription.hasActiveSubscription
                let hasNoEntitlements = viewModel.state.subscription.entitlements.isEmpty

                let footerLink = Link(UserText.settingsPProSectionFooter,
                                      destination: SettingsSubscriptionViewConstants.privacyPolicyURL)
                    .daxFootnoteRegular().accentColor(Color.init(designSystemColor: .accent))

                Section(header: Text(UserText.settingsPProSection),
                        footer: !isSignedIn ? footerLink : nil
                ) {
                    purchaseSubscriptionView

//                    switch (isSignedIn, hasActiveSubscription, hasNoEntitlements) {
//                      
//                        // Signed In, Subscription Expired
//                    case (true, false, _):
//                        subscriptionExpiredView
//                        
//                        // Signed in, Subscription Active, Valid entitlements
//                    case (true, true, false):
//                        subscriptionDetailsView  // View for valid subscription details
//                        
//                        // Signed in, Subscription Active, Empty Entitlements
//                    case (true, true, true):
//                        noEntitlementsAvailableView  // View for no entitlements
//                        
//                        // Signed out
//                    case (false, _, _):
//                        purchaseSubscriptionView  // View for signing up or purchasing a subscription
//                    }
                }
                
                .onChange(of: viewModel.state.subscription.shouldDisplayRestoreSubscriptionError) { value in
                    if value {
                        isShowingSubscriptionError = true
                    }
                }
                
                .onReceive(subscriptionNavigationCoordinator.$shouldPopToAppSettings) { shouldDismiss in
                    if shouldDismiss {
                        isShowingRestoreFlow = false
                        isShowingSubscribeFlow = false
                    }
                }

            }
        }.onReceive(viewModel.$state) { state in
            isShowingPrivacyPro = state.subscription.enabled && (state.subscription.isSignedIn || state.subscription.canPurchase)
        }
    }
}
