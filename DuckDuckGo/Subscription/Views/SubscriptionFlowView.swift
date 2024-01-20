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

@available(iOS 15.0, *)
struct SubscriptionFlowView: View {
        
    @ObservedObject var viewModel: SubscriptionFlowViewModel
    @State private var isAlertVisible = false
    @State private var isRestoringSubscription = false
    
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
    
    var body: some View {
        ZStack {
            AsyncHeadlessWebView(url: $viewModel.purchaseURL,
                                 userScript: viewModel.userScript,
                                 subFeature: viewModel.subFeature,
                                 shouldReload: $viewModel.shouldReloadWebView).background()

            // Overlay that appears when transaction is in progress
            if viewModel.transactionStatus != .idle {
                PurchaseInProgressView(status: getTransactionStatus())
            }
         
            // Activation View
            NavigationLink(destination: SubscriptionRestoreView(viewModel: SubscriptionRestoreViewModel(), isActivatingSubscription: $viewModel.activatingSubscription),
                           isActive: $viewModel.activatingSubscription) {
                EmptyView()
            }
        }
        .onChange(of: viewModel.shouldReloadWebView) { shouldReload in
            if shouldReload {
                viewModel.shouldReloadWebView = false
            }
        }
        .onChange(of: viewModel.hasActiveSubscription) { result in
            if result {
                isAlertVisible = true
            }
        }
        
        .onAppear(perform: {
            Task { await viewModel.initializeViewData() }
        })
        .navigationTitle(viewModel.viewTitle)
        .navigationBarBackButtonHidden(viewModel.transactionStatus != .idle)
        
        // Active subscription found Alert
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
        .navigationBarBackButtonHidden(viewModel.transactionStatus != .idle)
    }
}
#endif
