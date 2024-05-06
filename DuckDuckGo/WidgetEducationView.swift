//
//  WidgetEducationView.swift
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

extension Font {
    init(uiFont: UIFont) {
        self = Font(uiFont as CTFont)
    }
}

struct WidgetEducationImageConfig {
    let image: Image
    let maxWidth: CGFloat
    let horizontalOffset: CGFloat

    init(image: Image, maxWidth: CGFloat, horizontalOffset: CGFloat = 0) {
        self.image = image
        self.maxWidth = maxWidth
        self.horizontalOffset = horizontalOffset
    }
}

struct WidgetEducationView: View {
    typealias ImageConfig = WidgetEducationImageConfig

    let navBarTitle: String
    let thirdParagraphText: String
    let widgetExampleImageConfig: ImageConfig

    init(navBarTitle: String = UserText.settingsAddWidget,
         thirdParagraphText: String = UserText.addWidgetSettingsThirdParagraph,
         widgetExampleImageConfig: ImageConfig = .init(image: .widgetExample, maxWidth: Const.Size.imageWidth)) {
        self.navBarTitle = navBarTitle
        self.thirdParagraphText = thirdParagraphText
        self.widgetExampleImageConfig = widgetExampleImageConfig
    }

    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: Const.Spacing.paragraph) {
                    NumberedParagraph(number: 1,
                                      text: Text(UserText.addWidgetSettingsFirstParagraph))
                    NumberedParagraph(number: 2,
                                      text: secondParagraphText,
                                      imageConfig: ImageConfig(image: Image.homeScreen, maxWidth: Const.Size.imageWidth))
                    NumberedParagraph(number: 3,
                                      text: Text(thirdParagraphText),
                                      imageConfig: widgetExampleImageConfig)
                }
                .padding(.horizontal)
                .padding(.top, Const.Padding.top)
            }
        }.navigationBarTitle(navBarTitle, displayMode: .inline)
            .onForwardNavigationAppear {
                Pixel.fire(pixel: .settingsNextStepsAddWidget,
                           withAdditionalParameters: PixelExperiment.parameters)
            }
    }
    
    private var secondParagraphText: Text {
        // https://stackoverflow.com/questions/62168292/what-s-the-equivalent-to-string-localizedstringwithformat-for-swiftuis-lo
        Text("addWidget.settings.secondParagraph.\(Image.add)")
    }
}

private struct NumberedParagraph: View {
    var number: Int
    var text: Text
    var imageConfig: WidgetEducationImageConfig?

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: Const.Spacing.numberAndText) {
            NumberedCircle(number: number)
            VStack(alignment: .leading, spacing: Const.Spacing.textAndImage) {
                text
                    .font(Font(uiFont: Const.Font.text))
                    .lineSpacing(Const.Spacing.line)
                    .foregroundColor(Color.font)
                if let imageConfig {
                    imageConfig
                        .image
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: imageConfig.maxWidth)
                        .offset(x: imageConfig.horizontalOffset)
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
    static let background = Color(designSystemColor: .background)
    static let font = Color("WidgetEducationFontColor")
    static let circle = Color(UIColor.cornflowerBlue)
    static let numbers = Color.white
}

private extension Image {
    static let add = Image("WidgetEducationAddIcon")
    static let widgetExample = Image("WidgetEducationWidgetExample")
    static let homeScreen = Image("WidgetEducationHomeScreen")
}

private enum Const {
    enum Font {
        static let text = UIFont.appFont(ofSize: 17)
        static let numbers = UIFont.boldAppFont(ofSize: 16)
    }
    
    enum Padding {
        static let top: CGFloat = 32
    }
    
    enum Spacing {
        static let paragraph: CGFloat = 24
        static let numberAndText: CGFloat = 16
        static let textAndImage: CGFloat = 16
        static let line: CGFloat = 4
    }
    
    enum Size {
        static let circle = CGSize(width: 24, height: 24)
        static let imageWidth: CGFloat = 270
    }
}

struct WidgetEducationView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetEducationView()
    }
}
