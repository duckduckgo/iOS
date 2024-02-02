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
        
    @StateObject var viewModel = SubscriptionEmailViewModel()
    @Environment(\.dismiss) var dismiss
    @Environment(\.rootPresentationMode) private var rootPresentationMode: Binding<RootPresentationMode>
    @State private var isActive: Bool = false
    @State var isAddingDevice = false
    
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
                // If updating email, just go back
                if isAddingDevice {
                    dismiss()
                } else {
                    // Pop to Root view
                    self.rootPresentationMode.wrappedValue.dismiss()
                }
            }
        }
        .navigationTitle(viewModel.viewTitle)
    }
}
#endif
