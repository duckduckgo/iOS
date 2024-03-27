//
//  AutofillEmptySearchView.swift
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

class AutofillEmptySearchView: UIView {

    private lazy var title: UILabel = {
        let label = UILabel(frame: CGRect.zero)

        label.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .title2).pointSize * 1.091, weight: .regular)
        label.text = UserText.autofillSearchNoResultTitle
        label.numberOfLines = 0
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private lazy var subtitle: UILabel = {
        let label = UILabel(frame: CGRect.zero)

        label.font = .preferredFont(forTextStyle: .callout)
        label.text = ""
        label.numberOfLines = 0
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private lazy var stackContentView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [title, subtitle])
        stackView.axis = .vertical
        stackView.spacing = 3
        return stackView
    }()
    
    var query: String = "" {
        didSet {
            if query.count > 0 {
                subtitle.text = UserText.autofillSearchNoResultSubtitle(for: query)
            } else {
                subtitle.text = ""
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        installSubviews()
        installConstraints()
        decorate()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func installSubviews() {
        addSubview(stackContentView)
    }
    
    private func installConstraints() {
        stackContentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackContentView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackContentView.centerYAnchor.constraint(equalTo: centerYAnchor),
            heightAnchor.constraint(equalTo: stackContentView.heightAnchor),
            widthAnchor.constraint(equalTo: stackContentView.widthAnchor)
        ])
    }
}

extension AutofillEmptySearchView {

    private func decorate() {
        let theme = ThemeManager.shared.currentTheme
        title.textColor = theme.autofillEmptySearchViewTextColor
        subtitle.textColor = theme.autofillEmptySearchViewTextColor
    }
}
