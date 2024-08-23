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

    private let itemsToAnimate: [DisplayableTypes]

    init(
        title: String? = nil,
        message: NSAttributedString,
        list: [ContextualOnboardingListItem] = [],
        listAction: ((_: ContextualOnboardingListItem) -> Void)? = nil,
        imageName: String? = nil, cta: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.list = list
        self.listAction = listAction
        self.imageName = imageName
        self.cta = cta
        self.action = action

        var itemsToAnimate: [DisplayableTypes] = []
        if title != nil {
            itemsToAnimate.append(.title)
        }
        itemsToAnimate.append(.message)
        if !list.isEmpty {
            itemsToAnimate.append(.list)
        }
        if imageName != nil {
            itemsToAnimate.append(.image)
        }
        if cta != nil {
            itemsToAnimate.append(.button)
        }

        self.itemsToAnimate = itemsToAnimate
    }

    @State private var startTypingTitle: Bool = false
    @State private var startTypingMessage: Bool = false
    @State private var nonTypingAnimatableItems: NonTypingAnimatableItems = []

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Typing items
            titleView
            messageView
            // Non Typing items
            listView
                .visibility(nonTypingAnimatableItems.contains(.list) ? .visible : .invisible)
            imageView
                .visibility(nonTypingAnimatableItems.contains(.image) ? .visible : .invisible)
            actionView
                .visibility(nonTypingAnimatableItems.contains(.button) ? .visible : .invisible)
        }
        .onAppear {
            Task { @MainActor in
                try await Task.sleep(interval: 0.3)
                startAnimating()
            }
        }
    }

    @ViewBuilder
    private var titleView: some View {
        if let title {
            AnimatableTypingText(title, startAnimating: $startTypingTitle, onTypingFinished: {
                startTypingMessage = true
            })
            .daxTitle3()
        }
    }

    @ViewBuilder
    private var messageView: some View {
        AnimatableTypingText(message, startAnimating: $startTypingMessage, onTypingFinished: {
            animateNonTypingItems()
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

    enum DisplayableTypes {
        case title
        case message
        case list
        case image
        case button
    }

    struct NonTypingAnimatableItems: OptionSet {
        let rawValue: Int

        static let list = NonTypingAnimatableItems(rawValue: 1 << 0)
        static let image = NonTypingAnimatableItems(rawValue: 1 << 1)
        static let button = NonTypingAnimatableItems(rawValue: 1 << 2)
    }
}

// MARK: - Auxiliary Functions

extension ContextualDaxDialogContent {

    private func startAnimating() {
        if itemsToAnimate.contains(.title) {
            startTypingTitle = true
        } else if itemsToAnimate.contains(.message) {
            startTypingMessage = true
        }
    }

    private func animateNonTypingItems() {
        // Remove typing items and animate sequentially non typing items
        let nonTypingItems = itemsToAnimate.filter { $0 != .title && $0 != .message }

        nonTypingItems.enumerated().forEach { index, item in
            let delayForItem = Metrics.animationDelay * Double(index + 1)
            withAnimation(.easeIn(duration: Metrics.animationDuration).delay(delayForItem)) {
                switch item {
                case .title, .message:
                    // Typing items. they don't need to animate sequentially.
                    break
                case .list:
                    nonTypingAnimatableItems.insert(.list)
                case .image:
                    nonTypingAnimatableItems.insert(.image)
                case .button:
                    nonTypingAnimatableItems.insert(.button)
                }
            }
        }
    }
}

// MARK: - Metrics

extension ContextualDaxDialogContent {
    enum Metrics {
        static let animationDuration = 0.25
        static let animationDelay = 0.3
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
