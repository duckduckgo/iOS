//
//  HomeMessageCell.swift
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

protocol HomeMessageCellDelegate: class {
    func homeMessageCellDismissButtonWasPressed(_ controller: HomeMessageCell)
}

class HomeMessageCell: UICollectionViewCell {
    
    static let reuseIdentifier = "homeMessageCell"
    
    weak var delegate: HomeMessageCellDelegate?
    //TODO card shadow
    //TODO check x touchable area
    //todo home row integration stuff
    //todo when to show this/keeping track of if it's been dismissed/interacted with
    //todo tracking pixels
    
    //how are we going to generalise keeping track of dismissing stuff?
    //Do we want to tightly couple it to this view controller?
    //okay, so this should be a header on the collection view, and then nothing is in storyboard, which probably makes this easier to generalise
    
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var subheaderLabel: UILabel!
    private var buttonPressedHandler: (() -> ())? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4.0
        layer.shadowOpacity = 0.12
        layer.masksToBounds = false
        setShadowPath()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setShadowPath()
    }
    
    func configure(withModel model: HomeMessageModel) {
        headerLabel.text = model.header
        subheaderLabel.text = model.subheader
        topLabel.text = model.topText
        mainButton.setTitle(model.buttonText, for: .normal)
        buttonPressedHandler = model.buttonPressedAction
    }
    
    @IBAction func dismissButtonPressed(_ sender: Any) {
        delegate?.homeMessageCellDismissButtonWasPressed(self)
    }
    
    @IBAction func mainButtonPressed(_ sender: Any) {
        buttonPressedHandler?()
    }
    
    private func setShadowPath() {
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
    }
}

//TODO test this
extension HomeMessageCell: Themable {

    func decorate(with theme: Theme) {
        //TODO dark mode/themeing
        //todo close button colour (also colours in general)
    }
}
