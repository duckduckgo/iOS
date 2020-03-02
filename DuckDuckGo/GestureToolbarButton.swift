//
//  BookmarksButton.swift
//  DuckDuckGo
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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

protocol GestureToolbarButtonDelegate: NSObjectProtocol {
    
    func singleTapDetected(in sender: GestureToolbarButton)
    func longPressDetected(in sender: GestureToolbarButton)
    
}

class GestureToolbarButton: UIView {
    
    struct Constants {
        static let minLongPressDuration = 0.4
        static let maxTouchDeviationPoints = 20.0
        static let animationDuration = 0.3
    }
    
    // UIToolBarButton size would be 29X44 and it's imageview size would be 24X24
    struct ToolbarButton {
        static let Width = 29.0
        static let Height = 44.0
        static let ImageWidth = 24.0
        static let ImageHeight = 24.0
    }
    
    weak var delegate: GestureToolbarButtonDelegate?

    let iconImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: ToolbarButton.ImageWidth, height: ToolbarButton.ImageHeight))
    
    var image: UIImage? {
        didSet {
            iconImageView.image = image
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(iconImageView)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressHandler(_:)))
        longPressRecognizer.minimumPressDuration = Constants.minLongPressDuration
        longPressRecognizer.allowableMovement = CGFloat(Constants.maxTouchDeviationPoints)
        addGestureRecognizer(longPressRecognizer)

    }

    override func layoutSubviews() {
        super.layoutSubviews()
        iconImageView.center = center
    }

    @objc func longPressHandler(_ sender: UIGestureRecognizer) {
        
        if sender.state == .began {
            delegate?.longPressDetected(in: self)
        }
    }
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: ToolbarButton.Width, height: ToolbarButton.Height))
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    fileprivate func imposePressAnimation() {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.iconImageView.alpha = 0.2
        }
    }
    
    fileprivate func imposeReleaseAnimation() {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.iconImageView.alpha = 1.0
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        imposePressAnimation()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            imposeReleaseAnimation()
            return
        }
        guard point(inside: touch.location(in: self), with: event) else {
            imposeReleaseAnimation()
            return
        }
        delegate?.singleTapDetected(in: self)
        imposeReleaseAnimation()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        imposeReleaseAnimation()
    }
    
}

extension GestureToolbarButton: Themable {
    
    func decorate(with theme: Theme) {
        backgroundColor = theme.barBackgroundColor
        tintColor = theme.barTintColor
    }
}
