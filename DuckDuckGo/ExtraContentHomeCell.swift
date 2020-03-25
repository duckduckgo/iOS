//
//  ExtraContentHomeCell.swift
//  DuckDuckGo
//
//  Created by Bartek on 24/03/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import UIKit

class ExtraContentHomeCell: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var roundedBackground: UIView!
    @IBOutlet weak var dismissButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        ExtraContentHomeCell.applyDropshadow(to: roundedBackground!)
    }
    
    class func applyDropshadow(to view: UIView) {
        view.layer.shadowRadius = 1
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.12
        view.layer.masksToBounds = false
    }

}

extension ExtraContentHomeCell: Themable {
    
    func decorate(with theme: Theme) {
        label.textColor = theme.barTintColor
        dismissButton.tintColor = theme.barTintColor
        roundedBackground.backgroundColor = theme.faviconBackgroundColor
    }

}
