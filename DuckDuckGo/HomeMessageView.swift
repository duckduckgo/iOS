//
//  HomeMessageView.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
import RemoteMessaging
import Core

struct HomeMessageView: View {

    struct ShareItem: Identifiable {
        var id: String {
            value
        }

        var item: Any {
            if let url = URL(string: value), let title = title {
                return TitledURLActivityItem(url, title)
            } else {
                return value
            }
        }

        let value: String
        let title: String?
    }

    let viewModel: HomeMessageViewModel

    @State var activityItem: ShareItem?

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 8) {
                Group {
                    topText

                    if case .promoSingleAction = viewModel.modelType {
                        title
                            .daxTitle3()
                            .padding(.top, 16)
                        image
                    } else {
                        image
                        title
                            .daxHeadline()
                    }

                    subtitle
                        .padding(.top, 8)
                }
                .padding(.horizontal, 24)

                HStack {
                    buttons
                }
                .padding(.top, 8)
                .padding(.horizontal, 8)
            }
            .multilineTextAlignment(.center)
            .padding(.vertical)
            .padding(.horizontal, 8)

            closeButtonHeader
                .alignmentGuide(.top) { dimension in
                    dimension[.top]
                }
        }
        .background(RoundedRectangle(cornerRadius: Const.Radius.corner)
                        .fill(Color.background)
                        .shadow(color: Color.shadow,
                                radius: Const.Radius.shadow,
                                x: 0,
                                y: Const.Offset.shadowVertical))
        .onAppear {
            viewModel.onDidAppear()
        }
    }

    private var closeButtonHeader: some View {
        VStack {
            HStack {
                Spacer()
                closeButton
                    .padding(0)
            }
        }
    }
    
    private var closeButton: some View {
        Button {
            viewModel.onDidClose(.close)
        } label: {
            Image("Close-24")
                .foregroundColor(.primary)
        }
        .frame(width: Const.Size.closeButtonWidth, height: Const.Size.closeButtonWidth)
        .contentShape(Rectangle())
    }
    
    private var topText: some View {
        Group {
            if let topText = viewModel.topText {
                Text(topText)
                    .font(Font(uiFont: Const.Font.topText))
            } else {
                EmptyView()
            }
        }
    }
    
    private var image: some View {
        Group {
            if let image = viewModel.image {
                Image(image)
                    .scaledToFit()
            } else {
                EmptyView()
            }
        }
    }

    private var title: some View {
        Text(viewModel.title)
            .padding(.top, Const.Spacing.imageAndTitle)
   }

    @ViewBuilder
    private var subtitle: some View {
        if #available(iOS 15, *), let attributed = try? AttributedString(markdown: viewModel.subtitle) {
            Text(attributed)
                .daxBodyRegular()
        } else {
            Text(viewModel.subtitle)
                .daxBodyRegular()
        }
    }

    private var buttons: some View {
        ForEach(viewModel.buttons, id: \.title) { buttonModel in
            Button {
                buttonModel.action()
                if case .share(let value, let title) = buttonModel.actionStyle {
                    activityItem = ShareItem(value: value, title: title)
                }
            } label: {
                HStack {
                    if case .share = buttonModel.actionStyle {
                        Image("Share-24")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                    Text(buttonModel.title)
                        .daxButton()
                }
            }
            .buttonStyle(HomeMessageButtonStyle(viewModel: viewModel, buttonModel: buttonModel))
            .padding([.bottom], Const.Padding.buttonVerticalInset)
            .sheet(item: $activityItem) { activityItem in
                ActivityViewController(activityItems: [activityItem.item]) { _, result, _, _ in

                    Pixel.fire(pixel: .remoteMessageSheet, withAdditionalParameters: [
                        PixelParameters.message: "\(viewModel.messageId)",
                        PixelParameters.sheetResult: "\(result)"
                    ])

                }
                .modifier(ActivityViewPresentationModifier())
            }

        }
    }
}

private struct HomeMessageButtonStyle: ButtonStyle {

    let viewModel: HomeMessageViewModel
    let buttonModel: HomeMessageButtonViewModel

    var foregroundColor: Color {
        if case .promoSingleAction = viewModel.modelType {
            return .cancelButtonForeground
        }

        if case .cancel = buttonModel.actionStyle {
            return .cancelButtonForeground
        }

        return .primaryButtonText
    }

