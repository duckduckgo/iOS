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

    @EnvironmentObject var settingsViewModel: SettingsViewModel
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
                                                         subscriptionManager: subscriptionManager,
                                                         subscriptionFeatureAvailability: settingsViewModel.subscriptionFeatureAvailability)
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
            let subtitleText = {
                switch subscriptionManager.storePurchaseManager().currentStorefrontRegion {
                case .usa:
                    UserText.settingsPProUSDescription
                case .restOfWorld:
                    UserText.settingsPProROWDescription
                }
            }()

            SettingsCellView(label: UserText.settingsPProSubscribe,
                             subtitle: subtitleText,
                             image: Image("SettingsPrivacyPro"))
            .disabled(true)

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
        let subscriptionFeatures = settingsViewModel.state.subscription.subscriptionFeatures

        if subscriptionFeatures.contains(.networkProtection) {
            SettingsCellView(label: UserText.settingsPProVPNTitle,
                             image: Image("SettingsPrivacyProVPN"),
                             statusIndicator: StatusIndicatorView(status: .off),
                             isGreyedOut: true
            )
        }

        if subscriptionFeatures.contains(.dataBrokerProtection) {
            SettingsCellView(
                label: UserText.settingsPProDBPTitle,
                image: Image("SettingsPrivacyProPIR"),
                statusIndicator: StatusIndicatorView(status: .off),
                isGreyedOut: true
            )
        }

        if subscriptionFeatures.contains(.identityTheftRestoration) || subscriptionFeatures.contains(.identityTheftRestorationGlobal) {
            SettingsCellView(
                label: UserText.settingsPProITRTitle,
                image: Image("SettingsPrivacyProITP"),
                statusIndicator: StatusIndicatorView(status: .off),
                isGreyedOut: true
            )
        }
    }

    @ViewBuilder
    private var subscriptionExpiredView: some View {
        disabledFeaturesView

        // Renew Subscription (Expired)
        let settingsView = SubscriptionSettingsView(configuration: .expired,
                                                    settingsViewModel: settingsViewModel,
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
    private var missingSubscriptionOrEntitlementsView: some View {
        disabledFeaturesView
        
        // Renew Subscription (Expired)
        let settingsView = SubscriptionSettingsView(configuration: .activating,
                                                    settingsViewModel: settingsViewModel,
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
        let subscriptionFeatures = settingsViewModel.state.subscription.subscriptionFeatures
        let userEntitlements = settingsViewModel.state.subscription.entitlements

        if subscriptionFeatures.contains(.networkProtection) {
            let hasVPNEntitlement = userEntitlements.contains(.networkProtection)
            let isVPNConnected = settingsViewModel.state.networkProtectionConnected

            NavigationLink(destination: LazyView(NetworkProtectionRootView()), isActive: $isShowingVPN) {
                SettingsCellView(
                    label: UserText.settingsPProVPNTitle,
                    image: Image("SettingsPrivacyProVPN"),
                    statusIndicator: StatusIndicatorView(status: isVPNConnected ? .on : .off),
                    isGreyedOut: !hasVPNEntitlement
                )
            }
            .disabled(!hasVPNEntitlement)
        }

        if subscriptionFeatures.contains(.dataBrokerProtection) {
            let hasDBPEntitlement = userEntitlements.contains(.dataBrokerProtection)

            NavigationLink(destination: LazyView(SubscriptionPIRView()), isActive: $isShowingDBP) {
                SettingsCellView(
                    label: UserText.settingsPProDBPTitle,
                    image: Image("SettingsPrivacyProPIR"),
                    statusIndicator: StatusIndicatorView(status: hasDBPEntitlement ? .on : .off),
                    isGreyedOut: !hasDBPEntitlement
                )
            }
            .disabled(!hasDBPEntitlement)
        }

        if subscriptionFeatures.contains(.identityTheftRestoration) || subscriptionFeatures.contains(.identityTheftRestorationGlobal) {
            let hasITREntitlement = userEntitlements.contains(.identityTheftRestoration) || userEntitlements.contains(.identityTheftRestorationGlobal)

            NavigationLink(destination: LazyView(SubscriptionITPView()), isActive: $isShowingITP) {
                SettingsCellView(
                    label: UserText.settingsPProITRTitle,
                    image: Image("SettingsPrivacyProITP"),
                    statusIndicator: StatusIndicatorView(status: hasITREntitlement ? .on : .off),
                    isGreyedOut: !hasITREntitlement
                )
            }
            .disabled(!hasITREntitlement)
        }

        let isActiveTrialOffer = settingsViewModel.state.subscription.isActiveTrialOffer
        let configuration: SubscriptionSettingsView.Configuration = isActiveTrialOffer ? .trial : .subscribed

        NavigationLink(destination: LazyView(SubscriptionSettingsView(configuration: configuration, settingsViewModel: settingsViewModel))
            .environmentObject(subscriptionNavigationCoordinator)
        ) {
            SettingsCustomCell(content: { manageSubscriptionView })
        }
    }
        
    var body: some View {
        Group {
            if isShowingPrivacyPro {

                let isSignedIn = settingsViewModel.state.subscription.isSignedIn
                let hasSubscription = settingsViewModel.state.subscription.hasSubscription
                let hasActiveSubscription = settingsViewModel.state.subscription.hasActiveSubscription
                let hasAnyEntitlements = !settingsViewModel.state.subscription.entitlements.isEmpty

                let footerLink = Link(UserText.settingsPProSectionFooter,
                                      destination: ViewConstants.privacyPolicyURL)
                    .daxFootnoteRegular().accentColor(Color.init(designSystemColor: .accent))

                Section(header: Text(UserText.settingsPProSection),
                        footer: !isSignedIn ? footerLink : nil
                ) {

                    switch (isSignedIn, hasSubscription, hasActiveSubscription, hasAnyEntitlements) {

                    // Signed out
                    case (false, _, _, _):
                        purchaseSubscriptionView

                    // Signed In, Subscription Missing
                    case (true, false, _, _):
                        missingSubscriptionOrEntitlementsView

                    // Signed In, Subscription Present & Not Active
                    case (true, true, false, _):
                        subscriptionExpiredView

                    // Signed in, Subscription Present & Active, Missing Entitlements
                    case (true, true, true, false):
                        missingSubscriptionOrEntitlementsView

                    // Signed in, Subscription Present & Active, Valid entitlements
                    case (true, true, true, true):
                        subscriptionDetailsView
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
        .onReceive(settingsViewModel.$state) { state in
            isShowingPrivacyPro = (state.subscription.isSignedIn || state.subscription.canPurchase)
        }
    }
}
