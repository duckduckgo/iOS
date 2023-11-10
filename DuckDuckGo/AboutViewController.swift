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

                Divider()
                    .frame(width: 160)
                    .padding()

                // swiftlint:disable line_length
                Text("""
DuckDuckGo is the independent Internet privacy company founded in 2008 for anyone who’s tired of being tracked online and wants an easy solution. We’re proof you can get real privacy protection online without tradeoffs.

The DuckDuckGo browser comes with the features you expect from a go-to browser, like bookmarks, tabs, passwords, and more, plus over [a dozen powerful privacy protections](ddgQuickLink://duckduckgo.com/duckduckgo-help-pages/privacy/web-tracking-protections/) not offered in most popular browsers by default. This uniquely comprehensive set of privacy protections helps protect your online activities, from searching to browsing, emailing, and more.

Our privacy protections work without having to know anything about the technical details or deal with complicated settings. All you have to do is switch your browser to DuckDuckGo across all your devices and you get privacy by default.

But if you *do* want a peek under the hood, you can find more information about how DuckDuckGo privacy protections work on our [help pages](ddgQuickLink://duckduckgo.com/duckduckgo-help-pages/).
""")
                // swiftlint:enable line_length
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .tintIfAvailable(Color(designSystemColor: .accent))
                .padding(.horizontal)
                .padding(.bottom)

            }
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
        }
    }

}

#Preview {
    AboutView()
}
