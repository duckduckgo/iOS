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

struct WidgetEducationView: View {
    typealias Detail = NumberedParagraphConfig.Detail

    @Environment(\.dismiss) private var dismiss

    let navBarTitle: String
    let thirdParagraphText: String
    let thirdParagraphDetail: Detail

    var secondParagraphText: Text {
        if #available(iOS 18, *) {
            // The LocalizedStringKey wrapper is necessary to properly parse markdown
            return Text(LocalizedStringKey(UserText.addWidgetSettingsSecondParagraph))
        } else {
            // Ref: https://stackoverflow.com/questions/62168292/what-s-the-equivalent-to-string-localizedstringwithformat-for-swiftuis-lo
            return Text("addWidget.settings.secondParagraph.\(Image.add)")
        }
    }

    init(navBarTitle: String = UserText.settingsAddWidget,
         thirdParagraphText: String = UserText.addWidgetSettingsThirdParagraph,
         thirdParagraphDetail: Detail = .image(Image.widgetExample, maxWidth: Const.Size.exampleImageWidth)) {

        self.navBarTitle = navBarTitle
        self.thirdParagraphText = thirdParagraphText
        self.thirdParagraphDetail = thirdParagraphDetail
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Const.Spacing.titleAndList) {
                Text(navBarTitle)
                    .font(.system(size: 22, weight: .bold, design: .default))

                NumberedParagraphListView(
                    paragraphConfig: [
                        NumberedParagraphConfig(text: UserText.addWidgetSettingsFirstParagraph),
                        NumberedParagraphConfig(
                            text: secondParagraphText,
                            detail: .image(Image.homeScreen,
                                           maxWidth: Const.Size.exampleImageWidth)),
                        NumberedParagraphConfig(
                            text: thirdParagraphText,
                            detail: thirdParagraphDetail)
                    ]
                )
                .foregroundColor(Color.font)
            }
            .padding(.horizontal, Const.Padding.horizontal)
            .padding(.top, Const.Padding.top)
        }
        .navigationBarTitle("")
        .background(Color.background)
        .onFirstAppear {
            Pixel.fire(pixel: .settingsNextStepsAddWidget)
        }
    }
}

private extension Color {
    static let background = Color(designSystemColor: .background)
    static let font = Color("WidgetEducationFontColor")
}

extension Image {
    static let add = Image("WidgetEducationAddIcon")
    static let widgetExample = Image("WidgetEducationWidgetExample")
    static var homeScreen: Image {
        if #available(iOS 18, *) {
            Image("WidgetEducationHomeScreen")
        } else {
            Image("WidgetEducationHomeScreeniOS17")
        }
    }
}

private enum Const {

    enum Padding {
        static let top: CGFloat = 24
        static let horizontal: CGFloat = 24
    }
    
    enum Spacing {
        static let titleAndList: CGFloat = 24
    }
    
    enum Size {
        static let exampleImageWidth: CGFloat = 270
    }
}

@available(iOS 17.0, *)
struct WidgetEducationView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetEducationView()
    }
}
