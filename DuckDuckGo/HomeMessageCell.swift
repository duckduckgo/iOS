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
    func homeMessageCellDismissButtonWasPressed(_ cell: HomeMessageCell)
    func homeMessageCellMainButtonWaspressed(_ cell: HomeMessageCell)
}

class HomeMessageCell: UICollectionViewCell {
    
    static let reuseIdentifier = "homeMessageCell"
    static let maximumWidth: CGFloat = 380
    static let maximumWidthIpad: CGFloat = 455
    
    weak var delegate: HomeMessageCellDelegate?
    var homeMessage: HomeMessage = .defaultBrowserPrompt
    
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var subheaderLabel: UILabel!
    @IBOutlet weak var sizingLabel: UILabel!
    private lazy var cellWidthConstraint = contentView.widthAnchor.constraint(equalToConstant: HomeMessageCell.maximumWidth)

    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellWidthConstraint.isActive = true
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        mainButton.titleLabel?.textAlignment = .center
        
        let image = dismissButton.image(for: .normal)?.withRenderingMode(.alwaysTemplate)
        dismissButton.setImage(image, for: .normal)
        
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
        homeMessage = model.homeMessage
        headerLabel.text = model.header
        subheaderLabel.text = model.subheader
        topLabel.text = model.topText
        sizingLabel.font = mainButton.titleLabel?.font
        sizingLabel.text = model.buttonText
        mainButton.setTitle(model.buttonText, for: .normal)
        layoutIfNeeded()
    }
    
    func setWidth(_ width: CGFloat) {
        cellWidthConstraint.constant = width
        layoutIfNeeded()
    }
    
    @IBAction func dismissButtonPressed(_ sender: Any) {
        delegate?.homeMessageCellDismissButtonWasPressed(self)
    }
    
    @IBAction func mainButtonPressed(_ sender: Any) {
        delegate?.homeMessageCellMainButtonWaspressed(self)
    }
    
    private func setShadowPath() {
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
    }
}

extension HomeMessageCell: Themable {

    func decorate(with theme: Theme) {
        contentView.backgroundColor = theme.homeMessageBackgroundColor
        headerLabel.textColor = theme.homeMessageHeaderTextColor
        subheaderLabel.textColor = theme.homeMessageSubheaderTextColor
        topLabel.textColor = theme.homeMessageTopTextColor
        mainButton.backgroundColor = theme.homeMessageButtonColor
        mainButton.setTitleColor(theme.homeMessageButtonTextColor, for: .normal)
        dismissButton.tintColor = theme.homeMessageDismissButtonColor
    }
}
