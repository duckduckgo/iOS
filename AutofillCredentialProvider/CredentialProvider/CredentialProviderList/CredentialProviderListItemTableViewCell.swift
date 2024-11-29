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
        installConstraints()
    }
    
    private func installConstraints() {
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let imageSize: CGFloat = 32
        let margins = contentView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: imageSize),
            iconImageView.heightAnchor.constraint(equalToConstant: imageSize),
            
            contentStackView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            contentStackView.topAnchor.constraint(equalTo: margins.topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: margins.bottomAnchor)
        ])
    }
    
    private func setupContentView(with item: AutofillLoginItem) {
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        iconImageView.image = loadImageFromCache(forDomain: item.account.domain)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentStackView.frame = contentView.bounds
        
        separatorInset = UIEdgeInsets(top: 0, left: contentView.layoutMargins.left + textStackView.frame.origin.x, bottom: 0, right: 0)
    }
    
    
    private func loadImageFromCache(forDomain domain: String?) -> UIImage? {
        guard let domain = domain else { return nil }
        
        let key = FaviconHasher.createHash(ofDomain: domain)
        guard let cacheUrl = FaviconsCacheType.fireproof.cacheLocation() else { return nil }
        
        // Slight leap here to avoid loading Kingisher as a library for the widgets.
        // Once dependency management is fixed, link it and use Favicons directly.
        let imageUrl = cacheUrl.appendingPathComponent("com.onevcat.Kingfisher.ImageCache.fireproof").appendingPathComponent(key)
        
        guard let data = (try? Data(contentsOf: imageUrl)) else {
            let image = createFakeFavicon(forDomain: domain, size: 32, backgroundColor: UIColor.forDomain(domain), preferredFakeFaviconLetters: item?.preferredFaviconLetters)
            return image
        }
        
        return UIImage(data: data)?.toSRGB()
    }
    
    private func createFakeFavicon(forDomain domain: String,
                                   size: CGFloat = 192,
                                   backgroundColor: UIColor = UIColor.red,
                                   bold: Bool = true,
                                   preferredFakeFaviconLetters: String? = nil,
                                   letterCount: Int = 2) -> UIImage? {
        
        let cornerRadius = size * 0.125
        let imageRect = CGRect(x: 0, y: 0, width: size, height: size)
        let padding = size * 0.16
        let labelFrame = CGRect(x: padding, y: padding, width: imageRect.width - (2 * padding), height: imageRect.height - (2 * padding))
        
        let renderer = UIGraphicsImageRenderer(size: imageRect.size)
        let icon = renderer.image { imageContext in
            let context = imageContext.cgContext
            
            context.setFillColor(backgroundColor.cgColor)
            context.addPath(CGPath(roundedRect: imageRect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil))
            context.fillPath()
            
            let label = UILabel(frame: labelFrame)
            label.numberOfLines = 1
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.1
            label.baselineAdjustment = .alignCenters
            label.font = bold ? UIFont.boldSystemFont(ofSize: size) : UIFont.systemFont(ofSize: size)
            label.textColor = .white
            label.textAlignment = .center
            
            if let prefferedPrefix = preferredFakeFaviconLetters?.droppingWwwPrefix().prefix(letterCount).capitalized {
                label.text = prefferedPrefix
            } else {
                label.text = item?.preferredFaviconLetters.capitalized ?? "#"
            }
            
            context.translateBy(x: padding, y: padding)
            
            label.layer.draw(in: context)
        }
        
        return icon.withRenderingMode(.alwaysOriginal)
    }
    
}
