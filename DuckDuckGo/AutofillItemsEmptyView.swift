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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        installSubviews()
        installConstraints()
    }
    
    var viewState: ViewState = .autofillEnabled {
        didSet {
            updateLabels(with: viewState)
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
        label.font = .preferredFont(forTextStyle: .footnote, compatibleWith: nil)
        label.textColor = .gray70
        label.text = UserText.autofillEmptyViewSubtitle

        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let image = UIImage(named: "AutofillKey")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 0, width: 87, height: 87)

        return imageView
    }()
    
    private lazy var stackContentView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, title])
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
    
    private func installSubviews() {
        addSubview(stackContentView)
        addSubview(subtitle)
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
        
        NSLayoutConstraint.activate([
            stackContentView.topAnchor.constraint(equalTo: topAnchor, constant: 67),
            stackContentView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackContentView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackContentView.widthAnchor.constraint(equalToConstant: 225),

            subtitle.centerXAnchor.constraint(equalTo: centerXAnchor),
            subtitle.topAnchor.constraint(equalTo: stackContentView.bottomAnchor, constant: 27),
            subtitle.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
            subtitle.leadingAnchor.constraint(equalTo: stackContentView.leadingAnchor),
            subtitle.trailingAnchor.constraint(equalTo: stackContentView.trailingAnchor)
        ])
    }
}

extension AutofillItemsEmptyView: Themable {
    
    func decorate(with theme: Theme) {
        title.textColor = theme.autofillDefaultTitleTextColor
        subtitle.textColor = theme.autofillDefaultSubtitleTextColor
    }
}
