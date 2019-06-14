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
import Kingfisher

class FavoriteHomeCell: UICollectionViewCell {

    struct Constants {
        static let width: CGFloat = 68
        static let height: CGFloat = 100
        static let smallFaviconSize: CGFloat = 16
        static let largeFaviconSize: CGFloat = 40
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var iconBackground: UIView!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var highlightMask: UIView!
    
    @IBOutlet var iconConstraints: [NSLayoutConstraint]!
    
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
        iconImage.layer.cornerRadius = 3
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
        iconLabel.text = "\(host.capitalized.first ?? " ")"
        
        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = "\(link.title ?? "")). \(UserText.favorite)"
        
        titleLabel.text = link.title
        
        iconImage.isHidden = true
        iconLabel.isHidden = false
        
        iconBackground.backgroundColor = host.color
        
        if let domain = link.url.host {
            let resource = AppUrls().faviconUrl(forDomain: domain)
            iconImage.kf.setImage(with: resource,
                                  placeholder: nil,
                                  options: [
                                    .downloader(NotFoundCachingDownloader(name: "hello"))
                                    ],
                                  progressBlock: nil) { [weak self] image, error, _, _ in
                                    
                guard error == nil else {
                    NotFoundCachingDownloader.cacheNotFound(resource)
                    return
                }
                guard let image = image else {
                    NotFoundCachingDownloader.cacheNotFound(resource)
                    return
                }
                                    
                guard image.size.width > Constants.smallFaviconSize else { return }
                self?.applyFavicon(image)
            }
        }
        
    }
    
    private func applyFavicon(_ image: UIImage) {

        iconLabel.isHidden = true
        iconImage.isHidden = false
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

fileprivate extension String {
    
    var consistentHash: Int {
        return self.utf8
            .map { return $0 }
            .reduce(5381) { ($0 << 5) &+ $0 &+ Int($1) }
    }
    
    var color: UIColor {
        
        let palette = [
            UIColor(hex: "94B3AF"),
            UIColor(hex: "727998"),
            UIColor(hex: "645468"),
            UIColor(hex: "4D5F7F"),
            UIColor(hex: "855DB6"),
            UIColor(hex: "5E5ADB"),
            UIColor(hex: "678FFF"),
            UIColor(hex: "6BB4EF"),
            UIColor(hex: "4A9BAE"),
            UIColor(hex: "66C4C6"),
            UIColor(hex: "55D388"),
            UIColor(hex: "99DB7A"),
            UIColor(hex: "ECCC7B"),
            UIColor(hex: "E7A538"),
            UIColor(hex: "DD6B4C"),
            UIColor(hex: "D65D62")
        ]
        
        let hash = consistentHash
        let index = hash % palette.count
        return palette[abs(index)]
    }
    
}

fileprivate extension UIColor {

    convenience init(hex: String) {
        var rgbValue: UInt32 = 0
        Scanner(string: hex).scanHexInt32(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
}
