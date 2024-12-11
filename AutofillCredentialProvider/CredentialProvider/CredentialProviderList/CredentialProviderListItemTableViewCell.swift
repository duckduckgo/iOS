//
//  CredentialProviderListItemTableViewCell.swift
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

import UIKit
import Core
import DesignResourcesKit

class CredentialProviderListItemTableViewCell: UITableViewCell {
    
    static var reuseIdentifier = "CredentialProviderListItemTableViewCell"

    var disclosureButtonTapped: (() -> Void)?

    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.font = .preferredFont(forTextStyle: .callout)
        label.textColor = .init(designSystemColor: .textPrimary)
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textColor = .init(designSystemColor: .textPrimary)
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 4
        return imageView
    }()
    
    private lazy var textStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 3
        return stackView
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [iconImageView, textStackView])
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .center
        return stackView
    }()

    private lazy var disclosureButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "chevron.forward")
        let boldImage = image?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 11, weight: .bold))
        button.setImage(boldImage, for: .normal)
        button.tintColor = UIColor.tertiaryLabel
        button.addTarget(self, action: #selector(handleDisclosureButtonTap), for: .touchUpInside)

        let buttonSize: CGFloat = 44
        button.frame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center

        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        installSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var item: AutofillLoginItem? {
        didSet {
            guard let item = item else {
                return
            }
            setupContentView(with: item)
        }
    }
    
    private func installSubviews() {
        contentView.addSubview(contentStackView)
        contentView.addSubview(disclosureButton)
        installConstraints()
    }
    
    private func installConstraints() {
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        disclosureButton.translatesAutoresizingMaskIntoConstraints = false

        let imageSize: CGFloat = 32
        let margins = contentView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: imageSize),
            iconImageView.heightAnchor.constraint(equalToConstant: imageSize),

            disclosureButton.widthAnchor.constraint(equalToConstant: 44),
            disclosureButton.heightAnchor.constraint(equalToConstant: 44),
            disclosureButton.centerYAnchor.constraint(equalTo: margins.centerYAnchor),
            disclosureButton.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: 16),

            contentStackView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: disclosureButton.leadingAnchor, constant: -12),
            contentStackView.topAnchor.constraint(equalTo: margins.topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: margins.bottomAnchor)
        ])
    }
    
    private func setupContentView(with item: AutofillLoginItem) {
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        iconImageView.image = FaviconHelper.loadImageFromCache(forDomain: item.account.domain, preferredFakeFaviconLetters: item.preferredFaviconLetters)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentStackView.frame = contentView.bounds
        
        separatorInset = UIEdgeInsets(top: 0, left: contentView.layoutMargins.left + textStackView.frame.origin.x, bottom: 0, right: 0)
    }

    @objc private func handleDisclosureButtonTap() {
        disclosureButtonTapped?()
    }

}
