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
    
    func showTabSwitcher(_ button: TabSwitcherButton)
    func launchNewTab(_ button: TabSwitcherButton)
    
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

    var workItem: DispatchWorkItem?

    let anim = LOTAnimationView(name: "new_tab")
    let tint = UIView(frame: .zero)
    let label = UILabel()
    
    var tabCount: Int = 0 {
        didSet {
            refresh()
        }
    }
    
    private func refresh() {
        if tabCount == 0 {
            label.text = nil
            return
        }
        
        let text = tabCount >= Constants.maxTextTabs ? "~" : "\(tabCount)"
        label.attributedText = NSAttributedString(string: text, attributes: attributes())
    }
    
    var hasUnread: Bool = false {
        didSet {
            anim.animationProgress = hasUnread ? 1.0 : 0.0
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        tint.frame = frame
        label.frame = frame
        
        tint.alpha = 0.0
        tint.isUserInteractionEnabled = false
        
        label.isUserInteractionEnabled = false
        
        addSubview(anim)
        addSubview(label)
        addSubview(tint)
        
        configureAnimationView()
    }
    
    private func configureAnimationView() {
        anim.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        anim.layer.masksToBounds = false
        anim.isUserInteractionEnabled = false
        
        anim.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    override var backgroundColor: UIColor? {
        didSet {
            tint.backgroundColor = backgroundColor
            refresh()
        }
    }
    
    override var tintColor: UIColor! {
        didSet {
            refresh()
        }
    }
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: 29, height: 44))
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        tint(alpha: Constants.tintAlpha)
        workItem?.cancel()
        let workItem = DispatchWorkItem {
            self.delegate?.launchNewTab(self)
            self.workItem = nil
        }
        let longPressDelay = GestureToolbarButton.Constants.minLongPressDuration
        DispatchQueue.main.asyncAfter(deadline: .now() + longPressDelay, execute: workItem)
        self.workItem = workItem
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        tint(alpha: 0)

        workItem?.cancel()
        guard workItem != nil else { return }

        guard let touch = touches.first else { return }
        guard point(inside: touch.location(in: self), with: event) else { return }
        delegate?.showTabSwitcher(self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let inside = point(inside: touch.location(in: self), with: event)
        tint(alpha: inside ? Constants.tintAlpha : 0)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        tint.alpha = 0
    }
    
    func incrementAnimated() {
        anim.play()
        UIView.animate(withDuration: Constants.labelFadeDuration, animations: {
            self.label.alpha = 0.0
        }, completion: { _ in
            self.tabCount += 1
            UIView.animate(withDuration: Constants.labelFadeDuration, animations: {
                self.label.alpha = 1.0
            })
        })
    }
    
    private func attributes() -> [NSAttributedString.Key: Any] {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        
        let font = UIFont.systemFont(ofSize: Constants.fontSize, weight: UIFont.Weight(Constants.fontWeight))
        return [ NSAttributedString.Key.font: font,
                 NSAttributedString.Key.foregroundColor: tintColor as Any,
                 NSAttributedString.Key.paragraphStyle: paragraphStyle ]
    }
    
    private func tint(alpha: CGFloat) {
        UIView.animate(withDuration: Constants.buttonTouchDuration) {
            self.tint.alpha = alpha
        }
    }
}

extension TabSwitcherButton: Themable {
    
    func decorate(with theme: Theme) {
        backgroundColor = theme.barBackgroundColor
        tintColor = theme.barTintColor

        switch theme.currentImageSet {
        case .light:
            anim.setAnimation(named: "new_tab_dark")
        case .dark:
            anim.setAnimation(named: "new_tab")
        }

        addSubview(anim)
        configureAnimationView()
    }
}
