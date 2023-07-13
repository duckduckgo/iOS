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
import DesignResourcesKit

#if APP_TRACKING_PROTECTION

struct AppTPFAQView: View {
    
    init() {
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithTransparentBackground()
        coloredAppearance.backgroundColor = UIColor(designSystemColor: .background)
        
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
    }
    
    var faqBody: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Const.Size.stackSpacing) {
                ForEach(AppTPFAQViewModel.faqs, id: \.question) { faq in
                    VStack(alignment: .leading, spacing: Const.Size.stackSpacing) {
                        Text(faq.question)
                            .daxTitle3()
                            .foregroundColor(Color.fontColor)
                        Text(faq.answer)
                            .daxBodyRegular()
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
    
    var body: some View {
        if #available(iOS 16, *) {
            faqBody
                .scrollContentBackground(.hidden)
                .background(Color(designSystemColor: .background))
        } else {
            faqBody
                .background(Color(designSystemColor: .background))
        }
    }
}

private enum Const {
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
