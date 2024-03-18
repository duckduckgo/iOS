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
import Core

@available(iOS 15.0, *)
struct SubscriptionEmailView: View {
        
    @StateObject var viewModel = SubscriptionEmailViewModel()
    @Environment(\.dismiss) var dismiss
    
    @State var shouldDisplayInactiveError = false
    @State var shouldDisplayNavigationError = false
    @State var isModal = true
    
    var onDismissStack: (() -> Void)?
    
    enum Constants {
        static let navButtonPadding: CGFloat = 20.0
        static let backButtonImage = "chevron.left"
    }
        
    var body: some View {
        baseView
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                browserBackButton
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                closeButton
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationViewStyle(.stack)
        .navigationBarBackButtonHidden(true)
        .tint(Color.init(designSystemColor: .textPrimary))
        .accentColor(Color.init(designSystemColor: .textPrimary))
        
        .alert(isPresented: $shouldDisplayInactiveError) {
            Alert(
                title: Text(UserText.subscriptionRestoreEmailInactiveTitle),
                message: Text(UserText.subscriptionRestoreEmailInactiveMessage),
                dismissButton: .default(Text(UserText.actionOK)) {
                    viewModel.dismissView()
                }
            )
        }
        
        .alert(isPresented: $shouldDisplayNavigationError) {
            Alert(
                title: Text(UserText.subscriptionBackendErrorTitle),
                message: Text(UserText.subscriptionBackendErrorMessage),
                dismissButton: .cancel(Text(UserText.subscriptionBackendErrorButton)) {
                    viewModel.dismissView()
                })
        }
        
        .onAppear {
            viewModel.onAppear()
        }
                
        .onChange(of: viewModel.state.shouldDisplayInactiveError) { value in
            shouldDisplayInactiveError = value
        }
        
        .onChange(of: viewModel.state.shouldDisplaynavigationError) { value in
            shouldDisplayNavigationError = value
        }
        
        // Observe changes to shouldDismissView
        .onChange(of: viewModel.state.shouldDismissView) { shouldDismiss in
            if shouldDismiss {
                dismiss()

                // Reset shouldDismissView after dismissal to ensure it can trigger again
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    viewModel.resetDismissalState()
                }
            }
        }
        
        .navigationTitle(viewModel.viewTitle)
        
        .onAppear(perform: {
            setUpAppearances()
            viewModel.onAppear()
        })
        
    }
    
    // MARK: -
    
    @ViewBuilder
    private var closeButton: some View {
        if isModal {
            Button(UserText.subscriptionCloseButton) { onDismissStack?() }
        }
    }
    
    private var baseView: some View {
        ZStack {
            VStack {
                AsyncHeadlessWebView(viewModel: viewModel.webViewModel)
                    .background()
            }
        }
    }
    
    @ViewBuilder
    private var browserBackButton: some View {
        if viewModel.shouldDisplayBackButton() {
            Button(action: {
                Task { await viewModel.navigateBack() }
            }, label: {
                HStack(spacing: 0) {
                    Image(systemName: Constants.backButtonImage)
                    Text(UserText.backButtonTitle).foregroundColor(Color(designSystemColor: .textPrimary))
                }
            })
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

// Commented out because CI fails if a SwiftUI preview is enabled https://app.asana.com/0/414709148257752/1206774081310425/f
// @available(iOS 15.0, *)
// struct SubscriptionEmailView_Previews: PreviewProvider {
//    static var previews: some View {
//        SubscriptionEmailView()
//    }
// }

#endif
