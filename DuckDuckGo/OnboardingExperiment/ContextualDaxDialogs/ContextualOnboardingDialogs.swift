//
//  ContextualOnboardingDialogs.swift
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

struct OnboardingTrySearchDialog: View {
    let title = "Try a search!"
    let message = [NSAttributedString(string: "Your DuckDuckGo searches are always anonymous.")]
    let list = [
        ContextualOnboardingListItem.search(title: "Weblink"),
        ContextualOnboardingListItem.search(title: "Weblink"),
        ContextualOnboardingListItem.search(title: "Weblink"),
        ContextualOnboardingListItem.surprise(title: "Surprise me")
    ]
    let action: (_ index: Int) -> Void

    var body: some View {
        ContextualDaxDialog(
            logoPosition: .top,
            title: title,
            message: message,
            list: list,
            listAction: action)
    }
}

struct OnboardingTryVisitingSiteDialog: View {
    let logoPosition: DaxDialogLogoPosition
    let title = "Try visiting a site!"
    let message = [NSAttributedString(string: "We’ll block trackers so they can’t spy on you.")]
    let list = [
        ContextualOnboardingListItem.site(title: "Sitelink"),
        ContextualOnboardingListItem.site(title: "Sitelink"),
        ContextualOnboardingListItem.site(title: "Sitelink"),
        ContextualOnboardingListItem.surprise(title: "Surprise me")
    ]
    let action: (_ index: Int) -> Void

    var body: some View {
        ContextualDaxDialog(
            logoPosition: logoPosition,
            title: title,
            message: message,
            list: list,
            listAction: action)
    }
}

struct FireButtonDialog: View {
    let secondMessage = NSAttributedString(string: "Give it a try! ☝️")

    var attributedMessage: NSAttributedString {
        let firstString = "Instantly clear your browsing activity with the Fire Button."
        let boldString = "Fire Button."
        let attributedString = NSMutableAttributedString(string: firstString)
        let boldFontAttribute: [NSAttributedString.Key: Any] = [
            .font: UIFont.daxBodyBold()
        ]
        if let boldRange = firstString.range(of: boldString) {
            let nsBoldRange = NSRange(boldRange, in: firstString)
            attributedString.addAttributes(boldFontAttribute, range: nsBoldRange)
        }

        return attributedString
    }

    var body: some View {
        ContextualDaxDialog(
            message: [attributedMessage, secondMessage])
    }
}


#Preview("Try Search") {
    OnboardingTrySearchDialog(action: { _ in })
        .padding()
}

#Preview("Try Site Top") {
    OnboardingTryVisitingSiteDialog(logoPosition: .top, action: { _ in })
        .padding()
}

#Preview("Try Site Left") {
    OnboardingTryVisitingSiteDialog(logoPosition: .left, action: { _ in })
        .padding()
}

#Preview("Try Site Left") {
    FireButtonDialog()
        .padding()
}

