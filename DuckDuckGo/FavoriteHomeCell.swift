//
//  FavoriteHomeCell.swift
//  DuckDuckGo
//
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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

class FavoriteHomeCell: UICollectionViewCell {

    struct Constants {
        static let smallFaviconSize: CGFloat = 16
        static let largeFaviconSize: CGFloat = 40
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconBackground: UIView!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var highlightMask: UIView!
    @IBOutlet weak var iconSize: NSLayoutConstraint!
    
    static let appUrls = AppUrls()
    
    var isReordering = false {
        didSet {
            let scale: CGFloat = isReordering ? 1.2 : 1.0
            transform = CGAffineTransform.identity.scaledBy(x: scale, y: scale)
            contentView.alpha = isReordering ? 0.5 : 1.0
        }
    }
    
    var onDelete: (() -> Void)?
    var onEdit: (() -> Void)?
    
    private var link: Link?
    private var theme: Theme?
    
    struct Actions {
        static let delete = #selector(FavoriteHomeCell.doDelete(sender:))
        static let edit = #selector(FavoriteHomeCell.doEdit(sender:))
    }
    
    override var isHighlighted: Bool {
        didSet {
            highlightMask.isHidden = !isHighlighted
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        FavoriteHomeCell.applyDropshadow(to: iconBackground)
    }
    
    @objc func doDelete(sender: Any?) {
        onDelete?()
    }
    
    @objc func doEdit(sender: Any?) {
        onEdit?()
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return [ Actions.delete, Actions.edit ].contains(action)
    }
    
    func updateFor(link: Link) {
        self.link = link
        
        let host = link.url.host?.dropPrefix(prefix: "www.") ?? ""
        
        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = "\(link.displayTitle ?? "")). \(UserText.favorite)"
        
        titleLabel.text = link.displayTitle
        iconBackground.backgroundColor = UIColor.forDomain(host)
        
        if let domain = link.url.host?.dropPrefix(prefix: "www."),
           let fakeFavicon = UIImageView.createFakeFavicon(forDomain: link.url.host ?? "", backgroundColor: UIColor.forDomain(domain), bold: false) {
            iconImage.image = fakeFavicon
        }

        iconImage.loadFavicon(forDomain: link.url.host, usingCache: .bookmarks, useFakeFavicon: false) { image, _ in
            guard let image = image else { return }

            let useBorder = Self.appUrls.isDuckDuckGo(domain: link.url.host) || image.size.width < Constants.largeFaviconSize
            self.useImageBorder(useBorder)
            self.applyFavicon(image)
        }
    }

    private func useImageBorder(_ border: Bool) {
        iconSize.constant = border ? -24 : 0
        iconImage.layer.masksToBounds = !border
        iconImage.layer.cornerRadius = border ? 3 : 8
    }
  
    private func applyFavicon(_ image: UIImage) {

        iconImage.contentMode = image.size.width < Constants.largeFaviconSize ? .center : .scaleAspectFit

        guard let theme = theme else { return }
        iconBackground.backgroundColor = theme.faviconBackgroundColor
    }
    
    class func applyDropshadow(to view: UIView) {
        view.layer.shadowRadius = 1
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.12
        view.layer.masksToBounds = false
    }
    
}

extension FavoriteHomeCell: Themable {
    
    func decorate(with theme: Theme) {
        self.theme = theme
        titleLabel.textColor = theme.favoriteTextColor
        if let link = link {
            updateFor(link: link)
        }
    }

}
