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

@available(iOS 15.0, *)
struct SubscriptionExternalLinkView: View {
        
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = SubscriptionExternalLinkViewModel()
        
    enum Constants {
        static let navButtonPadding: CGFloat = 20.0
    }
    
    
    var body: some View {
        NavigationView {
            baseView
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(UserText.subscriptionCloseButton) { dismiss() }
                }
            }
            .edgesIgnoringSafeArea(.all)
            .navigationBarTitleDisplayMode(.inline)
            
            .onAppear(perform: {
                setUpAppearances()
                viewModel.initializeView()
            })
        }.tint(Color(designSystemColor: .textPrimary))
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
    
    
    private func setUpAppearances() {
        let navAppearance = UINavigationBar.appearance()
        navAppearance.backgroundColor = UIColor(designSystemColor: .surface)
        navAppearance.barTintColor = UIColor(designSystemColor: .surface)
        navAppearance.shadowImage = UIImage()
        navAppearance.tintColor = UIColor(designSystemColor: .textPrimary)
    }
}
#endif
