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

struct SettingsSubscriptionView: View {

    enum ViewConstants {
        static let purchaseDescriptionPadding = 5.0
        static let topCellPadding = 3.0
        static let noEntitlementsIconWidth = 20.0
        static let navigationDelay = 0.3
        static let infoIcon = "info-16"
        static let alertIcon = "Exclamation-Color-16"
        static let privacyPolicyURL = URL(string: "https://duckduckgo.com/pro/privacy-terms")!
    }

    @EnvironmentObject var viewModel: SettingsViewModel
    @EnvironmentObject var subscriptionNavigationCoordinator: SubscriptionNavigationCoordinator
    @State var isShowingDBP = false
    @State var isShowingITP = false
    @State var isShowingVPN = false
    @State var isShowingRestoreFlow = false
    @State var isShowingGoogleView = false
    @State var isShowingStripeView = false
    @State var isShowingPrivacyPro = false

    var subscriptionRestoreView: some View {
        SubscriptionContainerViewFactory.makeRestoreFlow(navigationCoordinator: subscriptionNavigationCoordinator,
                                                                           subscriptionManager: subscriptionManager)
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

            // Get privacy pro
            SettingsCustomCell(content: {
                Text(UserText.settingsPProLearnMore)
                    .daxBodyRegular()
                    .foregroundColor(Color.init(designSystemColor: .accent))
                    .padding(.leading, 32.0)
            }, action: {
                subscriptionNavigationCoordinator.shouldPushSubscriptionWebView = true
            }, isButton: true)

            // Restore subscription
            let restoreView = subscriptionRestoreView
                .navigationViewStyle(.stack)
                .onFirstAppear {
                    Pixel.fire(pixel: .privacyProRestorePurchaseClick)
                }
            NavigationLink(destination: restoreView,
                           isActive: $isShowingRestoreFlow) {
                SettingsCellView(label: UserText.settingsPProIHaveASubscription).padding(.leading, 32.0)
            }
        }
    }

    @ViewBuilder
    private var disabledFeaturesView: some View {
        SettingsCellView(label: UserText.settingsPProVPNTitle,
                         image: Image("SettingsPrivacyProVPN"),
                         statusIndicator: StatusIndicatorView(status: .off),
                         isGreyedOut: true
        )
        SettingsCellView(
            label: UserText.settingsPProDBPTitle,
            image: Image("SettingsPrivacyProPIR"),
            statusIndicator: StatusIndicatorView(status: .off),
            isGreyedOut: true
        )
        SettingsCellView(
            label: UserText.settingsPProITRTitle,
            image: Image("SettingsPrivacyProITP"),
            statusIndicator: StatusIndicatorView(status: .off),
            isGreyedOut: true
        )
    }

    @ViewBuilder
    private var subscriptionExpiredView: some View {
        disabledFeaturesView

        // Renew Subscription (Expired)
        let settingsView = SubscriptionSettingsView(configuration: .expired,
                                                    settingsViewModel: viewModel,
                                                    viewPlans: {
            subscriptionNavigationCoordinator.shouldPushSubscriptionWebView = true
        })
            .environmentObject(subscriptionNavigationCoordinator)
        NavigationLink(destination: settingsView) {
            SettingsCellView(
                label: UserText.settingsPProManageSubscription,
                subtitle: UserText.settingsPProSubscriptionExpiredTitle,
                image: Image("SettingsPrivacyPro"),
                accessory: .image(Image("Exclamation-Color-16"))
            )
        }
    }

    @ViewBuilder
    private var noEntitlementsAvailableView: some View {
        disabledFeaturesView
        
        // Renew Subscription (Expired)
        let settingsView = SubscriptionSettingsView(configuration: .activating,
                                                    settingsViewModel: viewModel,
                                                    viewPlans: {
            subscriptionNavigationCoordinator.shouldPushSubscriptionWebView = true
        })
            .environmentObject(subscriptionNavigationCoordinator)
        NavigationLink(destination: settingsView) {
            SettingsCellView(
                label: UserText.settingsPProManageSubscription,
                subtitle: UserText.settingsPProActivating,
                image: Image("SettingsPrivacyPro")
            )
        }
    }

    @ViewBuilder
    private var subscriptionDetailsView: some View {
        
        if viewModel.state.subscription.entitlements.contains(.networkProtection) {
            NavigationLink(destination: NetworkProtectionRootView(), isActive: $isShowingVPN) {
                SettingsCellView(
                    label: UserText.settingsPProVPNTitle,
                    image: Image("SettingsPrivacyProVPN"),
                    statusIndicator: StatusIndicatorView(status: viewModel.state.networkProtectionConnected ? .on : .off)
                )
            }
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
            destination: SubscriptionSettingsView(configuration: .subscribed,
                                                  settingsViewModel: viewModel)
                .environmentObject(subscriptionNavigationCoordinator)
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
                                      destination: ViewConstants.privacyPolicyURL)
                    .daxFootnoteRegular().accentColor(Color.init(designSystemColor: .accent))

                Section(header: Text(UserText.settingsPProSection),
                        footer: !isSignedIn ? footerLink : nil
                ) {

                    switch (isSignedIn, hasActiveSubscription, hasNoEntitlements) {

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
                .onReceive(subscriptionNavigationCoordinator.$shouldPopToAppSettings) { shouldDismiss in
                    if shouldDismiss {
                        isShowingRestoreFlow = false
                        subscriptionNavigationCoordinator.shouldPushSubscriptionWebView = false
                    }
                }
            }
        }
        .onReceive(viewModel.$state) { state in
            isShowingPrivacyPro = state.subscription.enabled && (state.subscription.isSignedIn || state.subscription.canPurchase)
        }
    }
}
