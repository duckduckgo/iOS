//
//  AutofillListItemTableViewCell.swift
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
import SwiftUI
import DuckUI

@available(iOS 14.0, *)
class AutofillListItemTableViewCell: UITableViewCell {
    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.font = .systemFont(ofSize: 16)
        label.textColor = .gray90
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.font = .systemFont(ofSize: 13)
        label.textColor = .gray50
        return label
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var textStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 3
        return stackView
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [iconImageView, textStackView])
        stackView.axis = .horizontal
        stackView.spacing = 10
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        installSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var viewModel: AutofillLoginListItemViewModel? {
        didSet {
            guard let viewModel = viewModel else {
                return
            }
            setupContentView(with: viewModel)
        }
    }
    
    private func installSubviews() {
        contentView.addSubview(contentStackView)
        installConstraints()
    }
    
    private func installConstraints() {
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        let imageSize: CGFloat = 32
        let margins = contentView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: imageSize),
            
            contentStackView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            contentStackView.topAnchor.constraint(equalTo: margins.topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: margins.bottomAnchor)
        ])
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    private func setupContentView(with item: AutofillLoginListItemViewModel) {
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        iconImageView.loadFavicon(forDomain: item.account.domain, usingCache: .tabs)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentStackView.frame = contentView.bounds
    }
}
