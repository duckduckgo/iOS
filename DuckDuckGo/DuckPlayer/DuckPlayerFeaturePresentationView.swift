//
//  DuckPlayerFeaturePresentationView.swift
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

struct DuckPlayerFeaturePresentationView: View {
    var body: some View {
        List {
            ZStack {
                VStack(alignment: .center, spacing: 18) {
                    Image(systemName: "video")

                    Text(UserText.duckPlayerPresentationModalTitle)
                        .daxTitle3()
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(designSystemColor: .textPrimary))

                    Text(UserText.duckPlayerPresentationModalBody)
                        .daxBodyRegular()
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(designSystemColor: .textSecondary))

                    Button(UserText.duckPlayerPresentationModalDismissButton, action: dismissButtonTapped)
                        .buttonStyle(PrimaryButtonStyle())
                        .frame(maxWidth: 310)
                }

                VStack {
                    HStack {
                        Spacer()
                        Button(action: dismissButtonTapped) {
                            Image(systemName: "xmark")
                                .foregroundColor(Color(designSystemColor: .textPrimary))
                                .daxBodyRegular()
                        }
                    }
                    Spacer()
                }
            }
            .listRowBackground(Color.clear)

        }
        //.background(Color(designSystemColor: .backgroundSheets))
    }

    func dismissButtonTapped() {
        print("Dismiss")
    }
}

#Preview {
    DuckPlayerFeaturePresentationView()
}
