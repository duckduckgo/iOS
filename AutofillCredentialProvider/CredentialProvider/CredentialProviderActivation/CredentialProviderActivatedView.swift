//
//  CredentialProviderActivatedView.swift
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
import DesignResourcesKit
import DuckUI

struct CredentialProviderActivatedView: View {

    let viewModel: CredentialProviderActivatedViewModel
    @State private var imageAppeared = false

    var body: some View {
        NavigationView {

            VStack(spacing: 0) {

                Image(.passwordsDDG96X96)
                    .padding(.top, 48)
                    .scaleEffect(imageAppeared ? 1 : 0.7)
                    .animation(
                        .interpolatingSpring(stiffness: 170, damping: 10)
                        .delay(0.1),
                        value: imageAppeared
                    )
                    .onAppear {
                        imageAppeared = true
                    }

                Text(UserText.credentialProviderActivatedTitle)
                    .daxTitle2()
                    .foregroundColor(Color(designSystemColor: .textPrimary))
                    .padding(.top, 16)
                    .multilineTextAlignment(.center)

                Spacer()

                Button {
                    viewModel.launchDDGApp()
                } label: {
                    Text(UserText.credentialProviderActivatedButton)
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.bottom, 12)

            }
            .padding(.horizontal, 24)
            .navigationBarItems(trailing: Button(UserText.actionDone) {
                viewModel.dismiss()
            })
        }
    }
    
}

#Preview {
    CredentialProviderActivatedView(viewModel: CredentialProviderActivatedViewModel())
}