    var backgroundColor: Color {
        if case .promoSingleAction = viewModel.modelType {
            return .cancelButtonBackground
        }

        if case .cancel = buttonModel.actionStyle {
            return .cancelButtonBackground
        }

        return .button
    }

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(.horizontal, Const.Padding.buttonHorizontal)
            .padding(.vertical, Const.Padding.buttonVertical)
            .frame(height: Const.Size.buttonHeight)
            .foregroundColor(configuration.isPressed ? foregroundColor.opacity(0.5) : foregroundColor)
            .background(backgroundColor)
            .cornerRadius(Const.Radius.corner)
    }
}

struct ActivityViewPresentationModifier: ViewModifier {

    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.presentationDetents([.medium])
        } else {
            content
        }
    }

}

private extension Color {
    static let button = Color(designSystemColor: .accent)
    static let primaryButtonText = Color("RemoteMessagePrimaryActionTextColor")
    static let cancelButtonBackground = Color("CancelButtonBackgroundColor")
    static let cancelButtonForeground = Color("CancelButtonForegroundColor")
    static let background = Color("HomeMessageBackgroundColor")
    static let shadow = Color("HomeMessageShadowColor")
}

private extension Image {
    static let dismiss = Image("HomeMessageDismissIcon")
}

private enum Const {
    enum Font {
        static let topText = UIFont.boldAppFont(ofSize: 13)
        static let title = UIFont.boldAppFont(ofSize: 17)
        static let subtitle = UIFont.appFont(ofSize: 15)
        static let button = UIFont.boldAppFont(ofSize: 15)
    }
    
    enum Radius {
        static let shadow: CGFloat = 3
        static let corner: CGFloat = 8
    }
    
    enum Padding {
        static let buttonHorizontal: CGFloat = 16
        static let buttonVertical: CGFloat = 9
        static let buttonVerticalInset: CGFloat = 8
        static let textHorizontalInset: CGFloat = 30
    }
    
    enum Spacing {
        static let imageAndTitle: CGFloat = 8
        static let titleAndSubtitle: CGFloat = 4
        static let subtitleAndButtons: CGFloat = 6
        static let line: CGFloat = 4
    }
    
    enum Size {
        static let closeButtonWidth: CGFloat = 44
        static let buttonHeight: CGFloat = 40
    }
    
    enum Offset {
        static let shadowVertical: CGFloat = 2
    }
}

struct HomeMessageView_Previews: PreviewProvider {

    static let small: RemoteMessageModelType =
        .small(titleText: "Small", descriptionText: "Description")

    static let critical: RemoteMessageModelType =
        .medium(titleText: "Critical",
                descriptionText: "Description text",
                placeholder: .criticalUpdate)

    static let bigSingle: RemoteMessageModelType =
        .bigSingleAction(titleText: "Big Single",
                         descriptionText: "This is a description",
                         placeholder: .ddgAnnounce,
                         primaryActionText: "Primary",
                         primaryAction: .dismiss)

    static let bigTwo: RemoteMessageModelType =
        .bigTwoAction(titleText: "Big Two",
                      descriptionText: "This is a <b>big</b> two style",
                      placeholder: .macComputer,
                      primaryActionText: "App Store",
                      primaryAction: .appStore,
                      secondaryActionText: "Dismiss",
                      secondaryAction: .dismiss)

    static let promo: RemoteMessageModelType =
        .promoSingleAction(titleText: "Promotional",
                           descriptionText: "Description <b>with bold</b> to make a statement.",
                           placeholder: .newForMacAndWindows,
                           actionText: "Share",
                           action: .share(value: "value", title: "title"))

    static var previews: some View {
        Group {
            HomeMessageView(viewModel: HomeMessageViewModel(messageId: "Small",
                                                            modelType: small,
                                                            onDidClose: { _ in }, onDidAppear: {}))

            HomeMessageView(viewModel: HomeMessageViewModel(messageId: "Critical",
                                                            modelType: critical,
                                                            onDidClose: { _ in }, onDidAppear: {}))

            HomeMessageView(viewModel: HomeMessageViewModel(messageId: "Big Single",
                                                            modelType: bigSingle,
                                                            onDidClose: { _ in }, onDidAppear: {}))

            HomeMessageView(viewModel: HomeMessageViewModel(messageId: "Big Two",
                                                            modelType: bigTwo,
                                                            onDidClose: { _ in }, onDidAppear: {}))

            HomeMessageView(viewModel: HomeMessageViewModel(messageId: "Promo",
                                                            modelType: promo,
                                                            onDidClose: { _ in }, onDidAppear: {}))
        }
        .frame(height: 200)
        .padding(.horizontal)

    }
}
