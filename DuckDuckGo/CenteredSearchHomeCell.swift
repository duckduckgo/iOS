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
    @IBOutlet weak var settingsButton: UIButton!
    
    private lazy var tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap))
    
    var settingsTapped: ((CenteredSearchHomeCell) -> Void)?
    var tapped: ((CenteredSearchHomeCell) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        searchBackground.addGestureRecognizer(tapGesture)
    }
    
    override func decorate(with theme: Theme) {
        searchBackground.backgroundColor = theme.searchBarBackgroundColor
        searchLoupe.tintColor = theme.barTintColor
        promptText.textColor = UIColor.greyish // TODO should this be a themeable color (if so also apply to omnibar)

        switch theme.currentImageSet {
        case .light:
            imageView.image = UIImage(named: "LogoDarkText")
            settingsButton.tintColor = UIColor.darkGreyish
        case .dark:
            imageView.image = UIImage(named: "LogoLightText")
            settingsButton.tintColor = UIColor.greyish
        }
    }
    
    @IBAction func onSettingsTapped() {
        settingsTapped?(self)
    }
    
    @objc func onTap() {
        tapped?(self)
    }
    
}
