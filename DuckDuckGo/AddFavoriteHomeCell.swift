//
//  AddFavoriteHomeCell.swift
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
            plusBackground.backgroundColor = UIColor.reallyBlack
        }
    }
    
}

fileprivate extension UIColor {
    
    func applyAlpha(_ alpha: CGFloat) -> UIColor {
        return UIColor(red: redComponent, green: greenComponent, blue: blueComponent, alpha: alpha)
    }
    
}
