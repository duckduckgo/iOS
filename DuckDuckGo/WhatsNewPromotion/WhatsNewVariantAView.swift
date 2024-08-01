//
//  WhatsNewVariantAView.swift
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
import DuckUI

struct WhatsNewVariantAView: View {

    private var featureSelected: ((FeatureSelected) -> Void)?

    init(featureSelected: ((FeatureSelected) -> Void)?) {
        self.featureSelected = featureSelected
    }

    var body: some View {

        VStack(alignment: .leading, spacing: 15) {
            FeatureView(
                title: "Privacy Pro Subscription",
                description: "Discover 3 new ways to expand your privacy with our VPN, Personal Information Removal, and Identity Theft Restoration.",
                learnMoreAction: {
                    featureSelected?(.privacyPro)
                }
            )
            Divider()

            FeatureView(
                title: "Sync & Backup",
                description: "Auto-sync bookmarks, passwords, and Email Protection settings across all devices where you use our browser.",
                learnMoreAction: {
                    // Add action for Enable in Settings
                }
            )

            Divider()

            FeatureView(
                title: "Cookie Pop-Up Protection",
                description: "By default, our browser detects cookie pop-ups, selects the most private cookie settings, and hides the pop-ups.",
                learnMoreAction: {
                    // Add action for Learn More
                }
            )
        }
        .padding()
        .background(Color(designSystemColor: .panel))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(designSystemColor: .container), lineWidth: 2)
        )
        .padding(.horizontal)
    }
}

#Preview {
    WhatsNewVariantAView(featureSelected: {_ in })
}
