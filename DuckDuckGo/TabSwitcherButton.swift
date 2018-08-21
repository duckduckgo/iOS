//
//  TabSwitcherButton.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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
import Lottie

protocol TabSwitcherButtonDelegate: NSObjectProtocol {
    
    func showTabSwitcher()
    
}

class TabSwitcherButton: UIView {
    
    struct Constants {
        
        static let fontSize: CGFloat = 10
        static let fontWeight: CGFloat = 5
        static let maxTextTabs = 100
        static let labelFadeDuration = 0.3
        static let buttonTouchDuration = 0.2
        static let tintAlpha: CGFloat = 0.5
        
    }
    
    weak var delegate: TabSwitcherButtonDelegate?
    
    let tint = UIView(frame: .zero)
    let anim = LOTAnimationView(name: "new_tab")
    let label = UILabel()
    
    var tabCount: Int = 0 {
        didSet {
            if tabCount == 0 {
                label.text = nil
                return
            }
            
            if tabCount >= Constants.maxTextTabs {
                label.text = "🦆"
                return
            }
            
            label.attributedText = NSAttributedString(string: "\(tabCount)", attributes: attributes())
        }
    }
    
    var hasUnread: Bool = false {
        didSet {
            anim.animationProgress = hasUnread ? 1.0 : 0.0
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        anim.frame = frame
        tint.frame = frame
        label.frame = frame
        
        tint.backgroundColor = UIColor.nearlyBlackLight
        tint.alpha = 0.0
        
        addSubview(anim)
        addSubview(label)
        addSubview(tint)
        
    }
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: Constants.buttonTouchDuration) {
            self.tint.alpha = Constants.tintAlpha
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: Constants.buttonTouchDuration) {
            self.tint.alpha = 0
        }
        
        guard let touch = touches.first else { return }
        guard point(inside: touch.location(in: self), with: event) else { return }
        delegate?.showTabSwitcher()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        tint.alpha = 0
    }
    
    func incrementAnimated() {
        UIView.animate(withDuration: Constants.labelFadeDuration, animations: {
            self.label.alpha = 0.0
        }, completion: { _ in
            self.tabCount += 1
            UIView.animate(withDuration: Constants.labelFadeDuration, animations: {
                self.label.alpha = 1.0
            })
        })
    }
    
    private func attributes() -> [NSAttributedStringKey: Any] {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        
        let font = UIFont.systemFont(ofSize: Constants.fontSize, weight: UIFont.Weight(Constants.fontWeight))
        return [ NSAttributedStringKey.font: font,
                 NSAttributedStringKey.foregroundColor: UIColor.nearlyBlackLight,
                 NSAttributedStringKey.paragraphStyle: paragraphStyle ]
    }
    
}
