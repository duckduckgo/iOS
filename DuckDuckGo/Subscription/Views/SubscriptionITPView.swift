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

#if SUBSCRIPTION
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

@available(iOS 15.0, *)
struct SubscriptionITPView: View {
        
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = SubscriptionITPViewModel()
    @State private var shouldShowNavigationBar = false
    @State private var isShowingActivityView = false
    
    enum Constants {
        static let daxLogo = "Home"
        static let daxLogoSize: CGFloat = 24.0
        static let empty = ""
        static let navButtonPadding: CGFloat = 20.0
        static let backButtonImage = "chevron.left"
        static let shareImage = "SubscriptionShareIcon"
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    shareButton
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(UserText.subscriptionCloseButton) { dismiss() }
                }
            }
            .edgesIgnoringSafeArea(.all)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(!viewModel.shouldShowNavigationBar && !viewModel.isDownloadableContent).animation(.snappy)
            
            .onAppear(perform: {
                setUpAppearances()
                viewModel.initializeView()
            })
            
        }
        .tint(Color(designSystemColor: .textPrimary))
        
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
            
            // Show a dismiss button while the bar is not visible
            // But it should be hidden while performing a transaction
            if !shouldShowNavigationBar {
                HStack {
                    backButton.padding(.leading, Constants.navButtonPadding)
                    Spacer()
                    dismissButton
                }
            }
        
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
                    SubscriptionActivityViewController(activityItems: [viewModel.attachmentURL], applicationActivities: nil)
                }
        }
    }
    
    @ViewBuilder
    private var dismissButton: some View {
        Button(action: { dismiss() }, label: { Text(UserText.subscriptionCloseButton) })
        .padding(Constants.navButtonPadding)
        .contentShape(Rectangle())
        .tint(Color(designSystemColor: .textPrimary))
    }
    
    
    private func setUpAppearances() {
        let navAppearance = UINavigationBar.appearance()
        navAppearance.backgroundColor = UIColor(designSystemColor: .surface)
        navAppearance.barTintColor = UIColor(designSystemColor: .surface)
        navAppearance.shadowImage = UIImage()
        navAppearance.tintColor = UIColor(designSystemColor: .textPrimary)
    }
}

 @available(iOS 15.0, *)
 struct SubscriptionITPView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionITPView()
    }
 }

#endif
