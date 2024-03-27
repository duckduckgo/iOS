//
//  AutofillNoAuthAvailableView.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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

class AutofillNoAuthAvailableView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        installSubviews()
        installConstraints()
        decorate()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var keyImageView: UIImageView = {
        let image = UIImage(named: "AutofillKey")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 0, width: 220, height: 170)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        imageView.setContentHuggingPriority(.defaultHigh, for: .vertical)

        return imageView
    }()

    private lazy var title: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title3)
        label.font = UIFont.systemFont(ofSize: descriptor.pointSize, weight: .semibold)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.textColor = .gray90
        label.text = UserText.autofillNoAuthViewTitle

        return label
    }()

    private lazy var subtitle: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textColor = .gray70
        label.text = UserText.autofillNoAuthViewSubtitle

        return label
    }()

    private lazy var lockImageView: UIImageView = {
        let image = UIImage(named: "AutofillLock")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 0, width: 128, height: 96)

        return imageView
    }()

    private lazy var stackContentView: UIStackView = {
        let spacerView = UIView()
        let stackView = UIStackView(arrangedSubviews: [title, subtitle, lockImageView])
        stackView.axis = .vertical

        return stackView
    }()

    private lazy var outerStackContentView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [keyImageView, stackContentView])
        stackView.axis = .vertical

        return stackView
    }()

    private lazy var leadingConstraint: NSLayoutConstraint = {
        outerStackContentView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16)
    }()

    private lazy var trailingConstraint: NSLayoutConstraint = {
        outerStackContentView.trailingAnchor.constraint(greaterThanOrEqualTo: trailingAnchor, constant: -16)
    }()

    private lazy var topConstraintIPhoneLandscape: NSLayoutConstraint = {
        NSLayoutConstraint(item: self,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: outerStackContentView,
                           attribute: .top,
                           multiplier: 1,
                           constant: -44)
    }()

    private lazy var bottomConstraintIPhoneLandscape: NSLayoutConstraint = {
        NSLayoutConstraint(item: self,
                           attribute: .bottomMargin,
                           relatedBy: .equal,
                           toItem: outerStackContentView,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 16)
    }()

    private lazy var centerYConstraint: NSLayoutConstraint = {
        NSLayoutConstraint(item: self,
                           attribute: .centerY,
                           relatedBy: .equal,
                           toItem: outerStackContentView,
                           attribute: .centerY,
                           multiplier: 1.1,
                           constant: 0)
    }()

    private lazy var widthConstraintIPhonePortrait: NSLayoutConstraint = {
        outerStackContentView.widthAnchor.constraint(equalToConstant: 250)
    }()

    private lazy var heightConstraint: NSLayoutConstraint = {
        heightAnchor.constraint(equalTo: stackContentView.heightAnchor)
    }()

    private func installSubviews() {
        addSubview(stackContentView)
        addSubview(outerStackContentView)
    }

    private func installConstraints() {
        stackContentView.translatesAutoresizingMaskIntoConstraints = false
        outerStackContentView.translatesAutoresizingMaskIntoConstraints = false

        outerStackContentView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true

        refreshConstraints()
    }

    func refreshConstraints() {
        let isIPhonePortrait = traitCollection.verticalSizeClass == .regular && traitCollection.horizontalSizeClass == .compact
        let isIPad = traitCollection.verticalSizeClass == .regular && traitCollection.horizontalSizeClass == .regular

        if isIPhonePortrait {
            NSLayoutConstraint.deactivate([topConstraintIPhoneLandscape, bottomConstraintIPhoneLandscape, leadingConstraint, trailingConstraint])
            NSLayoutConstraint.activate([heightConstraint, widthConstraintIPhonePortrait, centerYConstraint])
            stackContentView.spacing = 27
            outerStackContentView.spacing = 4
        } else if isIPad {
            NSLayoutConstraint.activate([heightConstraint, leadingConstraint, trailingConstraint, centerYConstraint])
            stackContentView.spacing = 16
            outerStackContentView.spacing = 16
        } else {
            NSLayoutConstraint.deactivate([centerYConstraint, widthConstraintIPhonePortrait, heightConstraint])
            NSLayoutConstraint.activate([topConstraintIPhoneLandscape, bottomConstraintIPhoneLandscape, leadingConstraint, trailingConstraint])
            stackContentView.spacing = 8
            outerStackContentView.spacing = 0
        }
        invalidateIntrinsicContentSize()
    }
}

extension AutofillNoAuthAvailableView {

    private func decorate() {
        let theme = ThemeManager.shared.currentTheme
        title.textColor = theme.autofillDefaultTitleTextColor
        subtitle.textColor = theme.autofillDefaultSubtitleTextColor
    }
}
