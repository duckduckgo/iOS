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
            ZStack {
                VStack(alignment: .center, spacing: stackVerticalSpacing) {
                    Image(systemName: "video")
                        .frame(width: heroImageSize.width, height: heroImageSize.height)
                        .background(Color.red)

                    Text(UserText.duckPlayerPresentationModalTitle)
                        .daxTitle3()
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(designSystemColor: .textPrimary))
                        .minimumScaleFactor(0.8)

                    Text(UserText.duckPlayerPresentationModalBody)
                        .daxBodyRegular()
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(designSystemColor: .textSecondary))
                        .minimumScaleFactor(0.8)

                    Button(UserText.duckPlayerPresentationModalDismissButton, action: dismissButtonTapped)
                        .buttonStyle(PrimaryButtonStyle())
                        .frame(maxWidth: 310)
                }
                .padding(.horizontal, 20)

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
            .padding()

            .background(Color(designSystemColor: .backgroundSheets))
        }

    func dismissButtonTapped() {
        print("Dismiss")
    }
}

extension DuckPlayerFeaturePresentationView {

    private var canAdjustSizeDynamically: Bool {
        if #available(iOS 16.0, *) {
            return true
        } else {
            return false
        }
    }

    private var heroImageSize: CGSize {
        if canAdjustSizeDynamically {
            return .init(width: 260, height: 180)
        } else {
            return .init(width: 240, height: 160)
        }
    }

    private var stackVerticalSpacing: CGFloat {
        if canAdjustSizeDynamically {
            return 22
        } else {
            return 18
        }
    }
}

#Preview {
    DuckPlayerFeaturePresentationView()
}
