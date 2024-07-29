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

import SwiftUI
import Foundation
import Core
import Combine

struct SubscriptionEmailView: View {
        
    @StateObject var viewModel: SubscriptionEmailViewModel
    @EnvironmentObject var subscriptionNavigationCoordinator: SubscriptionNavigationCoordinator
    @Environment(\.dismiss) var dismiss
        
    @State var isPresentingInactiveError = false
    @State var isPresentingNavigationError = false
    @State var backButtonText = UserText.backButtonTitle
    @State private var isShowingITR = false
    @State private var isShowingDBP = false
    @State private var isShowingNetP = false
    
    enum Constants {
        static let navButtonPadding: CGFloat = 20.0
        static let backButtonImage = "chevron.left"
    }
        
    var body: some View {
        // Hidden Navigation Links for Onboarding sections
        NavigationLink(destination: LazyView(NetworkProtectionRootView().navigationViewStyle(.stack)),
                       isActive: $isShowingNetP,
                       label: { EmptyView() })
        NavigationLink(destination: LazyView(SubscriptionITPView().navigationViewStyle(.stack)),
                       isActive: $isShowingITR,
                       label: { EmptyView() })
        NavigationLink(destination: LazyView(SubscriptionPIRView().navigationViewStyle(.stack)),
                       isActive: $isShowingDBP,
                       label: { EmptyView() })
                        
        baseView
        
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                browserBackButton
            }
            ToolbarItemGroup(placement: .principal) {
                daxLogoToolbarItem
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationViewStyle(.stack)
        .navigationBarBackButtonHidden(true)
        .tint(Color.init(designSystemColor: .textPrimary))
        .accentColor(Color.init(designSystemColor: .textPrimary))
        
        .alert(isPresented: $isPresentingInactiveError) {
            Alert(
                title: Text(UserText.subscriptionRestoreEmailInactiveTitle),
                message: Text(UserText.subscriptionRestoreEmailInactiveMessage),
                dismissButton: .default(Text(UserText.actionOK)) {
                    viewModel.dismissView()
                }
            )
        }
        
        .alert(isPresented: $isPresentingNavigationError) {
            Alert(
                title: Text(UserText.subscriptionBackendErrorTitle),
                message: Text(UserText.subscriptionBackendErrorMessage),
                dismissButton: .cancel(Text(UserText.subscriptionBackendErrorButton)) {
                    viewModel.dismissView()
                })
        }
                
        .onChange(of: viewModel.state.isPresentingInactiveError) { value in
            isPresentingInactiveError = value
        }
        
        .onChange(of: viewModel.state.shouldDisplaynavigationError) { value in
            isPresentingNavigationError = value
        }
        
        // Observe changes to shouldDismissView
        .onChange(of: viewModel.state.shouldDismissView) { shouldDismiss in
            if shouldDismiss {
                dismiss()
            }
        }
                
        .onChange(of: viewModel.state.shouldPopToSubscriptionSettings) { shouldDismiss in
            if shouldDismiss {
                subscriptionNavigationCoordinator.shouldPopToSubscriptionSettings = true
            }
        }
        
        .onChange(of: viewModel.state.shouldPopToAppSettings) { shouldDismiss in
            if shouldDismiss {
                subscriptionNavigationCoordinator.shouldPopToAppSettings = true
            }
        }
        
        .onChange(of: viewModel.state.selectedFeature) { feature in
            switch feature {
            case .dbp:
                self.isShowingDBP = true
            case .itr:
                self.isShowingITR = true
            case .netP:
                self.isShowingNetP = true
            default:
                break
            }
        }
        
        .navigationTitle(viewModel.state.viewTitle)
        
        .onFirstAppear {
            setUpAppearances()
            viewModel.onFirstAppear()
        }
        
        .onAppear {
            viewModel.onAppear()
        }
        
    }
    
    // MARK: -
    
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
        Button(action: {
            Task { await viewModel.navigateBack() }
        }, label: {
            HStack(spacing: 0) {
                Image(systemName: Constants.backButtonImage)
                Text(viewModel.state.backButtonTitle).foregroundColor(Color(designSystemColor: .textPrimary))
            }
        })
    }
    
    @ViewBuilder
    private var daxLogoToolbarItem: some View {
        if viewModel.state.viewTitle == UserText.subscriptionTitle {
            DaxLogoNavbarTitle()
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
// struct SubscriptionEmailView_Previews: PreviewProvider {
//    static var previews: some View {
//        SubscriptionEmailView()
//    }
// }
