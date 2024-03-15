//
//  SubscriptionFlowView.swift
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

#if SUBSCRIPTION
import SwiftUI
import Foundation
import DesignResourcesKit
import Core

@available(iOS 15.0, *)
struct SubscriptionFlowView: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = SubscriptionFlowViewModel()

    // Local View State
    @State private var errorMessage: SubscriptionErrorMessage = .general
    @State private var shouldPresentError: Bool = false

    enum Constants {
        static let daxLogo = "Home"
        static let daxLogoSize: CGFloat = 24.0
        static let empty = ""
        static let navButtonPadding: CGFloat = 20.0
        static let backButtonImage = "chevron.left"
    }
    
    enum SubscriptionErrorMessage {
        case activeSubscription
        case appStore
        case backend
        case general
    }
    
    var body: some View {
        NavigationView {
            baseView
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        backButton
                    }
                    ToolbarItem(placement: .principal) {
                        HStack {
                            Image(Constants.daxLogo)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: Constants.daxLogoSize, height: Constants.daxLogoSize)
                            Text(viewModel.viewTitle).daxBodyRegular()
                        }
                    }
                }
                .edgesIgnoringSafeArea(.top)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarHidden(!viewModel.state.shouldShowNavigationBar).animation(.easeOut)
        }
        .applyInsetGroupedListStyle()
        .tint(Color(designSystemColor: .textPrimary))
    }

    @ViewBuilder
    private var dismissButton: some View {
        Button(action: {
            viewModel.finalizeSubscriptionFlow()
        }, label: { Text(UserText.subscriptionCloseButton) })
        .padding(Constants.navButtonPadding)
        .contentShape(Rectangle())
        .tint(Color(designSystemColor: .textPrimary))
    }
    
    @ViewBuilder
    private var backButton: some View {
        if viewModel.state.canNavigateBack {
            Button(action: {
                Task { await viewModel.navigateBack() }
            }, label: {
                HStack(spacing: 0) {
                    Image(systemName: Constants.backButtonImage)
                    Text(UserText.backButtonTitle)
                }
                
            })
        }
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
    
    
    @ViewBuilder
    private var baseView: some View {
        ZStack(alignment: .top) {
            webView
                        
            // Show a dismiss button while the bar is not visible
            // But it should be hidden while performing a transaction
            if !viewModel.state.shouldShowNavigationBar && viewModel.state.transactionStatus == .idle {
                HStack {
                    backButton.padding(.leading, Constants.navButtonPadding)
                    Spacer()
                    dismissButton
                }
            }
        }
        
        .onChange(of: viewModel.state.shouldDismissView) { result in
            if result {
                dismiss()
            }
        }
        
        .onChange(of: viewModel.state.transactionError) { value in
            
            if !shouldPresentError {
                let displayError: Bool = {
                    switch value {
                    case .hasActiveSubscription:
                        errorMessage = .activeSubscription
                        return true
                    case .failedToRestorePastPurchase, .purchaseFailed:
                        errorMessage = .appStore
                        return true
                    case .failedToGetSubscriptionOptions, .generalError:
                        errorMessage = .backend
                        return true
                    default:
                        return false
                    }
                }()
                
                if displayError {
                    shouldPresentError = true
                }
            }
        }
        
        .onAppear(perform: {
            setUpAppearances()
            Task { await viewModel.initializeViewData() }
            viewModel.onAppear()
        })
        
        .onDisappear(perform: {
            viewModel.onDisappear()
        })
                
        .alert(isPresented: $shouldPresentError) {
            getAlert(error: self.errorMessage)
            
        }
        
        // The trailing close button should be hidden when a transaction is in progress
        .navigationBarItems(trailing: viewModel.state.transactionStatus == .idle
                            ? Button(UserText.subscriptionCloseButton) { viewModel.finalizeSubscriptionFlow() }
                            : nil)
    }
        
    private func getAlert(error: SubscriptionErrorMessage) -> Alert {
        
        switch error {
        case .activeSubscription:
            return Alert(
                title: Text(UserText.subscriptionFoundTitle),
                message: Text(UserText.subscriptionFoundText),
                primaryButton: .cancel(Text(UserText.subscriptionFoundCancel)) {
                    viewModel.clearTransactionError()
                     viewModel.finalizeSubscriptionFlow()
                },
                secondaryButton: .default(Text(UserText.subscriptionFoundRestore)) {
                    viewModel.restoreAppstoreTransaction()
                }
            )
        case .appStore:
            return Alert(
                title: Text(UserText.subscriptionAppStoreErrorTitle),
                message: Text(UserText.subscriptionAppStoreErrorMessage),
                dismissButton: .cancel(Text(UserText.actionOK)) {
                    Task { await viewModel.initializeViewData() }
                }
            )
        case .backend, .general:
            return Alert(
                title: Text(UserText.subscriptionBackendErrorTitle),
                message: Text(UserText.subscriptionBackendErrorMessage),
                dismissButton: .cancel(Text(UserText.subscriptionBackendErrorButton)) {
                    viewModel.finalizeSubscriptionFlow()
                }
            )
        }
    }

    @ViewBuilder
    private var webView: some View {
        
        ZStack(alignment: .top) {

            AsyncHeadlessWebView(viewModel: viewModel.webViewModel)
                .background()
            
            if viewModel.state.transactionStatus != .idle {
                PurchaseInProgressView(status: getTransactionStatus())
            }
        }
    }

    private func setUpAppearances() {
        let navAppearance = UINavigationBar.appearance()
        navAppearance.backgroundColor = UIColor(designSystemColor: .background)
        navAppearance.barTintColor = UIColor(designSystemColor: .container)
        navAppearance.shadowImage = UIImage()
        navAppearance.tintColor = UIColor(designSystemColor: .textPrimary)
    }

}

// Commented out because CI fails if a SwiftUI preview is enabled https://app.asana.com/0/414709148257752/1206774081310425/f
// @available(iOS 15.0, *)
// struct SubscriptionFlowView_Previews: PreviewProvider {
//    static var previews: some View {
//        SubscriptionFlowView()
//    }
// }

#endif
