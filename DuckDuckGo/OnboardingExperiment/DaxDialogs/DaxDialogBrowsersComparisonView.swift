//
//  DaxDialogBrowsersComparisonView.swift
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

struct DaxDialogBrowsersComparisonView: View {

    let action: () -> Void

    var body: some View {
        DaxDialogView(logoPosition: .top) {
            VStack(alignment: .leading, spacing: 16.0) {
                Text(UserText.DaxOnboardingExperiment.BrowsersComparison.title)
                    .foregroundColor(.primary)
                    .font(Font.system(size: 20, weight: .bold))

                // Replace with BrowsersComparisonView
                RoundedRectangle(cornerRadius: 15.0)
                    .foregroundColor(.blue)
                    .overlay(Text("Placeholder"), alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)

                Button(action: action) {
                    Text(UserText.DaxOnboardingExperiment.BrowsersComparison.cta)
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
    }

}

// MARK: - Preview

#Preview("Browsers Comparison - Light Mode") {
    DaxDialogBrowsersComparisonView(action: {})
        .padding()
        .preferredColorScheme(.light)
}

#Preview("Browsers Comparison - Dark Mode") {
    DaxDialogBrowsersComparisonView(action: {})
        .padding()
        .preferredColorScheme(.dark)
}
