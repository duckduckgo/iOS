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
    @State var context: DuckPlayerModalPresenter.PresentationContext
    var dismisPresentation: (() -> Void)?

    var body: some View {
        ZStack {

            VStack(alignment: .center, spacing: stackVerticalSpacing) {
                animation
                
                Text(context == .SERP
                     ? UserText.duckPlayerPresentationModalTitle
                     : UserText.duckPlayerPresentationModalTitleYouTube)
                    .daxTitle2()
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(designSystemColor: .textPrimary))
                    .minimumScaleFactor(Constants.textMinimumScaleFactor)
                
                Text(UserText.duckPlayerPresentationModalBody)
                    .daxBodyRegular()
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(designSystemColor: .textSecondary))
                    .minimumScaleFactor(Constants.textMinimumScaleFactor)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                Button(UserText.duckPlayerPresentationModalDismissButton, action: dismissButtonTapped)
                    .buttonStyle(PrimaryButtonStyle())
                    .frame(maxWidth: Constants.buttonCTAMaxWidth)
            }
            .padding(.horizontal, Constants.horizontalPadding)
            .padding(.top, contentVerticalPadding)
            .padding(.bottom)

            VStack {
                HStack {
                    Spacer()
                    Button(action: dismissButtonTapped) {
                        Image(systemName: Constants.closeButtonSystemImage)
                            .foregroundColor(Color(designSystemColor: .textPrimary))
                            .daxBodyRegular()
                            .frame(width: Constants.closeButtonSize.width, height: Constants.closeButtonSize.height)
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
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.animationDelay) {
                isAnimating = true
            }
        }
    }
}

extension DuckPlayerFeaturePresentationView {

    enum Constants {
        static let heroImageSize: CGSize = .init(width: 302, height: 180)
        static let closeButtonSystemImage = "xmark"
        static let closeButtonSize: CGSize = .init(width: 30, height: 30)
        static let buttonCTAMaxWidth: CGFloat = 310
        static let textMinimumScaleFactor: CGFloat = 0.8
        static let horizontalPadding: CGFloat = 30
        static let animationDelay: Double = 2
    }

    private var isSpaceConstrained: Bool {
        verticalSizeClass == .compact
    }

    private var stackVerticalSpacing: CGFloat {
        isSpaceConstrained ? 5 : 22
    }

    private var contentVerticalPadding: CGFloat {
        isSpaceConstrained ? 4 : 40
    }
}

#Preview {
    DuckPlayerFeaturePresentationView(context: .SERP)
}
