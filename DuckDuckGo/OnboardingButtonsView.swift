//
//  OnboardingButtonsView.swift
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

struct OnboardingActions: View {

    @ObservedObject var viewModel: Model

    var primaryAction: (() -> Void)?
    var secondaryAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 12) {
            Button(action: {
                self.primaryAction?()
            }, label: {
                Text(viewModel.primaryButtonTitle)
            })
            .buttonStyle(PrimaryButtonStyle())
            .disabled(!viewModel.isContinueEnabled)

            Button(action: {
                self.secondaryAction?()
            }, label: {
                Text(viewModel.secondaryButtonTitle)
            })
            .buttonStyle(SecondaryButtonStyle())
        }
    }
}

extension OnboardingActions {
    class Model: ObservableObject {
        @Published var primaryButtonTitle = ""
        @Published var secondaryButtonTitle = ""
        @Published var isContinueEnabled = true
    }
}
