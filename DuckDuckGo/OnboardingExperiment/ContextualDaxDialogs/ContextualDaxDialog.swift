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

    @State private var typeToDisplay: DisplayableTypes = .none {
        didSet {
            updateTypeToDisplaySequentially()
        }
    }
    @State private var visibleMessageLength: Int = 0

    var body: some View {
        DaxDialogView(logoPosition: logoPosition) {
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
        }
        .onAppear {
            updateTypeToDisplaySequentially()
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
        let attributedString = createAttributedString(original: message, visibleLength: visibleMessageLength)

        HStack {
            if #available(iOS 15, *) {
                Text(AttributedString(attributedString))
            } else {
                Text(attributedString.string)
            }
            Spacer()
        }
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

extension ContextualDaxDialog {
    private func updateTypeToDisplaySequentially() {
        let updateInterval = 0.3
        DispatchQueue.main.asyncAfter(deadline: .now() + updateInterval) {
            if self.typeToDisplay == .message {
                self.startTypingAnimation()
            } else if self.typeToDisplay.rawValue < DisplayableTypes.button.rawValue {
                withAnimation(.easeIn(duration: 0.25)) {
                    self.updateTypeToDisplay()
                }
            }
        }
    }

    private func startTypingAnimation() {
        let totalLength = message.length
        let typingSpeed = 0.03
        if visibleMessageLength < totalLength {
            DispatchQueue.main.asyncAfter(deadline: .now() + typingSpeed) {
                self.visibleMessageLength += 1
                self.startTypingAnimation()
            }
        } else {
            updateTypeToDisplay()
        }
    }

    private func createAttributedString(original: NSAttributedString, visibleLength: Int) -> NSAttributedString {
        let totalRange = NSRange(location: 0, length: original.length)
        let visibleRange = NSRange(location: 0, length: min(visibleLength, original.length))

        // Make the entire text transparent
        let transparentText = original.applyingColor(.clear, to: totalRange)

        // Change the color to standard for the visible range
        let visibleText = transparentText.applyingColor(.label, to: visibleRange)

        return visibleText
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
        listAction: { _ in })
        .padding()
        .preferredColorScheme(.light)
}

extension NSAttributedString {
    func applyingColor(_ color: UIColor, to range: NSRange) -> NSAttributedString {
        let mutableAttributedString = NSMutableAttributedString(attributedString: self)

        mutableAttributedString.enumerateAttributes(in: range, options: []) { attributes, range, _ in
            var newAttributes = attributes
            newAttributes[.foregroundColor] = color
            mutableAttributedString.setAttributes(newAttributes, range: range)
        }

        return mutableAttributedString
    }
}
