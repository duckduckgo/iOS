//
//  SubscriptionRestoreView.swift
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


#if SUBSCRIPTION
@available(iOS 15.0, *)
// swiftlint:disable type_body_length
struct SubscriptionRestoreView: View {

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var subscriptionNavController: SubscriptionNavigationController
    @StateObject var viewModel: SubscriptionRestoreViewModel
    @StateObject var emailViewModel: SubscriptionEmailViewModel
    
    @State private var isAlertVisible = false
    @State private var shouldShowWelcomePage = false
    @State private var shouldNavigateToActivationFlow = false
        
    var onRequirePurchase: (() -> Void)?
    
    
    private enum Constants {
        static let heroImage = "ManageSubscriptionHero"
        static let appleIDIcon = "Platform-Apple-16-subscriptions"
        static let emailIcon = "Email-16"
        static let openIndicator = "chevron.up"
        static let closedIndicator = "chevron.down"
        
        static let viewPadding = EdgeInsets(top: 10, leading: 30, bottom: 0, trailing: 30)
        static let sectionSpacing: CGFloat = 20
        static let maxWidth: CGFloat = 768
        static let boxMaxWidth: CGFloat = 500
        static let headerLineSpacing = 10.0
        static let footerLineSpacing = 7.0
        
        static let cornerRadius = 12.0
        static let boxPadding = EdgeInsets(top: 25,
                                           leading: 20,
                                           bottom: 25,
                                           trailing: 20)
        static let borderWidth: CGFloat = 1.0
        static let boxLineSpacing: CGFloat = 14
        
        static let buttonCornerRadius = 8.0
        static let buttonInsets = EdgeInsets(top: 10.0, leading: 16.0, bottom: 10.0, trailing: 16.0)
        static let buttonTopPadding: CGFloat = 20
    }
    
    var body: some View {
        if viewModel.state.isAddingDevice {
            ZStack {
                baseView
            }
        } else {
            ZStack {
                baseView
                
                if viewModel.state.transactionStatus != .idle {
                    PurchaseInProgressView(status: getTransactionStatus())
                }
              
            }
        }
    }
    
    private var contentView: some View {
        Group {
            ScrollView {
                VStack(spacing: Constants.sectionSpacing) {
                    headerView
                    emailView
                    footerView
                    Spacer()
                    
                    // Hidden link to display Email Activation View
                    NavigationLink(destination: SubscriptionEmailView(viewModel: emailViewModel)
                            .environmentObject(subscriptionNavController),
                                   isActive: $shouldNavigateToActivationFlow) {
                          EmptyView()
                    }.isDetailLink(false)
                    
                }.frame(maxWidth: Constants.boxMaxWidth)
            }
            .frame(maxWidth: Constants.maxWidth, alignment: .center)
            .padding(Constants.viewPadding)
            .background(Color(designSystemColor: .background))
            .tint(Color(designSystemColor: .icons))
            
            .navigationTitle(viewModel.state.viewTitle)
            .navigationBarBackButtonHidden(viewModel.state.transactionStatus != .idle)
            .navigationBarTitleDisplayMode(.inline)
            .applyInsetGroupedListStyle()
            .interactiveDismissDisabled(viewModel.subFeature.transactionStatus != .idle)
            .tint(Color.init(designSystemColor: .textPrimary))
            .accentColor(Color.init(designSystemColor: .textPrimary))
        }
    }
    
    @ViewBuilder
    private var baseView: some View {
       
        contentView
            .alert(isPresented: $isAlertVisible) { getAlert() }
            
            .onChange(of: viewModel.state.activationResult) { result in
                if result != .unknown {
                    isAlertVisible = true
                }
            }
            
            // Navigation Flow Binding
            .onChange(of: viewModel.state.shouldNavigateToActivationFlow) { result in
                shouldNavigateToActivationFlow = result
            }
            .onChange(of: shouldNavigateToActivationFlow) { result in
                viewModel.showActivationFlow(result)
            }
            
            .onChange(of: viewModel.state.shouldDismissView) { result in
                if result {
                    dismiss()
                }
            }
        
            .onReceive(subscriptionNavController.$shouldDismissStack) { shouldDismiss in
                if shouldDismiss {
                    dismiss()
                }
            }
            
            .onChange(of: viewModel.state.shouldShowPlans) { result in
                if result {
                    onRequirePurchase?()
                }
            }
            
            .onAppear {
                print("[Appear] SubscriptionRestoreView")
                Task { await viewModel.onAppear() }
                setUpAppearances()
                if viewModel.state.isAddingDevice {
                    Pixel.fire(pixel: .privacyProSettingsAddDevice, debounce: 2)
                }
            }

            .onDisappear {
                print("[DisAppear] SubscriptionRestoreView")
                Task { await viewModel.onDissappear() }
           }
                
    }

    // MARK: -
    
    private var emailView: some View {
        emailCellContent
            .padding(Constants.boxPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(designSystemColor: .panel))
            .cornerRadius(Constants.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .stroke(Color(designSystemColor: .lines), lineWidth: Constants.borderWidth)
            )
    }
   
