//
//  PasswordGenerationPromptView.swift
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

import SwiftUI
import DuckUI

struct PasswordGenerationPromptView: View {

    @State var frame: CGSize = .zero
    @ObservedObject var viewModel: PasswordGenerationPromptViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @State private var orientation = UIDevice.current.orientation


    var body: some View {
        GeometryReader { geometry in
            makeBodyView(geometry)
        }
        .padding(.horizontal, isIPhonePortrait ? 16 : 48)
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            orientation = UIDevice.current.orientation
        }
    }

    private func makeBodyView(_ geometry: GeometryProxy) -> some View {
        DispatchQueue.main.async { self.frame = geometry.size }

        return ZStack {
            closeButtonHeader
                .offset(x: isIPhonePortrait ? 16 : 48)

            VStack {
                titleHeaderView
                Spacer()
                HStack(spacing: 10) {
                    Text(viewModel.generatedPassword)
                            .textSelectionEnabled()
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .setKerning(0)
                            .font(Const.Fonts.password)
                            .secondaryTextStyle()
                    Button {
                        UIPasteboard.general.string = viewModel.generatedPassword
                        presentCopyConfirmation(message: UserText.autofillCopyToastPasswordCopied)
                    } label: {
                        Image("Copy")
                            .foregroundColor(Const.Colors.SecondaryTextColor)
                    }
                    .buttonStyle(.plain) // Prevent taps from being forwarded to the container view
                }
                Spacer()
                Text(UserText.autofillPasswordGenerationPromptSubtitle)
                        .font(Const.Fonts.subtitle)
                        .secondaryTextStyle()
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, isSmallFrame ? Const.Size.paddingSmallDevice : Const.Size.paddingDefault)
                        .fixedSize(horizontal: false, vertical: true)
                Spacer()
                ctaView
                Spacer()
                    .frame(height: 24)
            }
        }
    }

    private func presentCopyConfirmation(message: String) {
        DispatchQueue.main.async {
            ActionMessageView.present(message: message,
                                      actionTitle: "",
                                      onAction: {})
        }
    }

    var closeButtonHeader: some View {
        VStack {
            HStack {
                Spacer()
                closeButton
                    .padding(5)
            }
            Spacer()
        }
    }

    private var closeButton: some View {
        Button {
            viewModel.cancelButtonPressed()
        } label: {
            Image(systemName: "xmark")
                .resizable()
                .scaledToFit()
                .frame(width: Const.Size.closeButtonSize, height: Const.Size.closeButtonSize)
                .foregroundColor(.primary)
        }
        .frame(width: Const.Size.closeButtonTappableArea, height: Const.Size.closeButtonTappableArea)
        .contentShape(Rectangle())
    }

    var titleHeaderView: some View {
        VStack(spacing: 0) {
            Text(UserText.autofillPasswordGenerationPromptTitle)
                .font(Const.Fonts.title)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, isSmallFrame ? 12 : 56)
        }
        .frame(width: isIPhone ? Const.Size.contentWidth : frame.width)
    }

    var ctaView: some View {
        VStack(spacing: 8) {
            Button {
                viewModel.useGeneratedPasswordPressed()
            } label: {
                Text(UserText.autofillPasswordGenerationPromptUseGeneratedPasswordCTA)
                        .font(Const.Fonts.CTA)
                        .padding()
                        .frame(minWidth: 0, maxWidth: .infinity, maxHeight: Const.Size.CTAButtonMaxHeight - Const.Size.buttonBorderWidth)
                        .foregroundColor(Const.Colors.CTAPrimaryForeground)
                        .background(Const.Colors.CTAPrimaryBackground)
                        .cornerRadius(Const.Size.CTAButtonCornerRadius)
            }

            Button {
                viewModel.cancelButtonPressed()
            } label: {
                Text(UserText.autofillPasswordGenerationPromptUseOwnPasswordCTA)
                        .font(Const.Fonts.CTA)
                        .padding()
                        .frame(minWidth: 0, maxWidth: .infinity, maxHeight: Const.Size.CTAButtonMaxHeight - Const.Size.buttonBorderWidth)
                        .foregroundColor(Const.Colors.CTASecondaryForeground)
                        .background(Const.Colors.CTATertiaryBackground)
                        .cornerRadius(Const.Size.CTAButtonCornerRadius)
            }
        }
        .padding(.horizontal, isSmallFrame ? Const.Size.paddingCtaSmallDevice : Const.Size.paddingCtaDefault)
    }


    // We have specific layouts for the smaller iPhones
    private var isSmallFrame: Bool {
        frame.width <= Const.Size.smallDevice || frame.height <= Const.Size.smallDevice
    }

    private var isIPhonePortrait: Bool {
        verticalSizeClass == .regular && horizontalSizeClass == .compact
    }

    private var isIPhone: Bool {
        verticalSizeClass == .compact || horizontalSizeClass == .compact
    }

    private var isIPad: Bool {
        verticalSizeClass == .regular && horizontalSizeClass == .regular
    }

}

struct PasswordGenerationPromptView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = PasswordGenerationPromptViewModel(generatedPassword: "GeNeRaTeD-pAsSwOrD")
        PasswordGenerationPromptView(viewModel: viewModel)
    }
}

extension View {

    @ViewBuilder
    internal func setKerning(_ kerning: CGFloat) -> some View {
        if #available(iOS 16.0, *) {
            self.kerning(kerning)
        } else {
            self
        }
    }

    @ViewBuilder
    internal func textSelectionEnabled() -> some View {
        if #available(iOS 15.0, *) {
            self.textSelection(.enabled)
        }
    }

}

private enum Const {
    enum Fonts {
        static let title = Font.system(.title3).weight(.bold)
        static let subtitle = Font.system(.footnote)
        static let password = Font.system(.callout, design: .monospaced)
        static let CTA = Font(UIFont.boldAppFont(ofSize: 16))
    }

    enum Size {
        static let contentWidth: CGFloat = 286
        static let closeButtonSize: CGFloat = 13
        static let closeButtonTappableArea: CGFloat = 44
        static let smallDevice: CGFloat = 320

        static let paddingSmallDevice: CGFloat = 28
        static let paddingDefault: CGFloat = 36
        static let paddingCtaSmallDevice: CGFloat = 20
        static let paddingCtaDefault: CGFloat = 28
        static let CTAButtonCornerRadius: CGFloat = 12
        static let buttonBorderWidth: CGFloat = 2
        static let CTAButtonMaxHeight: CGFloat = 50
    }

    enum Colors {
        static let CTAPrimaryBackground = Color("CTAPrimaryBackground")
        static let CTATertiaryBackground = Color("CTATertiaryBackground")
        static let CTAPrimaryForeground = Color("CTAPrimaryForeground")
        static let CTASecondaryForeground = Color("CTASecondaryForeground")
        static let SecondaryTextColor = Color("SecondaryTextColor")
    }

}
