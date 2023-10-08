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
    
    private enum Constants {
        static let imageHeight: CGFloat = 170.0
        static let imageWidth: CGFloat = 220.0
        static let maxWidth: CGFloat = 250.0
        static let topPadding: CGFloat = -64
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        installSubviews()
        installConstraints()
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
        label.text = UserText.autofillEmptyViewTitle
        
        return label
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: .autofillKey)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 0, width: Constants.imageWidth, height: Constants.imageHeight)

        return imageView
    }()
    
    private lazy var stackContentView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, title])
        stackView.axis = .vertical
        return stackView
    }()

    private lazy var centerYConstraint: NSLayoutConstraint = {
        NSLayoutConstraint(item: self,
                           attribute: .centerY,
                           relatedBy: .equal,
                           toItem: stackContentView,
                           attribute: .centerY,
                           multiplier: 1.1,
                           constant: 0)
    }()

    private lazy var topConstraintIPhonePortrait: NSLayoutConstraint = {
        NSLayoutConstraint(item: self,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: stackContentView,
                           attribute: .top,
                           multiplier: 1,
                           constant: Constants.topPadding)
    }()

    private func installSubviews() {
        addSubview(stackContentView)
    }

    private func installConstraints() {
        stackContentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackContentView.widthAnchor.constraint(equalToConstant: Constants.maxWidth),
            stackContentView.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])

        refreshConstraints()
    }

    func refreshConstraints() {
        let isIPhonePortrait = traitCollection.verticalSizeClass == .regular && traitCollection.horizontalSizeClass == .compact

        centerYConstraint.isActive = !isIPhonePortrait
        topConstraintIPhonePortrait.isActive = isIPhonePortrait
    }

    func adjustHeight(to newHeight: CGFloat) {
        frame.size.height = newHeight
    }
}

extension AutofillItemsEmptyView: Themable {
    
    func decorate(with theme: Theme) {
        title.textColor = theme.autofillDefaultTitleTextColor
    }
}

private extension UIImage {
    static let autofillKey = UIImage(named: "AutofillKey")
}
