//
//  AutofillViews.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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

import Foundation
import SwiftUI
import DesignResourcesKit

struct AutofillViews {

    static let loginPromptMinHeight: CGFloat = 200.0
    static let saveLoginMinHeight = 375.0
    static let savePasswordMinHeight = 340.0
    static let updateUsernameMinHeight = 310.0
    static let passwordGenerationMinHeight: CGFloat = 310.0
    static let emailSignupPromptMinHeight: CGFloat = 260.0

    struct CloseButtonHeader: View {
        let action: () -> Void

        var body: some View {
            VStack {
                HStack {
                    Spacer()
                    Button {
                        action()
                    } label: {
                        Image.close
                            .resizable()
                            .scaledToFit()
                            .frame(width: Const.Size.closeButtonSize, height: Const.Size.closeButtonSize)
                            .foregroundColor(Color(designSystemColor: .textPrimary))
                    }
                    .frame(width: Const.Size.closeButtonTappableArea, height: Const.Size.closeButtonTappableArea)
                    .contentShape(Rectangle())
                    .padding(Const.Size.closeButtonPadding)
                }
                Spacer()
            }
        }
    }

    struct AppIconHeader: View {
        var body: some View {
            Image.appIcon
                .scaledToFit()
        }
    }

    struct Headline: View {
        let title: String

        var body: some View {
            Text(title)
                .daxTitle3()
                .foregroundColor(Color(designSystemColor: .textPrimary))
                .frame(maxWidth: Const.Size.maxWidth)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    struct Description: View {
        let text: String

        var body: some View {
            Text(text)
                .daxFootnoteRegular()
                .foregroundColor(Color(designSystemColor: .textSecondary))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: Const.Size.maxWidth)
        }
    }

    struct PrimaryButton: View {
        let title: String
        let action: () -> Void

        var body: some View {
            Button {
                action()
            } label: {
                Text(title)
                    .daxButton()
                    .padding()
                    .frame(minWidth: 0, maxWidth: Const.Size.maxWidth)
                    .foregroundColor(.white)
                    .background(Color(designSystemColor: .accent))
                    .cornerRadius(Const.Size.buttonCornerRadius)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    struct SecondaryButton: View {
        let title: String
        let action: () -> Void

        var body: some View {
            Button {
                action()
            } label: {
                Text(title)
                    .daxButton()
                    .padding()
                    .frame(minWidth: 0, maxWidth: Const.Size.maxWidth)
                    .foregroundColor(Color(designSystemColor: .accent))
                    .cornerRadius(Const.Size.buttonCornerRadius)
                    .fixedSize(horizontal: false, vertical: true)
                    .overlay(
                        RoundedRectangle(cornerRadius: Const.Size.buttonCornerRadius)
                            .stroke(Color(designSystemColor: .accent),
                                    lineWidth: Const.Size.buttonBorderWidth)
                            .padding(1)
                    )

            }
        }
    }

    struct TertiaryButton: View {
        let title: String
        let action: () -> Void

        var body: some View {
            Button {
                action()
            } label: {
                Text(title)
                    .daxButton()
                    .padding()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .foregroundColor(Color(designSystemColor: .accent))
                    .cornerRadius(Const.Size.buttonCornerRadius)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    struct LegacySpacerView: View {
        let height: CGFloat?
        let legacyHeight: CGFloat?

        init(height: CGFloat? = nil, legacyHeight: CGFloat? = nil) {
            self.height = height
            self.legacyHeight = legacyHeight
        }

        var body: some View {
            if #available(iOS 16.0, *) {
                Spacer()
                    .frame(height: height)
            } else {
                Spacer()
                    .frame(height: legacyHeight)
            }
        }
    }

    static func isIPhonePortrait(_ verticalSizeClass: UserInterfaceSizeClass?, _ horizontalSizeClass: UserInterfaceSizeClass?) -> Bool {
        verticalSizeClass == .regular && horizontalSizeClass == .compact
    }

    static func isIPhoneLandscape(_ verticalSizeClass: UserInterfaceSizeClass?) -> Bool {
        verticalSizeClass == .compact
    }

    static func isIPad(_ verticalSizeClass: UserInterfaceSizeClass?, _ horizontalSizeClass: UserInterfaceSizeClass?) -> Bool {
        verticalSizeClass == .regular && horizontalSizeClass == .regular
    }

    // We have specific layouts for the smaller iPhones
    static func isSmallFrame(_ frame: CGSize) -> Bool {
        frame.width > 0 && frame.width <= Const.Size.smallDevice
    }

    static func contentHeightExceedsScreenHeight(_ contentHeight: CGFloat) -> Bool {
        if #available(iOS 16.0, *) {
            let topSafeAreaInset = UIApplication.shared.connectedScenes
                .compactMap { ($0 as? UIWindowScene)?.keyWindow }
                .first?
                .safeAreaInsets
                .top ?? 0.0
            return contentHeight > UIScreen.main.bounds.size.height - topSafeAreaInset
        } else {
            return false
        }
    }
}

extension View {
    @ViewBuilder
    func useScrollView(_ useScrollView: Bool, minHeight: CGFloat) -> some View {
        if useScrollView {
            ScrollView(showsIndicators: false) {
                self
            }
            .frame(minHeight: minHeight)
        } else {
            self
        }
    }
}

private enum Const {
    enum Size {
        static let closeButtonPadding: CGFloat = 5.0
        static let closeButtonSize: CGFloat = 24.0
        static let closeButtonTappableArea: CGFloat = 44.0
        static let logoImage: CGFloat = 20.0
        static let buttonCornerRadius: CGFloat = 8.0
        static let buttonBorderWidth: CGFloat = 1.0
        static let smallDevice: CGFloat = 320.0
        static let maxWidth: CGFloat = 480.0
    }
}

private extension Image {
    static let close = Image("Close-24")
    static let appIcon = Image("WaitlistShareSheetLogo")
}
