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
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var iconBackground: UIView!
    @IBOutlet weak var iconImage: UIImageView!
    
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
        
        titleLabel.text = link.title
        
        iconImage.isHidden = true
        iconLabel.isHidden = false
        
        iconBackground.backgroundColor = host.color
        
        if let domain = link.url.host {
            let resource = AppUrls().faviconUrl(forDomain: domain)
            iconImage.kf.setImage(with: resource, placeholder: nil, options: nil, progressBlock: nil) { [weak self] image, error, _, _ in
                guard error == nil else { return }
                guard let image = image else { return }
                guard image.size.width > 16 else { return }
                self?.applyFavicon(image)
            }
        }
        
    }
    
    private func applyFavicon(_ image: UIImage) {

        iconLabel.isHidden = true
        iconImage.isHidden = false
        iconImage.contentMode = image.size.width < 40 ? .center : .scaleAspectFit
        
        guard let theme = theme else { return }
        switch theme.currentImageSet {
        case .dark:
            iconBackground.backgroundColor = UIColor.charcoalGrey
            
        case .light:
            iconBackground.backgroundColor = UIColor.white
        }
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
        
        switch theme.currentImageSet {
        case .dark:
            titleLabel.textColor = UIColor.greyish
            
        case .light:
            titleLabel.textColor = UIColor.darkGreyish
        }
        
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
            UIColor.fromHexString("94B3AF"),
            UIColor.fromHexString("727998"),
            UIColor.fromHexString("645468"),
            UIColor.fromHexString("4D5F7F"),
            UIColor.fromHexString("855DB6"),
            UIColor.fromHexString("5E5ADB"),
            UIColor.fromHexString("678FFF"),
            UIColor.fromHexString("6BB4EF"),
            UIColor.fromHexString("4A9BAE"),
            UIColor.fromHexString("66C4C6"),
            UIColor.fromHexString("55D388"),
            UIColor.fromHexString("99DB7A"),
            UIColor.fromHexString("ECCC7B"),
            UIColor.fromHexString("E7A538"),
            UIColor.fromHexString("DD6B4C"),
            UIColor.fromHexString("D65D62")
        ]
        
        let hash = consistentHash
        let index = hash % palette.count
        return palette[abs(index)]
    }
    
}

extension UIColor {

    // from: https://stackoverflow.com/a/27203691/73479
    class func fromHexString(_ hex: String) -> UIColor {
        var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }
        
        if (cString.count) != 6 {
            return UIColor.gray
        }
        
        var rgbValue: UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
}
