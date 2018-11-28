//
//  AddFavoriteHomeCell.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 28/11/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import UIKit

class AddFavoriteHomeCell: ThemableCollectionViewCell {
    
    @IBOutlet weak var plusImage: UIImageView!
    @IBOutlet weak var plusBackground: UIView!
    
    override func decorate(with theme: Theme) {
        
        switch theme.currentImageSet {
        case .light:
            plusImage.tintColor = UIColor.greyish.applyAlpha(0.6)
            plusBackground.backgroundColor = UIColor.mercury
            
        case .dark:
            plusImage.tintColor = UIColor.darkGreyish.applyAlpha(0.6)
            plusBackground.backgroundColor = UIColor.black
        }
    }
    
}

fileprivate extension UIColor {
    
    func applyAlpha(_ alpha: CGFloat) -> UIColor {
        return UIColor(red: redComponent, green: greenComponent, blue: blueComponent, alpha: alpha)
    }
    
}
