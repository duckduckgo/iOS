//
//  AutofillItemsEmptyView.swift
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
import DuckUI

class AutofillItemsEmptyView: UIView {
    
    enum ViewState {
        case autofillEnabled
        case autofillDisabled
    }

    private enum Constants {
        static let defaultPadding: CGFloat = 15
        static let portraitPaddingImageTitle: CGFloat = 8
        static let portraitPaddingTitleSubtitle: CGFloat = 27
        static let portraitPaddingTitle: CGFloat = 24
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        installSubviews()
        installConstraints()
    }
    
    var viewState: ViewState = .autofillEnabled {
        didSet {
            updateLabels(with: viewState)
            refreshConstraints()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var title: UILabel = {
        let label = UILabel(frame: CGRect.zero)

        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title3)
        label.font = UIFont.systemFont(ofSize: descriptor.pointSize, weight: .semibold)
        
        label.numberOfLines = 0
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.textColor = .gray90
        
        return label
    }()
    
    private lazy var subtitle: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textColor = .gray70
        label.text = UserText.autofillEmptyViewSubtitle

        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let image = UIImage(named: "AutofillKey")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 0, width: 220, height: 170)

        return imageView
    }()
    
    private lazy var stackContentView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, title])
        stackView.axis = .vertical
        return stackView
    }()

    private lazy var outerStackContentView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [stackContentView, subtitle])
        stackView.axis = .vertical
        return stackView
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

    private lazy var topConstraintIPhonePortrait: NSLayoutConstraint = {
        NSLayoutConstraint(item: self,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: outerStackContentView,
                           attribute: .top,
                           multiplier: 1,
                           constant: -66)
    }()

    private func installSubviews() {
        addSubview(stackContentView)
        addSubview(subtitle)
        addSubview(outerStackContentView)
    }

    private func updateLabels(with state: AutofillItemsEmptyView.ViewState) {
        switch state {
        case .autofillDisabled:
            title.text = UserText.autofillEmptyViewTitleDisabled
        case .autofillEnabled:
            title.text = UserText.autofillEmptyViewTitle
        }
    }
    
    private func installConstraints() {
        stackContentView.translatesAutoresizingMaskIntoConstraints = false
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        outerStackContentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            outerStackContentView.centerXAnchor.constraint(equalTo: centerXAnchor),
            outerStackContentView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
            outerStackContentView.trailingAnchor.constraint(greaterThanOrEqualTo: trailingAnchor, constant: -16)
        ])

        refreshConstraints()
    }

    func refreshConstraints() {
        let isIPhonePortrait = traitCollection.verticalSizeClass == .regular && traitCollection.horizontalSizeClass == .compact

        if isIPhonePortrait {
            centerYConstraint.isActive = !isIPhonePortrait
            topConstraintIPhonePortrait.isActive = isIPhonePortrait
            widthConstraintIPhonePortrait.isActive = isIPhonePortrait
            stackContentView.spacing = Constants.portraitPaddingImageTitle
            if viewState == .autofillEnabled {
                outerStackContentView.spacing = Constants.portraitPaddingTitleSubtitle + Constants.portraitPaddingTitle
            } else {
                outerStackContentView.spacing = Constants.portraitPaddingTitleSubtitle
            }
        } else {
            topConstraintIPhonePortrait.isActive = isIPhonePortrait
            widthConstraintIPhonePortrait.isActive = isIPhonePortrait
            centerYConstraint.isActive = !isIPhonePortrait
            stackContentView.spacing = Constants.defaultPadding
            outerStackContentView.spacing = Constants.defaultPadding
        }
        invalidateIntrinsicContentSize()
    }
}

extension AutofillItemsEmptyView: Themable {
    
    func decorate(with theme: Theme) {
        title.textColor = theme.autofillDefaultTitleTextColor
        subtitle.textColor = theme.autofillDefaultSubtitleTextColor
    }
}
