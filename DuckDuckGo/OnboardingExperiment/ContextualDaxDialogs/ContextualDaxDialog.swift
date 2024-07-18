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
import Combine

struct ContextualDaxDialogContent: View {

    var title: String?
    let message: NSAttributedString
    var list: [ContextualOnboardingListItem] = []
    var listAction: ((_ item: ContextualOnboardingListItem) -> Void)?
    var imageName: String?
    var cta: String?
    var action: (() -> Void)?

    @State private var typeToDisplay: DisplayableTypes = .none {
        didSet {
            if typeToDisplay == .message {
                timerCancellable?.cancel()
                startTyping = true
            }
        }
    }
    @State private var startTyping: Bool = false
    @State private var timerCancellable: AnyCancellable?

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            titleView
                .visibility((typeToDisplay.rawValue >= 1) ? .visible : .invisible)
            messageView
            listView
                .visibility((typeToDisplay.rawValue >= 3) ? .visible : .invisible)
            imageView
                .visibility((typeToDisplay.rawValue >= 4) ? .visible : .invisible)
            actionView
                .visibility((typeToDisplay.rawValue >= 5) ? .visible : .invisible)
        }
        .onAppear {
            startSequentialUpdate()
        }
        .onDisappear {
            timerCancellable?.cancel()
        }
    }

    @ViewBuilder
    private var titleView: some View {
        if let title {
            Text(title)
                .daxTitle3()
        }
    }

    @ViewBuilder
    private var messageView: some View {
        AnimatableTypingText(message, startAnimating: $startTyping, onTypingFinished: {
            startSequentialUpdate()
        })
    }

    @ViewBuilder
    private var listView: some View {
        if let listAction {
            ContextualOnboardingListView(list: list, action: listAction)
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
        }
    }

    @ViewBuilder
    private var actionView: some View {
        if let cta, let action {
            Button(action: action) {
                Text(cta)
            }
            .buttonStyle(PrimaryButtonStyle(compact: true))
        }
    }

    enum DisplayableTypes: Int {
        case none = 0
        case title = 1
        case message = 2
        case list = 3
        case image = 4
        case button = 5
    }
}

// MARK: - Auxiliary Functions

extension ContextualDaxDialogContent {
    private func startSequentialUpdate() {
        let updateInterval = 0.3
        let timerPublisher = Timer.publish(every: updateInterval, on: .main, in: .common).autoconnect()

        timerCancellable = timerPublisher.sink { _ in
            if self.typeToDisplay.rawValue < DisplayableTypes.button.rawValue {
                withAnimation(.easeIn(duration: 0.25)) {
                    self.updateTypeToDisplay()
                }
            } else {
                self.timerCancellable?.cancel()
            }
        }
    }

    private func updateTypeToDisplay() {
        switch typeToDisplay {
        case .none:
            if title != nil {
                typeToDisplay = .title
            } else {
                typeToDisplay = .message
            }
        case .title:
            typeToDisplay = .message
        case .message:
            if !list.isEmpty {
                typeToDisplay = .list
            } else if imageName != nil {
                typeToDisplay = .image
            } else if cta != nil {
                typeToDisplay = .button
            }
        case .list:
            if imageName != nil {
                typeToDisplay = .image
            } else if cta != nil {
                typeToDisplay = .button
            }
        case .image:
            if cta != nil {
                typeToDisplay = .button
            }
        case .button:
            break
        }
    }
}


// MARK: - Preview

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

    return ContextualDaxDialogContent(message: attributedString)
        .padding()
        .preferredColorScheme(.light)
}

#Preview("Intro Dialog - text and button") {
    let contextualText = NSMutableAttributedString(string: "Sabrina is the best\n\nBelieve me! ☝️")
    return ContextualDaxDialogContent(
        message: contextualText,
        cta: "Got it!",
        action: {})
    .padding()
    .preferredColorScheme(.light)
}

#Preview("Intro Dialog - title, text, image and button") {
    let contextualText = NSMutableAttributedString(string: "Sabrina is the best\n\nBelieve me! ☝️")
    return ContextualDaxDialogContent(
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
    return ContextualDaxDialogContent(
        title: "Who is the best?",
        message: contextualText,
        list: list,
        listAction: { _ in })
    .padding()
    .preferredColorScheme(.light)
}

#Preview("en_GB list") {
    ContextualDaxDialogContent(title: "title",
                        message: "this is a message".attributedStringFromMarkdown(color: .blue),
                        list: OnboardingSuggestedSitesProvider(countryProvider: Locale(identifier: "en_GB")).list,
                        listAction: { _ in })
    .padding()
}

#Preview("en_US list") {
    ContextualDaxDialogContent(title: "title",
                        message: "this is a message".attributedStringFromMarkdown(color: .blue),
                        list: OnboardingSuggestedSitesProvider(countryProvider: Locale(identifier: "en_US")).list,
                        listAction: { _ in })
    .padding()
}
