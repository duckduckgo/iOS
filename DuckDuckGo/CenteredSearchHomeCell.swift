//
//  CenteredSearchHomeCell.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 28/11/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import UIKit

class CenteredSearchHomeCell: ThemableCollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var searchBackground: RoundedRectangleView!
    @IBOutlet weak var promptText: UILabel!
    @IBOutlet weak var searchLoupe: UIImageView!
    
    private lazy var tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap))
    
    var tapped: ((CenteredSearchHomeCell) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        searchBackground.addGestureRecognizer(tapGesture)
    }
    
    override func decorate(with theme: Theme) {
        searchBackground.backgroundColor = theme.searchBarBackgroundColor
        searchLoupe.tintColor = theme.barTintColor
        
        // omnibar also uses this, maybe it should be themeable?
        promptText.textColor = UIColor.greyish

        switch theme.currentImageSet {
        case .light:
            imageView.image = UIImage(named: "LogoDarkText")
        case .dark:
            imageView.image = UIImage(named: "LogoLightText")
        }
    }
    
    @objc func onTap() {
        tapped?(self)
    }
    
}
