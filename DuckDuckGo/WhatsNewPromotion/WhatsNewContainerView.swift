//
//  WhatsNewContainerView.swift
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

struct WhatsNewContainerView: View {

    var viewModel: WhatsNewViewModel?

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    viewModel?.closeAction?()
                }, label: {
                    Image("Close-24")
                        .foregroundColor(.black)
                })
                .font(.system(size: 20, weight: .bold))
            }
            .padding()

            Image("Home")
                .resizable()
                .frame(width: 48, height: 48)

            Text("What's New in DuckDuckGo")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.top, 8)

            Spacer().frame(height: 20)

            ScrollView {
                switch viewModel?.variant {
                case .a:
                    WhatsNewVariantAView(featureSelected: viewModel?.featureSelectedAction)
                case .b:
                    WhatsNewVariantAView(featureSelected: viewModel?.featureSelectedAction)
                case nil:
                    EmptyView()
                }
            }

            Spacer()

            Button(action: {
                viewModel?.closeAction?()
            }, label: {
                HStack {
                    Image("Rocket-24")
                    Text("Continue Browsing")
                        .font(.headline)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(Color(designSystemColor: .backgroundSheets))
                .cornerRadius(10)


            })
            .padding(.bottom, 20)
        }
        .padding()
    }
}

#Preview {
    WhatsNewContainerView()
}
