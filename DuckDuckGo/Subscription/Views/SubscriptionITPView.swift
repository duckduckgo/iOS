//
//  SubscriptionITPView.swift
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

import SwiftUI
import Foundation
import DesignResourcesKit

struct SubscriptionActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]?

    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct SubscriptionITPView: View {
        
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = SubscriptionITPViewModel(subscriptionManager: AppDependencyProvider.shared.subscriptionManager)
    @State private var shouldShowNavigationBar = false
    @State private var isShowingActivityView = false
    
    enum Constants {
        static let empty = ""
        static let navButtonPadding: CGFloat = 20.0
        static let backButtonImage = "chevron.left"
        static let shareImage = "SubscriptionShareIcon"
    }
    
    var body: some View {
        
        baseView
        
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                backButton
            }
            ToolbarItem(placement: .principal) {
                DaxLogoNavbarTitle()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                shareButton
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarBackButtonHidden(viewModel.canNavigateBack)
        .navigationBarTitleDisplayMode(.inline)
        .tint(Color(designSystemColor: .textPrimary))
        
        .onFirstAppear {
            viewModel.onFirstAppear()
            setUpAppearances()
        }
        
        .alert(isPresented: $viewModel.navigationError) {
            Alert(
                title: Text(UserText.subscriptionBackendErrorTitle),
                message: Text(UserText.subscriptionBackendErrorMessage),
                dismissButton: .cancel(Text(UserText.subscriptionBackendErrorButton)) {
                    dismiss()
                })
        }
        
        
        .sheet(isPresented: Binding(
            get: { viewModel.shouldShowExternalURLSheet },
            set: { if !$0 { viewModel.shouldNavigateToExternalURL = nil } }
        )) {
            if let url = viewModel.shouldNavigateToExternalURL {
                SubscriptionExternalLinkView(viewModel: viewModel.getExternalLinksViewModel(url: url))
            }
        }
    }
    
    private var baseView: some View {
        ZStack(alignment: .top) {
            webView
        }
    }

    @ViewBuilder
    private var webView: some View {
        
        ZStack(alignment: .top) {
            AsyncHeadlessWebView(viewModel: viewModel.webViewModel)
                .background()
        }
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
    
    @ViewBuilder
    private var shareButton: some View {
        if viewModel.isDownloadableContent {
            Button(action: { isShowingActivityView = true }, label: { Image(Constants.shareImage) })
                .popover(isPresented: $isShowingActivityView, arrowEdge: .bottom) {
                    SubscriptionActivityViewController(activityItems: [viewModel.attachmentURL ?? ""], applicationActivities: nil)
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

// Commented out because CI fails if a SwiftUI preview is enabled https://app.asana.com/0/414709148257752/1206774081310425/f
// struct SubscriptionITPView_Previews: PreviewProvider {
//    static var previews: some View {
//        SubscriptionITPView()
//    }
// }
