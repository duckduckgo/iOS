//
//  SiriEducationView.swift
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

struct SiriEducationView: View {
    typealias Detail = NumberedParagraphConfig.Detail

    enum Padding {
        static let top: CGFloat = 24
    }

    enum Spacing {
        static let aboveHeader: CGFloat = 8
        static let headerToList: CGFloat = 32
        static let headerInterContent: CGFloat = 13
        static let sidesToContent: CGFloat = 24
    }

    enum Size {
        static let exampleImageWidth: CGFloat = 270
    }

    @Environment(\.dismiss) private var dismiss

    let navBarTitle: String
    let thirdParagraphText: String
    let thirdParagraphDetail: Detail

    init(navBarTitle: String = UserText.settingsAddWidgetTitle,
         thirdParagraphText: String = UserText.addWidgetSettingsThirdParagraph,
         thirdParagraphDetail: Detail = .image(Image.widgetExample, maxWidth: Size.exampleImageWidth)) {

        self.navBarTitle = navBarTitle
        self.thirdParagraphText = thirdParagraphText
        self.thirdParagraphDetail = thirdParagraphDetail
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: Spacing.headerInterContent) {
                Image(.siriControl128)
                    .resizable()
                    .frame(maxWidth: 128)

                Text("Control DuckDuckGo VPN with Siri")
                    .font(.system(size: 22, weight: .bold, design: .default))
                    .kerning(0.35)
                    .multilineTextAlignment(.center)

                Text("Siri Shortcuts let you connect to your VPN with a quick voice command, like saying “Connect DuckDuckgo VPN” to Siri. It’s a fast, hands-free way to use the VPN.")
                    .font(.system(size: 16, weight: .regular))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, Spacing.aboveHeader)
            .padding(.horizontal, Spacing.sidesToContent)

            VStack(alignment: .leading, spacing: 16) {
                SiriBubbleView("\"Siri, snooze DuckDuckGo VPN.\"")

                SiriBubbleView("\"Siri, enable DuckDuckGo VPN.\"")

                SiriBubbleView("\"Siri, protect my device with DuckDuckGo.\"")
            }
            .padding(.top, Spacing.headerToList)
            .padding(.horizontal, Spacing.sidesToContent)
        }
        .navigationBarTitle("")
        .background(Color.background)
    }
}

private extension Color {
    static let background = Color(designSystemColor: .background)
    static let font = Color(designSystemColor: .textPrimary)
}

/*
@available(iOS 17.0, *)
struct WidgetEducationView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetEducationView()
    }
}
*/
