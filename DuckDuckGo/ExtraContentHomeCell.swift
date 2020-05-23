//
//  ExtraContentHomeCell.swift
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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

class ExtraContentHomeCell: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var roundedBackground: UIView!
    @IBOutlet weak var highlightMask: UIView!
    @IBOutlet weak var dismissButton: UIButton!
    
    var onDismiss: ((ExtraContentHomeCell) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        ExtraContentHomeCell.applyDropshadow(to: roundedBackground!)
    }
    
    override var isHighlighted: Bool {
        didSet {
            highlightMask.isHidden = !isHighlighted
        }
    }
    
    class func applyDropshadow(to view: UIView) {
        view.layer.shadowRadius = 1
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.12
        view.layer.masksToBounds = false
    }

    @IBAction func onDismiss(_ sender: UIButton) {
        onDismiss?(self)
    }
}

extension ExtraContentHomeCell: Themable {
    
    func decorate(with theme: Theme) {
        label.textColor = theme.barTintColor
        dismissButton.tintColor = theme.barTintColor
        roundedBackground.backgroundColor = theme.faviconBackgroundColor
    }

}
