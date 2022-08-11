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

struct RoundedRectStyle: ButtonStyle {
    let foregroundColor: Color
    let backgroundColor: Color

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(.horizontal, Const.Padding.buttonHorizontal)
            .padding(.vertical, Const.Padding.buttonVertical)
            .foregroundColor(configuration.isPressed ? foregroundColor.opacity(0.5) : foregroundColor)
            .background(backgroundColor)
            .cornerRadius(Const.Radius.corner)
    }
}

struct HomeMessageView: View {
    let viewModel: HomeMessageViewModel
    
    var body: some View {
        VStack(spacing: Const.Spacing.titleAndSubtitle) {
            HStack(alignment: .top) {
                Spacer()
                VStack(spacing: 0) {
                    topText
                    image
                    title
                }
                .offset(x: Const.Size.closeButtonWidth / 2, y: 0)
                .layoutPriority(1)
                Spacer()
                closeButton
            }
            
            VStack(spacing: 0) {
                subtitle
                HStack {
                    buttons
                }
                .padding(.top, Const.Spacing.subtitleAndButtons)
            }
        }
        .multilineTextAlignment(.center)
        .padding()
        .background(RoundedRectangle(cornerRadius: Const.Radius.corner)
                        .fill(Color.background)
                        .shadow(color: Color.shadow,
                                radius: Const.Radius.shadow,
                                x: 0,
                                y: Const.Offset.shadowVertical))
    }
    
    private var closeButton: some View {
        Button(action: { viewModel.onDidClose(.close) },
               label: { Image.dismiss })
            .layoutPriority(2)
            .offset(x: Const.Offset.closeButton,
                    y: -Const.Offset.closeButton)
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
            .font(Font(uiFont: Const.Font.title))
            .fixedSize(horizontal: false, vertical: true)
            .padding(.top, Const.Spacing.imageAndTitle)
   }
    
    private var subtitle: some View {
        Text(viewModel.subtitle)
            .font(Font(uiFont: Const.Font.subtitle))
            .lineSpacing(Const.Spacing.line)
            .padding(.top, Const.Spacing.titleAndSubtitle)
    }
    
    private var buttons: some View {
        ForEach(viewModel.buttons, id: \.title) {
            let foreground: Color = $0.actionStyle == .default ? .white : .cancelButtonForeground
            let background: Color = $0.actionStyle == .default ? .button : .cancelButtonBackground
            Button($0.title, action: $0.action)
                .font(Font(uiFont: Const.Font.button))
                .buttonStyle(RoundedRectStyle(foregroundColor: foreground,
                                              backgroundColor: background))
                .padding([.top, .bottom], Const.Padding.buttonVerticalInset)
        }
    }
}

private extension Color {
    static let button = Color(UIColor.cornflowerBlue)
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
    }
    
    enum Spacing {
        static let imageAndTitle: CGFloat = 8
        static let titleAndSubtitle: CGFloat = 4
        static let subtitleAndButtons: CGFloat = 6
        static let line: CGFloat = 4
    }
    
    enum Size {
        static let maxImageWidth: CGFloat = 64
        static let closeButtonWidth: CGFloat = 24
    }
    
    enum Offset {
        static let closeButton: CGFloat = 6
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
                                             onDidClose: { _ in })
        return HomeMessageView(viewModel: viewModel)
            .padding(.horizontal)
    }
}
