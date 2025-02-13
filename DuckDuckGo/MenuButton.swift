//
//  MenuButton.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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

import Foundation

import UIKit
import Lottie
import Core

protocol MenuButtonDelegate: NSObjectProtocol {
    
    func showMenu(_ button: MenuButton)
    func showBookmarks(_ button: MenuButton)
    
}

class MenuButton: UIView {
    
    enum State {
        case menuImage
        case closeImage
    }
    
    struct Constants {
        
        static let labelFadeDuration = 0.3
        static let buttonTouchDuration = 0.2
        static let tintAlpha: CGFloat = 0.5

        static let pointerViewWidth: CGFloat = 48
        static let pointerViewHeight: CGFloat = 36

    }
    
    weak var delegate: MenuButtonDelegate?
    private var currentState: State = .menuImage
    
    private let bookmarksIconView = UIImageView()

    let anim = LottieAnimationView(name: "menu_light")
    let pointerView: UIView = UIView(frame: CGRect(x: 0,
                                                   y: 0,
                                                   width: Constants.pointerViewWidth,
                                                   height: Constants.pointerViewHeight))
    
    var hasUnread: Bool = false {
        didSet {
            anim.currentProgress = hasUnread ? 1.0 : 0.0
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(pointerView)
        addSubview(anim)
        addSubview(bookmarksIconView)

        configureAnimationView()

        addInteraction(UIPointerInteraction(delegate: self))

        decorate()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        anim.center = center
        pointerView.center = center
        bookmarksIconView.center = center
    }

    private func configureAnimationView() {
        anim.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        anim.layer.masksToBounds = false
        anim.isUserInteractionEnabled = false
        
        anim.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: 29, height: 44))
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        tint(alpha: Constants.tintAlpha)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        tint(alpha: 1)
        switch currentState {
        case .menuImage, .closeImage:
            delegate?.showMenu(self)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let inside = point(inside: touch.location(in: self), with: event)
        tint(alpha: inside ? Constants.tintAlpha : 1)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        tint(alpha: 1, animated: false)
    }
    
    func setState(_ state: State, animated: Bool) {
        guard state != currentState else { return }
        
        switch state {
        case .closeImage:
            bookmarksIconView.isHidden = true
            anim.isHidden = false
            if animated {
                anim.play()
            } else {
                anim.currentProgress = 1.0
            }
        case .menuImage:
            bookmarksIconView.isHidden = true
            anim.isHidden = false
            if animated {
                // Work around a bug that caused glitches when rapidly toggling button
                anim.stop()
                anim.currentProgress = 1.0
                anim.play(fromProgress: 1.0, toProgress: 0, loopMode: nil, completion: nil)
            } else {
                anim.currentProgress = 0.0
            }
        }
        
        currentState = state
    }
    
    private func tint(alpha: CGFloat, animated: Bool = true) {
    
        let setAlpha = {
            self.anim.alpha = alpha
            self.bookmarksIconView.alpha = alpha
        }
        
        if animated {
            UIView.animate(withDuration: Constants.buttonTouchDuration, animations: setAlpha)
        } else {
            setAlpha()
        }
    }
}

extension MenuButton {
    
    private func decorate() {
        let theme = ThemeManager.shared.currentTheme
        tintColor = theme.barTintColor

        updateAnimationForCurrentAppearance()
    }

    private func updateAnimationForCurrentAppearance() {
        switch traitCollection.userInterfaceStyle {
        case .dark:
            anim.animation = LottieAnimation.named("menu_dark")
        default:
            anim.animation = LottieAnimation.named("menu_light")
        }

        if currentState == State.closeImage {
            anim.currentProgress = 1.0
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateAnimationForCurrentAppearance()
        }
    }
}

extension MenuButton: UIPointerInteractionDelegate {
    
    func pointerInteraction(_ interaction: UIPointerInteraction, styleFor region: UIPointerRegion) -> UIPointerStyle? {
        return .init(effect: .highlight(.init(view: pointerView)))
    }
    
}
