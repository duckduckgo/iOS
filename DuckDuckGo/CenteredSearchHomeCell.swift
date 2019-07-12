//
//  CenteredSearchHomeCell.swift
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

class CenteredSearchHomeCell: UICollectionViewCell {
    
    struct Constants {
        
        static let searchWidth: CGFloat = 380
        static let searchWidthPad: CGFloat = 455
        static let targetSearchLeadingOffset: CGFloat = -18
        static let targetSearchTrailingOffset: CGFloat = 16
        static let targetSearchLoupeOffset: CGFloat = -9
        
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var searchBackground: RoundedRectangleView!
    @IBOutlet weak var searchBackgroundHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchBackgroundLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchBackgroundTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchLoupeLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var promptText: UILabel!
    @IBOutlet weak var searchLoupe: UIImageView!
    
    private lazy var tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap))

    var tapped: ((CenteredSearchHomeCell) -> Void)?
    
    var targetSearchHeight: CGFloat!
    var targetSearchRadius: CGFloat!
    var defaultSearchLoupeOffset: CGFloat!
    var defaultSearchHeight: CGFloat!
    var defaultSearchRadius: CGFloat!

    var defaultSearchBackgroundMargin: CGFloat {

        if isPad {
            return (frame.width - Constants.searchWidthPad) / 2
        }

        return isPortrait && !isPad ? 0 : (frame.width - Constants.searchWidth) / 2
    }
    
    var searchHeaderTransition: CGFloat = 0.0 {
        didSet {
            updateForTransition()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        searchBackground.addGestureRecognizer(tapGesture)
        defaultSearchHeight = searchBackground.frame.height
        defaultSearchRadius = searchBackground.layer.cornerRadius
        defaultSearchLoupeOffset = searchLoupeLeadingConstraint.constant
    }

    @objc func onTap() {
        Pixel.fire(pixel: .homeScreenSearchTapped)
        tapped?(self)
    }

    private func updateForTransition() {
        let heightDiff = defaultSearchHeight - targetSearchHeight
        searchBackgroundHeightConstraint.constant = defaultSearchHeight - (heightDiff * searchHeaderTransition)
        
        let radiusDiff = defaultSearchRadius - targetSearchRadius
        searchBackground.layer.cornerRadius = defaultSearchRadius - (radiusDiff * searchHeaderTransition)
        
        let leadingOffset = Constants.targetSearchLeadingOffset * searchHeaderTransition
        searchBackgroundLeadingConstraint.constant = leadingOffset + (defaultSearchBackgroundMargin * (1 - searchHeaderTransition))
        
        let trailingOffset = Constants.targetSearchTrailingOffset * searchHeaderTransition
        searchBackgroundTrailingConstraint.constant = trailingOffset + (defaultSearchBackgroundMargin * (1 - searchHeaderTransition))

        let searchLoupeDiff: CGFloat = Constants.targetSearchLoupeOffset
        searchLoupeLeadingConstraint.constant = defaultSearchLoupeOffset + (searchLoupeDiff * searchHeaderTransition)
        
        searchBackground.isAccessibilityElement = searchHeaderTransition < 1.0
    }
    
}

extension CenteredSearchHomeCell: Themable {
    func decorate(with theme: Theme) {
        // called on rotation too, so ideal time to update
        updateForTransition()
        
        searchBackground.backgroundColor = theme.centeredSearchBarBackgroundColor
        searchLoupe.tintColor = theme.barTintColor
        
        promptText.textColor = theme.searchBarTextPlaceholderColor
        
        switch theme.currentImageSet {
        case .light:
            imageView.image = UIImage(named: "LogoDarkText")
        case .dark:
            imageView.image = UIImage(named: "LogoLightText")
        }
    }
}