    private var emailCellContent: some View {
        VStack(alignment: .leading, spacing: Constants.boxLineSpacing) {
            HStack {
                Image(Constants.emailIcon)
                Text(UserText.subscriptionActivateEmail)
                    .daxSubheadSemibold()
                    .foregroundColor(Color(designSystemColor: .textPrimary))
            }
            
            VStack(alignment: .leading) {
                if !viewModel.state.isAddingDevice {
                    Text(UserText.subscriptionActivateEmailDescription)
                        .daxSubheadRegular()
                        .foregroundColor(Color(designSystemColor: .textSecondary))
                    getCellButton(buttonText: UserText.subscriptionActivateEmailButton,
                                  action: {
                        DailyPixel.fireDailyAndCount(pixel: .privacyProRestorePurchaseEmailStart)
                        DailyPixel.fire(pixel: .privacyProWelcomeAddDevice)
                        viewModel.showActivationFlow(true)
                    })
                } else if viewModel.state.subscriptionEmail == nil {
                    Text(UserText.subscriptionAddDeviceEmailDescription)
                        .daxSubheadRegular()
                        .foregroundColor(Color(designSystemColor: .textSecondary))
                    getCellButton(buttonText: UserText.subscriptionRestoreAddEmailButton,
                                  action: {
                        Pixel.fire(pixel: .privacyProAddDeviceEnterEmail, debounce: 1)
                        viewModel.showActivationFlow(true)
                    })
                } else {
                    Text(viewModel.state.subscriptionEmail ?? "").daxSubheadSemibold()
                    Text(UserText.subscriptionManageEmailDescription)
                        .daxSubheadRegular()
                        .foregroundColor(Color(designSystemColor: .textSecondary))
                    HStack {
                        getCellButton(buttonText: UserText.subscriptionManageEmailButton,
                                      action: {
                            Pixel.fire(pixel: .privacyProSubscriptionManagementEmail, debounce: 1)
                            viewModel.showActivationFlow(true)
                        })
                    }
                }
            }
        }
    }
    
    private func getCellButton(buttonText: String, action: @escaping () -> Void) -> AnyView {
        AnyView(
            VStack {
                Button(action: action, label: {
                    Text(buttonText)
                        .daxButton()
                        .padding(Constants.buttonInsets)
                        .foregroundColor(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: Constants.buttonCornerRadius)
                                .stroke(Color.clear, lineWidth: 1)
                        )
                })
                
                .background(Color(designSystemColor: .accent))
                .cornerRadius(Constants.buttonCornerRadius)
            }.padding(.top, Constants.boxLineSpacing)
            
        )
    }
                
    private func getTransactionStatus() -> String {
        switch viewModel.state.transactionStatus {
        case .polling:
            return UserText.subscriptionCompletingPurchaseTitle
        case .purchasing:
            return UserText.subscriptionPurchasingTitle
        case .restoring:
            return UserText.subscriptionRestoringTitle
        case .idle:
            return ""
        }
    }
    
    private var headerView: some View {
        VStack(spacing: Constants.headerLineSpacing) {
            Image(Constants.heroImage)
            Text(viewModel.state.isAddingDevice ? UserText.subscriptionAddDeviceHeaderTitle : UserText.subscriptionActivateTitle)
                .daxHeadline()
                .multilineTextAlignment(.center)
                .foregroundColor(Color(designSystemColor: .textPrimary))
            Text(viewModel.state.isAddingDevice ? UserText.subscriptionAddDeviceDescription : UserText.subscriptionActivateHeaderDescription)
                .daxFootnoteRegular()
                .foregroundColor(Color(designSystemColor: .textSecondary))
                .multilineTextAlignment(.center)
        }
        
    }
    
    @ViewBuilder
    private var footerView: some View {
        if !viewModel.state.isAddingDevice {
            VStack(alignment: .leading, spacing: Constants.footerLineSpacing) {
                Text(UserText.subscriptionActivateDescription)
                    .daxFootnoteRegular()
                    .foregroundColor(Color(designSystemColor: .textSecondary))
                Button(action: {
                     viewModel.restoreAppstoreTransaction()
                }, label: {
                    Text(UserText.subscriptionRestoreAppleID)
                        .daxFootnoteSemibold()
                        .foregroundColor(Color(designSystemColor: .accent))
                })
            }
        }
    }
       
    private func getAlert() -> Alert {
        switch viewModel.state.activationResult {
        case .activated:
            return Alert(title: Text(UserText.subscriptionRestoreSuccessfulTitle),
                         message: Text(UserText.subscriptionRestoreSuccessfulMessage),
                         dismissButton: .default(Text(UserText.subscriptionRestoreSuccessfulButton)) {
                            viewModel.dismissView()
                         }
            )
        case .notFound:
            return Alert(title: Text(UserText.subscriptionRestoreNotFoundTitle),
                         message: Text(UserText.subscriptionRestoreNotFoundMessage),
                         primaryButton: .default(Text(UserText.subscriptionRestoreNotFoundPlans),
                                                 action: { viewModel.showPlans() }),
                         secondaryButton: .cancel())
            
        case .expired:
            return Alert(title: Text(UserText.subscriptionRestoreNotFoundTitle),
                         message: Text(UserText.subscriptionRestoreNotFoundMessage),
                         primaryButton: .default(Text(UserText.subscriptionRestoreNotFoundPlans),
                                                 action: { viewModel.showPlans() }),
                         secondaryButton: .cancel())
        default:
            return Alert(
                title: Text(UserText.subscriptionBackendErrorTitle),
                message: Text(UserText.subscriptionBackendErrorMessage),
                dismissButton: .cancel(Text(UserText.subscriptionBackendErrorButton)) {
                    viewModel.dismissView()
                }
            )
        }
    }
    
    private func setUpAppearances() {
        let navAppearance = UINavigationBar.appearance()
        navAppearance.backgroundColor = UIColor(designSystemColor: .background)
        navAppearance.barTintColor = UIColor(designSystemColor: .surface)
        navAppearance.shadowImage = UIImage()
        navAppearance.tintColor = UIColor(designSystemColor: .textPrimary)
    }
      
    struct ListItem {
        let id: Int
        let content: AnyView
        let expandedContent: AnyView
    }
    
}
// swiftlint:enable type_body_length
#endif
