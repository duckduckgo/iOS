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
    let message = NSAttributedString(string: "Your DuckDuckGo searches are always anonymous.")
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
    let message = NSAttributedString(string: "We’ll block trackers so they can’t spy on you.")
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

struct OnboardingFireButtonDialog: View {
    var attributedMessage: NSAttributedString {
        let firstString = "Instantly clear your browsing activity with the Fire Button.\n\nGive it a try! ☝️"
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
            message: attributedMessage)
    }
}

struct OnboardingFirstSearchDoneDialog: View {

    @State var showNextScreen: Bool = false
    @State var shouldFollowUp: Bool
    let listAction: (_ index: Int) -> Void
    let message = NSAttributedString(string: "That’s DuckDuckGo Search. Private. Fast. Fewer ads.")
    let cta = "Got it!"
    let gotItAction: () -> Void

    var body: some View {
        if showNextScreen {
            OnboardingTryVisitingSiteDialog(logoPosition: .left, action: listAction)
        } else {
            ContextualDaxDialog(
                message: message,
                cta: cta) {
                    if shouldFollowUp {
                        showNextScreen = true
                    } else {
                        gotItAction()
                    }
            }
        }
    }
}

struct OnboardingTrackersDoneDialog: View {

    @State var showNextScreen: Bool = false
    let message: NSAttributedString
    let cta = "Got it!"

    var body: some View {
        if showNextScreen {
            OnboardingFireButtonDialog()
        } else {
            ContextualDaxDialog(
                message: message,
                cta: cta) {
                    showNextScreen = true
                }
        }
    }
}

struct OnboardingFinalDialog: View {
    let title = "You’ve got this!"
    let message = NSAttributedString(string: "Remember every time you browse with me a creepy ad loses it’s wings.")
    let cta = "High five!"
    let imageName = "Success-128"
    let highFiveAction: () -> Void

    var body: some View {
        ContextualDaxDialog(
            title: title,
            message: message,
            imageName: imageName,
            cta: cta,
            action: highFiveAction
        )
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

#Preview("Try Fire Button") {
    OnboardingFireButtonDialog()
        .padding()
}

#Preview("First Search Dialog") {
    OnboardingFirstSearchDoneDialog(shouldFollowUp: true, listAction: {_ in }, gotItAction: {})
        .padding()
}

#Preview("Final Dialog") {
    OnboardingFinalDialog(highFiveAction: {})
        .padding()
}

#Preview("Final Dialog") {
    OnboardingTrackersDoneDialog(message: NSAttributedString(string: "Heads up! Instagram.com is owned by Facebook.\n\nFacebook’s trackers lurk on about 40% of top websites 😱 but don’t worry!\n\nI’ll block Facebook from seeing your activity on those sites."))
        .padding()
}
