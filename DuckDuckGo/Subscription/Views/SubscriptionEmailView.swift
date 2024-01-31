//
//  SubscriptionEmailView.swift
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

#if SUBSCRIPTION
import SwiftUI
import Foundation

@available(iOS 15.0, *)
struct SubscriptionEmailView: View {
        
    @ObservedObject var viewModel: SubscriptionEmailViewModel
    @Binding var isActivatingSubscription: Bool
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            VStack {
                AsyncHeadlessWebView(url: $viewModel.emailURL,
                                     userScript: viewModel.userScript,
                                     subFeature: viewModel.subFeature,
                                     shouldReload: $viewModel.shouldReloadWebView,
                                     onScroll: { position in
                                        print(position)}
                                    ).background()
            }
        }
        .onChange(of: viewModel.activateSubscription) { active in
            if active {
                // We just need to dismiss the current view
                if viewModel.managingSubscriptionEmail {
                    dismiss()
                } else {
                    // Update the binding to tear down the entire view stack
                    // This dismisses all views in between and takes you back to the welcome page
                    isActivatingSubscription = false
                }
            }
        }
        .navigationTitle(viewModel.viewTitle)
    }
    
    
}
#endif
