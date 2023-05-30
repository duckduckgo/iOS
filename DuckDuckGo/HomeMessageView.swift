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

struct RoundedRectStyle: ButtonStyle {
    let foregroundColor: Color
    let backgroundColor: Color

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(.horizontal, Const.Padding.buttonHorizontal)
            .padding(.vertical, Const.Padding.buttonVertical)
            .frame(maxWidth: .infinity)
            .foregroundColor(configuration.isPressed ? foregroundColor.opacity(0.5) : foregroundColor)
            .background(backgroundColor)
            .cornerRadius(Const.Radius.corner)
    }
}

struct HomeMessageView: View {
    let viewModel: HomeMessageViewModel
    
    var body: some View {
        ZStack {
            closeButtonHeader

            VStack(spacing: 8) {
                Group {
                    topText
                    image
                    title
                    subtitle
                        .padding(.top, 8)

                    if viewModel.isSharing {
                        prompt
                    }
                }
                .padding(.horizontal, 24)

                HStack {
                    buttons
                }
                .padding(.top, 8)
                .padding(.horizontal, 32)
            }
            .multilineTextAlignment(.center)
            .padding(.vertical)
            .padding(.horizontal, 8)
        }
        .background(RoundedRectangle(cornerRadius: Const.Radius.corner)
                        .fill(Color.background)
                        .shadow(color: Color.shadow,
                                radius: Const.Radius.shadow,
                                x: 0,
                                y: Const.Offset.shadowVertical))
    }

    private var closeButtonHeader: some View {
        VStack {
            HStack {
                Spacer()
                closeButton
                    .padding(0)
            }
            Spacer()
        }
    }
    
    private var closeButton: some View {
        Button {
            viewModel.onDidClose(.close, .dismiss)
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
            .daxHeadline()
            .padding(.top, Const.Spacing.imageAndTitle)
   }
    
    private var subtitle: some View {
        Text(viewModel.subtitle)
            .daxBodyRegular()
            .padding(.top, Const.Spacing.titleAndSubtitle)
    }

    // EXP2: Hardcoded for experiment
    private var prompt: some View {
        Text("Send a link to yourself for later:")
            .daxSubheadRegular()
            .foregroundColor(Color(designSystemColor: .textSecondary))
            .padding(.top, Const.Spacing.prompt)
    }
    
    private var buttons: some View {
        ForEach(viewModel.buttons, id: \.title) { model in
            let foreground: Color = model.actionStyle == .cancel ? .cancelButtonForeground : .white
            let background: Color = model.actionStyle == .cancel ? .cancelButtonBackground : .button
            Button(action: model.action) {
                HStack {
                    if model.actionStyle == .share {
                        Image(systemName: "square.and.arrow.up")
                    }
                    Text(model.title)
                        .font((Font(uiFont: Const.Font.button)))
                }
            }
            .buttonStyle(RoundedRectStyle(foregroundColor: foreground,
                                          backgroundColor: background))
            .padding([.bottom], Const.Padding.buttonVerticalInset)
        }
    }
}

private extension Color {
    static let button = Color(designSystemColor: .accent)
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
        static let buttonHorizontal: CGFloat = 24
        static let buttonVertical: CGFloat = 9
        static let buttonVerticalInset: CGFloat = 8
        static let textHorizontalInset: CGFloat = 30
    }
    
    enum Spacing {
        static let imageAndTitle: CGFloat = 8
        static let titleAndSubtitle: CGFloat = 4
        static let subtitleAndButtons: CGFloat = 6
        static let prompt: CGFloat = 12
        static let line: CGFloat = 4
    }
    
    enum Size {
        static let closeButtonWidth: CGFloat = 44
    }
    
    enum Offset {
        static let shadowVertical: CGFloat = 2
    }
}

struct HomeMessageView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = HomeMessageViewModel(image: "RemoteMessageDDGAnnouncement",
                                             topText: "",
                                             title: "Placeholder Title",
                                             subtitle: "Body text goes here. This component can be used with one or two buttons.",
                                             buttons: [.init(title: "Button1", actionStyle: .cancel) {},
                                                       .init(title: "Button2") {}],
                                             onDidClose: { _, _ in })
        return HomeMessageView(viewModel: viewModel)
            .padding(.horizontal)
    }
}
