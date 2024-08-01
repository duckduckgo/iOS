//
//  FeatureCardView.swift
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

struct FeatureCardView: View {
    var title: String
    var description: String
    var imageName: String
    var learnMoreAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .cornerRadius(10)
                .padding(.bottom, 10)

            Text(title)
                .font(.headline)
                .fontWeight(.bold)

            Text(description)
                .font(.subheadline)
                .foregroundColor(.gray)

            Button(action: learnMoreAction) {
                Text("Learn More")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
}

#Preview {
    FeatureCardView(title: "Privacy Pro Subscription",
                      description: "Discover 3 new ways to expand your privacy with our VPN, Personal Information Removal, & Identity Theft Restoration.",
                      imageName: "WhatsNewPrivacyPro",
                      learnMoreAction: {})
}
