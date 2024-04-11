//
//  GestureToolbarButton.swift
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
import Core

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
    
    // UIToolBarButton size would be 29X44 and its imageview size would be 24X24
    struct ToolbarButtonConstants {
        static let width = 29.0
        static let height = 44.0
        static let imageWidth = 24.0
        static let imageHeight = 24.0
        
        static let pointerViewWidth = 48.0
        static let pointerViewHeight = 36.0
    }
    
    weak var delegate: GestureToolbarButtonDelegate?

    let iconImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: ToolbarButtonConstants.imageWidth, height: ToolbarButtonConstants.imageHeight))
    
    var image: UIImage? {
        didSet {
            iconImageView.image = image
        }
    }
    
    let pointerView: UIView = UIView(frame: CGRect(x: 0,
                                                   y: 0,
                                                   width: ToolbarButtonConstants.pointerViewWidth,
                                                   height: ToolbarButtonConstants.pointerViewHeight))
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(pointerView)
        addSubview(iconImageView)
                
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressHandler(_:)))
        longPressRecognizer.minimumPressDuration = Constants.minLongPressDuration
        longPressRecognizer.allowableMovement = CGFloat(Constants.maxTouchDeviationPoints)
        addGestureRecognizer(longPressRecognizer)
        addInteraction(UIPointerInteraction(delegate: self))

        decorate()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        iconImageView.center = center
        pointerView.center = center
    }

    @objc func longPressHandler(_ sender: UIGestureRecognizer) {
        
        if sender.state == .began {
            delegate?.longPressDetected(in: self)
        }
    }
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: ToolbarButtonConstants.width, height: ToolbarButtonConstants.height))
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
        imposeReleaseAnimation()
        delegate?.singleTapDetected(in: self)
        imposeReleaseAnimation()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        imposeReleaseAnimation()
    }
    
}

extension GestureToolbarButton {
    
    private func decorate() {
        let theme = ThemeManager.shared.currentTheme
        tintColor = theme.barTintColor
    }
}

extension GestureToolbarButton: UIPointerInteractionDelegate {
    
    func pointerInteraction(_ interaction: UIPointerInteraction, styleFor region: UIPointerRegion) -> UIPointerStyle? {
        return .init(effect: .highlight(.init(view: pointerView)))
    }
    
}
