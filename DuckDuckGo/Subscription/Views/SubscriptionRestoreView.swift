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

#if SUBSCRIPTION
@available(iOS 15.0, *)
struct SubscriptionRestoreView: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: SubscriptionRestoreViewModel
    @State private var expandedItemId: Int = 0
    @State private var isAlertVisible = false
    
    // Binding used to dismiss the entire stack (Go back to settings from several levels down)
    @Binding var isActivatingSubscription: Bool
    
    private enum Constants {
        static let heroImage = "ManageSubscriptionHero"
        static let appleIDIcon = "Platform-Apple-16"
        static let emailIcon = "Email-16"
        static let headerLineSpacing = 10.0
        static let openIndicator = "chevron.up"
        static let closedIndicator = "chevron.down"
        static let buttonCornerRadius = 8.0
        static let buttonInsets = EdgeInsets(top: 10.0, leading: 16.0, bottom: 10.0, trailing: 16.0)
        static let cellLineSpacing = 12.0
        static let cellPadding = 4.0
        static let headerPadding = EdgeInsets(top: 16.0, leading: 16.0, bottom: 0, trailing: 16.0)
    }
    
    var body: some View {
        ZStack {
            VStack {
                headerView
                listView
            }
            .background(Color(designSystemColor: .container))
            .navigationTitle(viewModel.isAddingDevice ? UserText.subscriptionAddDeviceTitle : UserText.subscriptionActivate)
            .navigationBarBackButtonHidden(viewModel.transactionStatus != .idle)
            .applyInsetGroupedListStyle()
            .alert(isPresented: $isAlertVisible) { getAlert() }
            .onChange(of: viewModel.activationResult) { result in
                if result != .unknown {
                    isAlertVisible = true
                }
            }
            .onAppear {
                viewModel.initializeView()
            }
            
            if viewModel.transactionStatus != .idle {
                PurchaseInProgressView(status: getTransactionStatus())
            }
        }
        
        // Activation View
        NavigationLink(destination: SubscriptionEmailView(
                    viewModel: SubscriptionEmailViewModel(
                    userScript: viewModel.userScript,
                    subFeature: viewModel.subFeature,
                    accountManager: viewModel.accountManager),
                isActivatingSubscription: $isActivatingSubscription),
                isActive: $viewModel.isManagingEmailSubscription) {
            EmptyView()
        }
    }
    
    private var listItems: [ListItem] {
        [
            .init(id: 0,
                  content: getCellTitle(icon: Constants.appleIDIcon,
                                        text: UserText.subscriptionActivateAppleID),
                  expandedContent: getAppleIDCellContent(buttonAction: viewModel.restoreAppstoreTransaction)),
            .init(id: 1,
                  content: getCellTitle(icon: Constants.emailIcon,
                                        text: UserText.subscriptionActivateEmail),
                  expandedContent: getEmailCellContent(buttonAction: viewModel.manageEmailSubscription ))
        ]
    }
    
    private func getCellTitle(icon: String, text: String) -> AnyView {
        AnyView(
            HStack {
                Image(icon)
                Text(text)
                    .daxBodyRegular()
                    .foregroundColor(Color(designSystemColor: .textPrimary))
            }
        )
    }
    
    private func getAppleIDCellContent(buttonAction: @escaping () -> Void) -> AnyView {
        AnyView(
            VStack(alignment: .leading) {
                Text(viewModel.isAddingDevice ? UserText.subscriptionAvailableInApple : UserText.subscriptionActivateAppleIDDescription)
                    .daxSubheadRegular()
                    .foregroundColor(Color(designSystemColor: .textSecondary))
                if !viewModel.isAddingDevice {
                    getCellButton(buttonText: UserText.subscriptionActivateAppleIDButton, action: buttonAction)
                }
            }
        )
    }
    
    private func getEmailCellContent(buttonAction: @escaping () -> Void) -> AnyView {
        AnyView(
                VStack(alignment: .leading) {
                    if viewModel.subscriptionEmail == nil {
                        Text(UserText.subscriptionActivateEmailDescription)
                            .daxSubheadRegular()
                            .foregroundColor(Color(designSystemColor: .textSecondary))
                        getCellButton(buttonText: UserText.subscriptionRestoreEmail,
                                                    action: buttonAction)
                    } else {
                        Text(viewModel.subscriptionEmail ?? "").daxSubheadSemibold()
                        Text(UserText.subscriptionActivateEmailDescription)
                            .daxSubheadRegular()
                            .foregroundColor(Color(designSystemColor: .textSecondary))
                        HStack {
                            getCellButton(buttonText: UserText.subscriptionManageEmailButton,
                                                        action: buttonAction)
                            /* TO BE IMPLEMENTED ??
                            Spacer()
                            Button(action: {}, label: {
                                Text(UserText.subscriptionManageEmailResendInstructions).daxButton().daxBodyBold()
                            })
                            */
                        }
                    }
                }
            )
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
            .padding(.top, Constants.cellPadding)
        )
    }
                
    private func getTransactionStatus() -> String {
        switch viewModel.transactionStatus {
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
            Text(viewModel.isAddingDevice ? UserText.subscriptionAddDeviceHeaderTitle : UserText.subscriptionActivateTitle)
                .daxHeadline()
                .multilineTextAlignment(.center)
                .foregroundColor(Color(designSystemColor: .textPrimary))
            Text(viewModel.isAddingDevice ? UserText.subscriptionAddDeviceDescription : UserText.subscriptionActivateDescription)
                .daxFootnoteRegular()
                .foregroundColor(Color(designSystemColor: .textSecondary))
                .multilineTextAlignment(.center)
        }.padding(Constants.headerPadding)
    }
    
    private var listView: some View {
        List {
            Section {
                ForEach(Array(zip(listItems.indices, listItems)), id: \.1.id) { _, item in
                    VStack(alignment: .leading, spacing: Constants.cellLineSpacing) {
                        HStack {
                            item.content
                            Spacer()
                            Image(systemName: expandedItemId == item.id ? Constants.openIndicator : Constants.closedIndicator)
                                .foregroundColor(Color(designSystemColor: .textPrimary))
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            expandedItemId = expandedItemId == item.id ? 0 : item.id
                        }
                        if expandedItemId == item.id {
                            item.expandedContent
                        }
                    }.padding(Constants.cellPadding)
                }
            }
        }
    }
        
    private func getAlert() -> Alert {
        switch viewModel.activationResult {
        case .activated:
            return Alert(title: Text(UserText.subscriptionRestoreSuccessfulTitle),
                         message: Text(UserText.subscriptionRestoreSuccessfulMessage),
                         dismissButton: .default(Text(UserText.subscriptionRestoreSuccessfulButton)) {
                            dismiss()
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
        case .error:
            return Alert(title: Text("Error"), message: Text("An error occurred during activation."))
        default:
            return Alert(title: Text("Unknown"), message: Text("An unknown error occurred."))
        }
    }
    
    struct ListItem {
        let id: Int
        let content: AnyView
        let expandedContent: AnyView
    }
}
#endif
