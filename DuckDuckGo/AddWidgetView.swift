//
//  AddWidgetView.swift
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

extension Font {
    init(uiFont: UIFont) {
        self = Font(uiFont as CTFont)
    }
}

@available(iOS 14.0, *)
struct AddWidgetView: View {
    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: Const.Spacing.paragraph) {
                    NumberedParagraph(number: 1,
                                      text: Text("Long-press on the home screen to enter jiggle mode."))
                    NumberedParagraph(number: 2,
                                      text: Text("Tap the plus \(Image.add) button."),
                                      image: Image.homeScreen)
                    NumberedParagraph(number: 3,
                                      text: Text("Find and select DuckDuckGo. Then choose a widget."),
                                      image: Image.widgetExample)
                }
                .padding(EdgeInsets(top: Const.Padding.top,
                                    leading: Const.Padding.leading,
                                    bottom: 0,
                                    trailing: Const.Padding.trailing))
            }
        }
    }
}

private struct NumberedParagraph: View {
    var number: Int
    var text: Text
    var image: Image?
        
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: Const.Spacing.numberAndText) {
            NumberedCircleView(number: number)
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

private struct NumberedCircleView: View {
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
    static let background = Color("WidgetBackgroundColor")
    static let font = Color("WidgetFontColor")
    static let circle = Color(UIColor.cornflowerBlue)
    static let numbers = Color.white
}

private extension Image {
    static let add = Image("WidgetAddIcon")
    static let widgetExample = Image("WidgetExample")
    static let homeScreen = Image("WidgetHomeScreen")
}

private enum Const {
    enum Font {
        static let text = UIFont.appFont(ofSize: 17)
        static let numbers = UIFont.boldAppFont(ofSize: 16)
    }
    
    enum Padding {
        static let top: CGFloat = 32
        static let leading: CGFloat = 24
        static let trailing: CGFloat = 40
    }
    
    enum Spacing {
        static let paragraph: CGFloat = 32
        static let numberAndText: CGFloat = 16
        static let textAndImage: CGFloat = 18
        static let line: CGFloat = 4
    }
    
    enum Size {
        static let circle = CGSize(width: 24, height: 24)
        static let imageWidth: CGFloat = 270
    }
}

@available(iOS 14.0, *)
struct AddWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        AddWidgetView()
    }
}
