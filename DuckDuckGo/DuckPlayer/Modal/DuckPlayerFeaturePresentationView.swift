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
import Lottie

struct DuckPlayerFeaturePresentationView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @State private var isAnimating: Bool = false
    var dismisPresentation: (() -> Void)?

    var body: some View {
        ZStack {

            VStack(alignment: .center, spacing: stackVerticalSpacing) {
                animation
                
                Text(UserText.duckPlayerPresentationModalTitle)
                    .daxTitle2()
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(designSystemColor: .textPrimary))
                    .minimumScaleFactor(0.8)

                Text(UserText.duckPlayerPresentationModalBody)
                    .daxBodyRegular()
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(designSystemColor: .textSecondary))
                    .minimumScaleFactor(0.8)

                Spacer()

                Button(UserText.duckPlayerPresentationModalDismissButton, action: dismissButtonTapped)
                    .buttonStyle(PrimaryButtonStyle())
                    .frame(maxWidth: 310)
            }
            .padding(.horizontal, 30)
            .padding(.top, contentVerticalPadding)
            .padding(.bottom)

            VStack {
                HStack {
                    Spacer()
                    Button(action: dismissButtonTapped) {
                        Image(systemName: "xmark")
                            .foregroundColor(Color(designSystemColor: .textPrimary))
                            .daxBodyRegular()
                            .frame(width: 30, height: 30)
                    }
                    .padding(8)
                }
                Spacer()
            }
        }
        .background(Color(designSystemColor: .backgroundSheets))
    }

    private func dismissButtonTapped() {
        dismisPresentation?()
    }

    @ViewBuilder
    private var animation: some View {
        LottieView(lottieFile: "DuckPlayer-ModalAnimation",
                   isAnimating: $isAnimating)
        .frame(width: Constants.heroImageSize.width, height: Constants.heroImageSize.height)
        .cornerRadius(8)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isAnimating = true
            }
        }
    }
}

extension DuckPlayerFeaturePresentationView {

    enum Constants {
        static let heroImageSize: CGSize = .init(width: 302, height: 180)
    }

    private var isSpaceConstrained: Bool {
        verticalSizeClass == .compact
    }

    private var stackVerticalSpacing: CGFloat {
        if isSpaceConstrained {
            return 5
        } else {
            return 22
        }
    }

    private var contentVerticalPadding: CGFloat {
        if isSpaceConstrained {
            return 4
        } else {
            return 40
        }
    }
}

#Preview {
    DuckPlayerFeaturePresentationView()
}
