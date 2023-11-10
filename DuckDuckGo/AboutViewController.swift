//
//  AboutViewController.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

import UIKit
import Core
import SwiftUI
import DesignResourcesKit

class AboutViewController: UIHostingController<AboutView> {

    convenience init() {
        self.init(rootView: AboutView())
    }

}

struct AboutView: View {

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Image("Logo")
                    .resizable()
                    .frame(width: 96, height: 96)
                    .padding(.top)

                Image("TextDuckDuckGo")

                Text("Welcome to the Duck Side!")
                    .daxHeadline()

                Rectangle()
                    .frame(width: 80, height: 0.5)
                    .foregroundColor(Color(designSystemColor: .lines))
                    .padding()

                Text(LocalizedStringKey(UserText.aboutText))
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.primary)
                    .tintIfAvailable(Color(designSystemColor: .accent))
                    .padding(.horizontal, 32)
                    .padding(.bottom)

                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .background(Rectangle()
            .ignoresSafeArea()
            .foregroundColor(Color(designSystemColor: .background)))
    }

}

private extension View {
    
    @ViewBuilder func tintIfAvailable(_ color: Color) -> some View {
        if #available(iOS 16.0, *) {
            tint(color)
        } else {
            self
        }
    }

}
