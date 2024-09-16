//
//  AutofillSettingsEnableFooterView.swift
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

import UIKit
import DesignResourcesKit

class AutofillSettingsEnableFooterView: UIView {

    private enum Constants {
        static let topPadding: CGFloat = 8
        static let defaultPadding: CGFloat = 16
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        installSubviews()
        installConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var title: UITextView = {
        let textView = UITextView(frame: CGRect.zero)
        textView.delegate = self
        textView.textAlignment = .left

        var attributedText = NSMutableAttributedString()
        let attributedTextDescription = (try? NSMutableAttributedString(markdown: UserText.autofillLoginListSettingsFooterMarkdown)) ?? NSMutableAttributedString(string: UserText.autofillLoginListSettingsFooterFallback)
        let attachment = NSTextAttachment()
        attachment.image = UIImage(resource: .lockSolid16).withTintColor(UIColor(designSystemColor: .textSecondary))
        attachment.bounds = CGRect(x: 0, y: -1, width: 12, height: 12)
        let attributedTextImage = NSMutableAttributedString(attachment: attachment)
        attributedText.append(attributedTextImage)
        attributedText.append(.init(string: " "))
        attributedText.append(attributedTextDescription)
        let wholeRange = NSRange(location: 0, length: attributedText.length)
        attributedText.addAttribute(.foregroundColor, value: UIColor(designSystemColor: .textSecondary), range: wholeRange)
        attributedText.addAttribute(.font, value: UIFont.daxFootnoteRegular(), range: wholeRange)

        textView.attributedText = attributedText
        textView.linkTextAttributes = [.foregroundColor: UIColor(designSystemColor: .accent)]
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0

        return textView
    }()

    private func installSubviews() {
        addSubview(title)
    }

    private func installConstraints() {
        title.translatesAutoresizingMaskIntoConstraints = false
        
        let bottomConstraint = title.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -Constants.defaultPadding)
        // setting priority to ensure multiline text is displayed correctly
        bottomConstraint.priority = .defaultHigh

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: self.topAnchor, constant: Constants.topPadding),
            bottomConstraint,
            title.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.defaultPadding),
            title.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -Constants.defaultPadding)
        ])
    }
}

extension AutofillSettingsEnableFooterView: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        textView.selectedTextRange = nil
    }
}
