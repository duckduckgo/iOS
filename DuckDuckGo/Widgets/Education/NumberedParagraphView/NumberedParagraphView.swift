//
//  NumberedParagraphView.swift
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
import Core

extension Font {
    init(uiFont: UIFont) {
        self = Font(uiFont as CTFont)
    }
}

struct NumberedParagraphListView: View {
    let spacing: CGFloat?
    let paragraphConfig: [NumberedParagraphConfig]

    init(spacing: CGFloat? = nil,
         paragraphConfig: [NumberedParagraphConfig]) {

        self.paragraphConfig = paragraphConfig
        self.spacing = spacing ?? Const.Spacing.paragraph
    }

    var body: some View {
        VStack(spacing: spacing) {
            ForEach(paragraphConfig.indices, id: \.self) { index in
                NumberedParagraphView(number: index + 1,
                                      config: paragraphConfig[index])
            }
        }
    }
}

struct NumberedParagraphConfig {
    enum Detail {
        case image(_ image: Image,
                   maxWidth: CGFloat,
                   horizontalOffset: CGFloat = 0,
                   dropsShadow: Bool = false)
        case view(_ view: AnyView,
                  maxWidth: CGFloat)
    }

    let text: Text
    let detail: Detail?

    init(text: String, detail: Detail? = nil) {
        // The LocalizedStringKey wrapper is necessary to properly parse markdown
        self.text = Text(LocalizedStringKey(text))
        self.detail = detail
    }

    init(text: Text, detail: Detail? = nil) {
        self.text = text
        self.detail = detail
    }
}

private struct NumberedParagraphView: View {
    let number: Int
    let config: NumberedParagraphConfig

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: Const.Spacing.numberAndText) {
            NumberedCircle(number: number)
            VStack(alignment: .leading, spacing: Const.Spacing.textAndImage) {
                HStack {
                    config.text
                        .foregroundStyle(Color(designSystemColor: .textPrimary))
                        .font(Font(uiFont: Const.Font.text))
                        .lineSpacing(Const.Spacing.line)

                    Spacer()
                }

                if let detailConfig = config.detail {
                    switch detailConfig {
                    case .image(let image, let maxWidth, let horizontalOffset, let dropsShadow):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: maxWidth)
                            .offset(x: horizontalOffset)
                            .if(dropsShadow) { view in
                                view.shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 8)
                                    .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                            }
                    case .view(let view, let maxWidth):
                        view
                            .scaledToFit()
                            .frame(maxWidth: maxWidth)
                    }

                }
            }
        }
    }
}

private struct NumberedCircle: View {
    var number: Int

    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(Color.circle)
            Text("\(number)")
                .font(Font(uiFont: Const.Font.numbers))
                .foregroundColor(Color.numbers)
        }
        .frame(width: Const.Size.circle.width,
               height: Const.Size.circle.height)
    }
}

private extension Color {
    static let circle = Color(designSystemColor: .textSelectionFill)
    static let numbers = Color(designSystemColor: .textLink)
}

private enum Const {
    enum Font {
        static let text = UIFont.appFont(ofSize: 17)
        static let numbers = UIFont.boldAppFont(ofSize: 16)
    }

    enum Spacing {
        static let paragraph: CGFloat = 24
        static let numberAndText: CGFloat = 16
        static let textAndImage: CGFloat = 16
        static let line: CGFloat = 4
    }

    enum Size {
        static let circle = CGSize(width: 24, height: 24)
    }
}

@available(iOS 17.0, *)
struct NumberedParagraphListView_Previews: PreviewProvider {
    static var previews: some View {
        NumberedParagraphListView(paragraphConfig: [
            NumberedParagraphConfig(text: "Hellow world"),
            NumberedParagraphConfig(text: "Paragraph 2"),
        ])
    }
}
