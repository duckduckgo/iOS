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
import Bookmarks

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
    @IBOutlet weak var deleteButton: UIButton!

    static let appUrls = AppUrls()

    var isEditing = false {
        didSet {
            deleteButton.isHidden = !isEditing
        }
    }

    var truncatedUrlString: String? {
        guard let url = favorite?.url else { return nil }
        let urlString = url.prefix(100).description
        let ellipsis = url.count != urlString.count ? "…" : ""
        return urlString + ellipsis
    }

    var title: String? {
        favorite?.title
    }
    
    var onRemove: (() -> Void)?
    var onEdit: (() -> Void)?
    
    var favorite: BookmarkEntity?
    private var theme: Theme?
    
    struct Actions {
        static let remove = #selector(FavoriteHomeCell.doRemove(sender:))
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
        FavoriteHomeCell.applyDropshadow(to: deleteButton)
        layer.cornerRadius = 8
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if deleteButton.frame.contains(point) {
            return deleteButton
        }
        return super.hitTest(point, with: event)
    }

    @objc func doRemove(sender: Any?) {
        onRemove?()
    }
    
    @objc func doEdit(sender: Any?) {
        onEdit?()
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return [ Actions.remove, Actions.edit ].contains(action)
    }

    @IBAction func onRemovePressed() {
        doRemove(sender: nil)
    }
    
    func updateFor(favorite: BookmarkEntity) {
        self.favorite = favorite
        
        let host = favorite.host
        let color = UIColor.forDomain(host)
        
        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = "\(favorite.displayTitle). \(UserText.favorite)"
        
        titleLabel.text = favorite.displayTitle
        iconBackground.backgroundColor = color

        let iconImage = self.iconImage
        let domain = favorite.host
        let fakeFavicon = FaviconsHelper.createFakeFavicon(forDomain: domain,
                                                           backgroundColor: color,
                                                           bold: false)
        iconImage?.image = fakeFavicon

        iconImage?.loadFavicon(forDomain: domain, usingCache: .bookmarks, useFakeFavicon: false) { image, _ in
            guard let image = image else {
                iconImage?.image = fakeFavicon
                return
            }

            let useBorder = Self.appUrls.isDuckDuckGo(domain: domain) || image.size.width < Constants.largeFaviconSize
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

private extension BookmarkEntity {

    var displayTitle: String {
        if let title = title?.trimmingWhitespace() {
            return title
        }

        if let host = urlObject?.host?.droppingWwwPrefix() {
            return host
        }

        assertionFailure("Unable to create display title")
        return ""
    }

    var host: String {
        return urlObject?.host?.droppingWwwPrefix() ?? ""
    }

}

extension FavoriteHomeCell: Themable {
    
    func decorate(with theme: Theme) {
        self.theme = theme
        titleLabel.textColor = theme.favoriteTextColor
        if let favorite = favorite {
            updateFor(favorite: favorite)
        }
    }

}
