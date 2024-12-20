//
//  ControlCenterWidgetEducationView.swift
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
import Core

@available(iOS 18.0, *)
struct ControlCenterWidgetEducationView: View {
    typealias Detail = NumberedParagraphConfig.Detail

    enum Padding {
        static let top: CGFloat = 24
        static let horizontal: CGFloat = 24
        static let widgetBorder: CGFloat = 20
    }

    enum Spacing {
        static let titleAndList: CGFloat = 24
    }

    enum Size {
        static let exampleImageWidth: CGFloat = 270
        static let widgetHeight: CGFloat = 30
        static let widgetWidth: CGFloat = 30
        static let widgetMaxWidth: CGFloat = 70 // width + padding * 2
    }

    @Environment(\.dismiss) private var dismiss

    let navBarTitle: String
    let widgetIconDetail: Detail

    init(navBarTitle: String, widget: ControlCenterWidget) {

        self.navBarTitle = navBarTitle

        let icon = widget.image
            .renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .foregroundStyle(Color.white)
            .frame(width: Size.widgetWidth, height: Size.widgetHeight)
            .padding(Padding.widgetBorder)
            .background(Circle().fill(Color.controlWidgetBackground))
            .frame(maxWidth: Size.widgetMaxWidth)

        self.widgetIconDetail = .view(AnyView(icon), maxWidth: Size.widgetMaxWidth)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.titleAndList) {
                Text(navBarTitle)
                    .font(.system(size: 22, weight: .bold, design: .default))

                NumberedParagraphListView(
                    paragraphConfig: [
                        NumberedParagraphConfig(text: UserText.controlCenterWidgetEducationParagraph1),
                        NumberedParagraphConfig(text: UserText.controlCenterWidgetEducationParagraph2),
                        NumberedParagraphConfig(
                            text: UserText.controlCenterWidgetEducationParagraph3,
                            detail: .image(Image.controlCenterBottom,
                                           maxWidth: Size.exampleImageWidth)),
                        NumberedParagraphConfig(
                            text: UserText.controlCenterVPNWidgetEducationParagraph,
                            detail: widgetIconDetail)
                    ]
                )
                .foregroundColor(Color.font)
            }
            .padding(.horizontal, Padding.horizontal)
            .padding(.top, Padding.top)
        }
        .navigationBarTitle("")
        .background(Color.background)
    }
}

private extension Color {
    static let background = Color(designSystemColor: .background)
    static let controlWidgetBackground = Color("controlWidgetBackground", bundle: DesignResourcesKit.bundle)
    static let font = Color("WidgetEducationFontColor")
}

private extension Image {
    static let controlCenterBottom = Image("ControlCenterBottom")
}


@available(iOS 18.0, *)
struct ControlCenterWidgetEducationView_Previews: PreviewProvider {
    static var previews: some View {
        ControlCenterWidgetEducationView(navBarTitle: "Control Center", widget: .vpnToggle)
    }
}
