//
//  ContextualDaxDialog.swift
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

import Foundation
import SwiftUI
import DuckUI

struct ContextualDaxDialog: View {
    
    var logoPosition: DaxDialogLogoPosition = .left
    var title: String?
    let message: NSAttributedString
    var list: [ContextualOnboardingListItem] = []
    var listAction: ((_ index: Int) -> Void)?
    var imageName: String?
    var cta: String?
    var action: (() -> Void)?

    @State private var currentDisplayIndex: Int = 0

    var body: some View {
        DaxDialogView(logoPosition: logoPosition) {
            VStack(alignment: .leading, spacing: 24) {
                titleView
                messageView
                listView
                imageView
                actionView
            }
        }
    }

    @ViewBuilder
    private var titleView: some View {
        if let title {
            Text(title)
                .daxTitle3()
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    private var messageView: some View {
        if #available(iOS 15, *){
            Text(AttributedString(message))
        } else {
            Text(message.string)
        }
    }

    @ViewBuilder
    private var listView: some View {
        if let listAction {
            ContextualOnboardingListView(list: list, action: listAction)
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    private var imageView: some View {
        if let imageName {
            HStack {
                Spacer()
                Image(imageName)
                Spacer()
            }
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    private var actionView: some View {
        if let cta, let action {
            Button(action: action) {
                Text(cta)
            }
            .buttonStyle(PrimaryButtonStyle(compact: true))
        } else {
            EmptyView()
        }
    }

    private func updateDisplayIndex() {
        let totalComponents = 5  // corresponds to title, message, list, image, action
        if currentDisplayIndex < totalComponents - 1 {
            currentDisplayIndex += 1
        }
    }

}

#Preview("Intro Dialog - text") {
    let fullString = "Instantly clear your browsing activity with the Fire Button.\n\n Give it a try! ☝️"
    let boldString = "Fire Button."

    let attributedString = NSMutableAttributedString(string: fullString)
    let boldFontAttribute: [NSAttributedString.Key: Any] = [
        .font: UIFont.daxBodyBold()
    ]

    if let boldRange = fullString.range(of: boldString) {
        let nsBoldRange = NSRange(boldRange, in: fullString)
        attributedString.addAttributes(boldFontAttribute, range: nsBoldRange)
    }

    return ContextualDaxDialog(message: attributedString)
        .padding()
        .preferredColorScheme(.light)
}

#Preview("Intro Dialog - text and button") {
    let contextualText = NSMutableAttributedString(string: "Sabrina is the best\n\nBelieve me! ☝️")
    return ContextualDaxDialog(
        message: contextualText,
        cta: "Got it!",
        action: {})
        .padding()
        .preferredColorScheme(.light)
}

#Preview("Intro Dialog - title, text, image and button") {
    let contextualText = NSMutableAttributedString(string: "Sabrina is the best\n\nBelieve me! ☝️")
    return ContextualDaxDialog(
        title: "Who is the best?",
        message: contextualText,
        imageName: "Sync-Desktop-New-128",
        cta: "Got it!",
        action: {})
        .padding()
        .preferredColorScheme(.light)
}

#Preview("Intro Dialog - title, text, list") {
    let contextualText = NSMutableAttributedString(string: "Sabrina is the best!\n\n Alessandro is ok I guess...")
    let list = [
        ContextualOnboardingListItem.search(title: "Search"),
        ContextualOnboardingListItem.site(title: "Website"),
        ContextualOnboardingListItem.surprise(title: "Surprise"),
    ]
    return ContextualDaxDialog(
        title: "Who is the best?",
        message: contextualText,
        list: list,
        listAction: {_ in })
        .padding()
        .preferredColorScheme(.light)
}
