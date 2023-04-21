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

extension Font {
    init(uiFont: UIFont) {
        self = Font(uiFont as CTFont)
    }
}

struct WidgetEducationView: View {
    
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
                                      image: Image.homeScreen)
                    NumberedParagraph(number: 3,
                                      text: Text(UserText.addWidgetSettingsThirdParagraph),
                                      image: Image.widgetExample)
                }
                .padding(.horizontal)
                .padding(.top, Const.Padding.top)
            }
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
    var image: Image?
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: Const.Spacing.numberAndText) {
            NumberedCircle(number: number)
            VStack(alignment: .leading, spacing: Const.Spacing.textAndImage) {
                text
                    .font(Font(uiFont: Const.Font.text))
                    .lineSpacing(Const.Spacing.line)
                    .foregroundColor(Color.font)
                image?
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: Const.Size.imageWidth)
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
