//
//  AppTPFAQView.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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

#if APP_TRACKING_PROTECTION

struct AppTPFAQView: View {
    var faqBody: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Const.Size.stackSpacing) {
                ForEach(AppTPFAQViewModel.faqs, id: \.question) { faq in
                    VStack(alignment: .leading, spacing: Const.Size.stackSpacing) {
                        Text(faq.question)
                            .font(Font(uiFont: Const.Font.titleFont))
                            .foregroundColor(Color.fontColor)
                        Text(faq.answer)
                            .font(Font(uiFont: Const.Font.contentFont))
                            .foregroundColor(Color.fontColor)
                    }
                    .padding(Const.Size.stackPadding)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .navigationTitle(Text(UserText.appTPFAQTitle))
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    var scrollWithBackgroud: some View {
        if #available(iOS 16, *) {
            faqBody
                .scrollContentBackground(.hidden)
                .background(Color(designSystemColor: .background))
        } else {
            faqBody
                .background(Color(designSystemColor: .background))
        }
    }
    
    var body: some View {
        scrollWithBackgroud
    }
}

private enum Const {
    enum Font {
        static let titleFont = UIFont.boldAppFont(ofSize: 20)
        static let contentFont = UIFont.appFont(ofSize: 16)
    }
    
    enum Size {
        static let stackSpacing: CGFloat = 10
        static let stackPadding: CGFloat = 24
    }
}

private extension Color {
    static let fontColor = Color("AppTPDomainColor")
}


struct AppTPFAQView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AppTPFAQView()
        }
    }
}

#endif
