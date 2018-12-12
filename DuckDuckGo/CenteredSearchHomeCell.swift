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

class CenteredSearchHomeCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var searchBackground: RoundedRectangleView!
    @IBOutlet weak var searchBackgroundHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchBackgroundLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchBackgroundTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchLoupeLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var promptText: UILabel!
    @IBOutlet weak var searchLoupe: UIImageView!
    
    weak var omniBar: OmniBar!
    
    private lazy var tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap))
    
    var targetSearchHeight: CGFloat = 40
    var targetSearchRadius: CGFloat = 20
    
    var tapped: ((CenteredSearchHomeCell) -> Void)?

    var defaultSearchBackgroundMargin: CGFloat {
        return UIDevice.current.orientation.isPortrait ? 0 : (frame.width - 380) / 2
    }
    var defaultSearchLoupeOffset: CGFloat = 15
    var defaultSearchHeight: CGFloat!
    var defaultSearchRadius: CGFloat!
    
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
    }

    @objc func onTap() {
        tapped?(self)
    }

    private func updateForTransition() {
        let heightDiff = defaultSearchHeight - targetSearchHeight
        searchBackgroundHeightConstraint.constant = defaultSearchHeight - (heightDiff * searchHeaderTransition)
        
        let radiusDiff = defaultSearchRadius - targetSearchRadius
        searchBackground.layer.cornerRadius = defaultSearchRadius - (radiusDiff * searchHeaderTransition)
        
        let leadingOffset = -18 * searchHeaderTransition
        let trailingOffset = 16 * searchHeaderTransition
        
        searchBackgroundLeadingConstraint.constant = leadingOffset + (defaultSearchBackgroundMargin * (1 - searchHeaderTransition))
        searchBackgroundTrailingConstraint.constant = trailingOffset + (defaultSearchBackgroundMargin * (1 - searchHeaderTransition))
        
        let searchLoupeDiff: CGFloat = -6
        searchLoupeLeadingConstraint.constant = defaultSearchLoupeOffset + (searchLoupeDiff * searchHeaderTransition)
    }
    
}

extension CenteredSearchHomeCell: Themable {
    func decorate(with theme: Theme) {
        print("***", #function, frame.width)
        updateForTransition()
        
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
}
