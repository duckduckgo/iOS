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

@available(iOS 15.0, *)
struct SubscriptionFlowView: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = SubscriptionFlowViewModel()
    @State private var showNestedViews = true
    @State private var isAlertVisible = false
    @State private var shouldShowNavigationBar = false
    @State private var isActive: Bool = false
    
    enum Constants {
        static let daxLogo = "Home"
        static let daxLogoSize: CGFloat = 24.0
        static let empty = ""
        static let navButtonPadding: CGFloat = 20.0
        static let backButtonImage = "chevron.left"
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
                .navigationBarHidden(!viewModel.shouldShowNavigationBar).animation(.easeOut)
        }
        .tint(Color(designSystemColor: .textPrimary))
        .environment(\.rootPresentationMode, self.$isActive)
        
    }
    
    @ViewBuilder
    private var dismissButton: some View {
        Button(action: { viewModel.finalizeSubscriptionFlow() }, label: { Text(UserText.subscriptionCloseButton) })
        .padding(Constants.navButtonPadding)
        .contentShape(Rectangle())
        .tint(Color(designSystemColor: .textPrimary))
    }
    
    @ViewBuilder
    private var backButton: some View {
        if viewModel.canNavigateBack {
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
    
    
    @ViewBuilder
    private var baseView: some View {
        ZStack(alignment: .top) {
            webView
                        
            // Show a dismiss button while the bar is not visible
            // But it should be hidden while performing a transaction
            if !shouldShowNavigationBar && viewModel.transactionStatus == .idle {
                HStack {
                    backButton.padding(.leading, Constants.navButtonPadding)
                    Spacer()
                    dismissButton
                }
            }
        }
        
        .onChange(of: viewModel.hasActiveSubscription) { result in
            if result {
                isAlertVisible = true
            }
        }
        
        .onChange(of: viewModel.shouldDismissView) { result in
            if result {
                dismiss()
                viewModel.shouldDismissView = false
            }
        }
        
        .onChange(of: viewModel.activatingSubscription) { value in
            if value {
                isActive = true
                viewModel.activatingSubscription = false
            }
        }
        
        .onAppear(perform: {
            setUpAppearances()
            Task { await viewModel.initializeViewData() }
            
        })
        
        .alert(isPresented: $isAlertVisible) {
            Alert(
                title: Text(UserText.subscriptionFoundTitle),
                message: Text(UserText.subscriptionFoundText),
                primaryButton: .cancel(Text(UserText.subscriptionFoundCancel)) {
                },
                secondaryButton: .default(Text(UserText.subscriptionFoundRestore)) {
                    viewModel.restoreAppstoreTransaction()
                }
            )
        }
        // The trailing close button should be hidden when a transaction is in progress
        .navigationBarItems(trailing: viewModel.transactionStatus == .idle
                            ? Button(UserText.subscriptionCloseButton) { viewModel.finalizeSubscriptionFlow() }
                            : nil)
    }
    
    @ViewBuilder
    private var webView: some View {
        
        ZStack(alignment: .top) {
            // Restore View Hidden Link
            NavigationLink(destination: SubscriptionRestoreView(), isActive: $isActive) {
                EmptyView()
            }.isDetailLink(false)
            
            AsyncHeadlessWebView(viewModel: viewModel.webViewModel)
                .background()
            
            if viewModel.transactionStatus != .idle {
                PurchaseInProgressView(status: getTransactionStatus())
            }

        }
    }
        
    private func setUpAppearances() {
        let navAppearance = UINavigationBar.appearance()
        navAppearance.backgroundColor = UIColor(designSystemColor: .surface)
        navAppearance.barTintColor = UIColor(designSystemColor: .surface)
        navAppearance.shadowImage = UIImage()
        navAppearance.tintColor = UIColor(designSystemColor: .textPrimary)
    }

}
#endif
