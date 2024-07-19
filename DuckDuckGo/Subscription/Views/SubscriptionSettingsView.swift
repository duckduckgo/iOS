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

struct SubscriptionSettingsView: View {
        
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = SubscriptionSettingsViewModel()
    @EnvironmentObject var subscriptionNavigationCoordinator: SubscriptionNavigationCoordinator
    var viewPlans: (() -> Void)?
    
    @State var isShowingStripeView = false
    @State var isShowingGoogleView = false
    @State var isShowingRemovalNotice = false
    @State var isShowingFAQView = false
    @State var isShowingLearnMoreView = false
    @State var isShowingEmailView = false
    @State var isShowingConnectionError = false

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
            let isExpired = !(viewModel.state.subscriptionInfo?.isActive ?? false)
            VStack(alignment: .center, spacing: 7) {
                Image("Privacy-Pro-96x96")
                Text(UserText.subscriptionTitle).daxTitle2()

                if isExpired {
                    HStack {
                        Image(Constants.alertIcon)
                        Text(viewModel.state.subscriptionDetails)
                            .daxSubheadRegular()
                            .foregroundColor(Color(designSystemColor: .textSecondary))
                    }
                }
            }
        }
        .listRowBackground(Color.clear)
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var devicesSection: some View {
        Section(header: Text(UserText.subscriptionDevicesSectionHeader),
                footer: devicesSectionFooter) {

            if !viewModel.state.isLoadingEmailInfo {
                NavigationLink(destination: SubscriptionContainerViewFactory.makeEmailFlow(
                    navigationCoordinator: subscriptionNavigationCoordinator,
                    subscriptionManager: AppDependencyProvider.shared.subscriptionManager,
                    onDisappear: {
                        Task { await viewModel.fetchAndUpdateAccountEmail(cachePolicy: .reloadIgnoringLocalCacheData, loadingIndicator: false) }
                    }),
                               isActive: $isShowingEmailView) {
                    if let email = viewModel.state.subscriptionEmail {
                        SettingsCellView(label: UserText.subscriptionEditEmailButton,
                                         subtitle: email)
                    } else {
                        SettingsCellView(label: UserText.subscriptionAddEmailButton)
                    }
                }.isDetailLink(false)
            } else {
                SwiftUI.ProgressView()
            }
        }
    }

    private var devicesSectionFooter: some View {
        let hasEmail = !(viewModel.state.subscriptionEmail ?? "").isEmpty
        let footerText = hasEmail ? UserText.subscriptionDevicesSectionWithEmailFooter : UserText.subscriptionDevicesSectionNoEmailFooter
        return Text(.init("\(footerText)")) // required to parse markdown formatting
            .environment(\.openURL, OpenURLAction { _ in
                viewModel.displayLearnMoreView(true)
                return .handled
            })
    }

    private var manageSection: some View {
        Section(header: Text(UserText.subscriptionManageTitle),
                footer: manageSectionFooter) {
            let active = viewModel.state.subscriptionInfo?.isActive ?? false
            SettingsCustomCell(content: {

                if !viewModel.state.isLoadingSubscriptionInfo {
                    if active {
                        Text(UserText.subscriptionChangePlan)
                            .daxBodyRegular()
                            .foregroundColor(Color.init(designSystemColor: .accent))
                    } else {
                        Text(UserText.subscriptionRestoreNotFoundPlans)
                            .daxBodyRegular()
                            .foregroundColor(Color.init(designSystemColor: .accent))
                    }
                } else {
                    SwiftUI.ProgressView()
                }
            },
                               action: {
                if !viewModel.state.isLoadingSubscriptionInfo {
                    Task {
                        if active {
                            viewModel.manageSubscription()
                            Pixel.fire(pixel: .privacyProSubscriptionManagementPlanBilling, debounce: 1)
                        } else {
                            viewPlans?()
                        }
                    }
                }
            },
                               isButton: true)
            .sheet(isPresented: $isShowingStripeView) {
                if let stripeViewModel = viewModel.state.stripeViewModel {
                    SubscriptionExternalLinkView(viewModel: stripeViewModel, title: UserText.subscriptionManagePlan)
                }
            }

            SettingsCustomCell(content: {
                Text(UserText.subscriptionRemoveFromDevice)
                        .daxBodyRegular()
                        .foregroundColor(Color.init(designSystemColor: .accent))},
                               action: { viewModel.displayRemovalNotice(true) },
                               isButton: true)
        }
    }

    private var manageSectionFooter: some View {
        let isExpired = !(viewModel.state.subscriptionInfo?.isActive ?? false)
        return  Group {
            if isExpired {
                EmptyView()
            } else {
                Text(viewModel.state.subscriptionDetails)
            }
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
            devicesSection
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
            manageSection
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
        
        // FAQ
        .onChange(of: viewModel.state.isShowingFAQView) { value in
            isShowingFAQView = value
        }
        .onChange(of: isShowingFAQView) { value in
            viewModel.displayFAQView(value)
        }

        // Learn More
        .onChange(of: viewModel.state.isShowingLearnMoreView) { value in
            isShowingLearnMoreView = value
        }
        .onChange(of: isShowingLearnMoreView) { value in
            viewModel.displayLearnMoreView(value)
        }

        // Connection Error
        .onChange(of: viewModel.state.isShowingConnectionError) { value in
            isShowingConnectionError = value
        }
        .onChange(of: isShowingConnectionError) { value in
            viewModel.showConnectionError(value)
        }

        .onChange(of: isShowingEmailView) { value in
            if value {
                if let email = viewModel.state.subscriptionEmail, !email.isEmpty {
                    Pixel.fire(pixel: .privacyProSubscriptionManagementEmail, debounce: 1)
                } else {
                    Pixel.fire(pixel: .privacyProAddDeviceEnterEmail, debounce: 1)
                }
            }
        }
        
        .onReceive(subscriptionNavigationCoordinator.$shouldPopToSubscriptionSettings) { shouldDismiss in
            if shouldDismiss {
                isShowingEmailView = false
            }
        }
        
        .alert(isPresented: $isShowingConnectionError) {
            Alert(
                title: Text(UserText.subscriptionBackendErrorTitle),
                message: Text(UserText.subscriptionBackendErrorMessage),
                dismissButton: .cancel(Text(UserText.subscriptionBackendErrorButton)) {
                    dismiss()
                }
            )
        }
        
        .sheet(isPresented: $isShowingFAQView, content: {
            SubscriptionExternalLinkView(viewModel: viewModel.state.faqViewModel, title: UserText.subscriptionFAQ)
        })

        .sheet(isPresented: $isShowingLearnMoreView, content: {
            SubscriptionExternalLinkView(viewModel: viewModel.state.learnMoreViewModel, title: UserText.subscriptionFAQ)
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
// struct SubscriptionSettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SubscriptionSettingsView()
//    }
// }
