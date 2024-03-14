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
struct SubscriptionRestoreView: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = SubscriptionRestoreViewModel()
    
    @State private var isAlertVisible = false
    @State private var isActive: Bool = false
    @State private var shouldNavigateToSubscriptionFlow: Bool = false
    @State private var shouldDisplayEmailActivationFlow: Bool = false
    var onDismissStack: (() -> Void)?
    
    private enum Constants {
        static let heroImage = "ManageSubscriptionHero"
        static let appleIDIcon = "Platform-Apple-16"
        static let emailIcon = "Email-16"
        static let openIndicator = "chevron.up"
        static let closedIndicator = "chevron.down"
        
        static let viewPadding = EdgeInsets(top: 10, leading: 30, bottom: 0, trailing: 30)
        static let sectionSpacing: CGFloat = 20
        static let headerLineSpacing = 10.0
        static let footerLineSpacing = 7.0
        
        static let cornerRadius = 12.0
        static let boxPadding: CGFloat = 25
        static let borderWidth: CGFloat = 1.0
        static let boxLineSpacing: CGFloat = 18
        
        static let buttonCornerRadius = 8.0
        static let buttonInsets = EdgeInsets(top: 10.0, leading: 16.0, bottom: 10.0, trailing: 16.0)
        static let baseInsets = EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30)
        
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: Constants.sectionSpacing) {
                    headerView
                    emailView
                    footerView
                    Spacer()
                    
                    // Hidden link to display Subscription Welcome Page
                    NavigationLink(destination: SubscriptionFlowView(), isActive: $shouldNavigateToSubscriptionFlow) {
                        EmptyView()
                    }.isDetailLink(false)
                    
                }
                .padding(Constants.viewPadding)
                .background(Color(designSystemColor: .background))
                
                
                .navigationTitle(viewModel.state.isAddingDevice ? UserText.subscriptionAddDeviceTitle : UserText.subscriptionActivate)
                .navigationBarBackButtonHidden(viewModel.state.transactionStatus != .idle)
                .navigationBarTitleDisplayMode(.inline)
                .applyInsetGroupedListStyle()
                .navigationBarItems(trailing: Button(UserText.subscriptionCloseButton) { })
                .tint(Color(designSystemColor: .icons))
                
                .alert(isPresented: $isAlertVisible) { getAlert() }
            
                .onChange(of: viewModel.state.activationResult) { result in
                    if result != .unknown {
                        isAlertVisible = true
                    }
                }
            
                .sheet(isPresented: $shouldDisplayEmailActivationFlow) {
                    SubscriptionEmailView(isAddingDevice: viewModel.state.isAddingDevice)
                }
            
                .onAppear {
                    viewModel.initializeView()
                    setUpAppearances()
                }
                
                if viewModel.state.transactionStatus != .idle {
                    PurchaseInProgressView(status: getTransactionStatus())
                }
            }
        }.navigationViewStyle(.stack)
        
    }
    
    // MARK: -
    
    private var emailView: some View {
        emailCellContent
        .background(Color(designSystemColor: .panel))
        .padding(Constants.boxPadding)
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
                        // buttonAction()
                    })
                } else if viewModel.state.subscriptionEmail == nil {
                    Text(UserText.subscriptionAddDeviceEmailDescription)
                        .daxSubheadRegular()
                        .foregroundColor(Color(designSystemColor: .textSecondary))
                    getCellButton(buttonText: UserText.subscriptionRestoreAddEmailButton,
                                  action: {
                        Pixel.fire(pixel: .privacyProAddDeviceEnterEmail)
                        // buttonAction()
                    })
                } else {
                    Text(viewModel.state.subscriptionEmail ?? "").daxSubheadSemibold()
                    Text(UserText.subscriptionManageEmailDescription)
                        .daxSubheadRegular()
                        .foregroundColor(Color(designSystemColor: .textSecondary))
                    HStack {
                        getCellButton(buttonText: UserText.subscriptionManageEmailButton,
                                      action: {
                            Pixel.fire(pixel: .privacyProSubscriptionManagementEmail)
                            // buttonAction()
                        })
                    }
                }
            }
            
        }
    }
    
    private func getCellButton(buttonText: String, action: @escaping () -> Void) -> AnyView {
        AnyView(
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
                    shouldNavigateToSubscriptionFlow = true
                    // viewModel.restoreAppstoreTransaction()
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
                            shouldNavigateToSubscriptionFlow = true
                         }
            )
        case .notFound:
            return Alert(title: Text(UserText.subscriptionRestoreNotFoundTitle),
                         message: Text(UserText.subscriptionRestoreNotFoundMessage),
                         primaryButton: .default(Text(UserText.subscriptionRestoreNotFoundPlans),
                                                 action: {
                                                    dismiss()
                                                 }),
                         secondaryButton: .cancel())
            
        case .expired:
            return Alert(title: Text(UserText.subscriptionRestoreNotFoundTitle),
                         message: Text(UserText.subscriptionRestoreNotFoundMessage),
                         primaryButton: .default(Text(UserText.subscriptionRestoreNotFoundPlans),
                                                 action: {
                                                    dismiss()
                                                 }),
                         secondaryButton: .cancel())
        default:
            return Alert(
                title: Text(UserText.subscriptionBackendErrorTitle),
                message: Text(UserText.subscriptionBackendErrorMessage),
                dismissButton: .cancel(Text(UserText.subscriptionBackendErrorButton)) {
                    onDismissStack?()
                    dismiss()
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

@available(iOS 15.0, *)
struct SubscriptionRestoreView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionRestoreView()
    }
}

#endif
