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
    
    private func getTransactionStatus() -> String {
        switch viewModel.transactionStatus {
        case .polling:
            return UserText.privacyProCompletingPurchaseTitle
        case .purchasing:
            return UserText.privacyProPurchasingSubscriptionTitle
        case .restoring:
            return UserText.privacyProPestoringSubscriptionTitle
        case .idle:
            return ""
        }
    }
    
    var body: some View {
        ZStack {
            AsyncHeadlessWebView(url: $viewModel.purchaseURL,
                                 userScript: viewModel.userScript,
                                 subFeature: viewModel.subFeature,
                                 shouldReload: $viewModel.shouldReloadWebview).background()

            // Overlay that appears when transaction is in progress
            if viewModel.transactionStatus != .idle {
                PurchaseInProgressView(status: getTransactionStatus())
            }
        }
        .onChange(of: viewModel.shouldReloadWebview) { shouldReload in
            if shouldReload {
                viewModel.shouldReloadWebview = false
            }
        }
        .onChange(of: viewModel.shouldReloadWebview) { shouldReload in
            if shouldReload {
                viewModel.shouldReloadWebview = false
            }
        }
        .onAppear(perform: {
            Task { await viewModel.initializeViewData() }
        })
        .navigationTitle(viewModel.viewTitle)
        .navigationBarBackButtonHidden(viewModel.transactionStatus != .idle)
        
        // Active subscription found Alert
        .alert(isPresented: $viewModel.hasActiveSubscription) {
            Alert(
                title: Text("Subscription Found"),
                message: Text("We found a subscription associated with this Apple ID."),
                primaryButton: .cancel(Text("Cancel")) {
                    // TODO: Handle subscription Restore cancellation
                },
                secondaryButton: .default(Text("Restore")) {
                    viewModel.restoreAppstoreTransaction()
                }
            )
        }
        .navigationBarBackButtonHidden(viewModel.transactionStatus != .idle)
    }
}
#endif
