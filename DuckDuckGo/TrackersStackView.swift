//
//  TrackersStackView.swift
//  DuckDuckGo
//
//  Created by Bartek on 09/04/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import UIKit

class TrackersStackView: UIStackView {

    @IBOutlet var firstIcon: UIImageView!
    @IBOutlet var secondIcon: UIImageView!
    @IBOutlet var thirdIcon: UIImageView!
    
    var crossOutBackgroundColor: UIColor = .clear
    
    func animateTrackers() {
        
        let visibleIcons = [firstIcon, secondIcon, thirdIcon]

        visibleIcons.forEach { imageView in
            imageView?.animateCrossOut(foregroundColor: self.tintColor!,
                                       backgroundColor: self.crossOutBackgroundColor)
        }
    }
    
    func resetTrackers() {
        
        let visibleIcons = [firstIcon, secondIcon, thirdIcon]

        visibleIcons.forEach { imageView in
            imageView?.resetCrossOut()
        }
    }
}
