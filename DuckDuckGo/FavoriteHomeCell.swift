//
//  FavoriteHomeCell.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 28/11/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import UIKit
import Core

class FavoriteHomeCell: ThemableCollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var iconBackground: UIView!
    @IBOutlet weak var iconImage: UIImageView!
    
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
    }
    
    @objc func doDelete(sender: Any?) {
        print("***", #function)
        onDelete?()
    }
    
    @objc func doEdit(sender: Any?) {
        print("***", #function)
        onEdit?()
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        print("***", #function, action)
        return [ Actions.delete, Actions.edit ].contains(action)
    }
    
    override func decorate(with theme: Theme) {
        super.decorate(with: theme)
        self.theme = theme
        
        switch theme.currentImageSet {
        case .dark:
            titleLabel.textColor = UIColor.greyishBrown2
            
        case .light:
            titleLabel.textColor = UIColor.greyish
        }
        
        if let link = link {
            updateFor(link: link)
        }
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
        iconImage.contentMode = image.size.width >= 40 ? .scaleAspectFit : .center
        
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

fileprivate extension String {
    
    var consistentHash: Int {
        return self.utf8
            .map { return $0 }
            .reduce(5381) { ($0 << 5) &+ $0 &+ Int($1) }
    }
    
    var color: UIColor {
        let hash = consistentHash
        let red = CGFloat((hash >> 0) & 0xFF)
        let green = CGFloat((hash >> 8) & 0xFF)
        let blue = CGFloat((hash >> 16) & 0xFF)
        return UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1.0)
    }
    
}
