//
//  PrivacyIconView.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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

enum PrivacyIcon {
    case daxLogo, shield, shieldWithDot
}

class PrivacyIconView: UIView {

    @IBOutlet var daxLogoImageView: UIImageView!
    @IBOutlet var staticShieldAnimationView: AnimationView!
    @IBOutlet var staticShieldDotAnimationView: AnimationView!
    
    @IBOutlet var shieldAnimationView: AnimationView!
    @IBOutlet var shieldDotAnimationView: AnimationView!
    
    public required init?(coder aDecoder: NSCoder) {
        icon = .shield
        
        super.init(coder: aDecoder)
        
        
        if #available(iOS 13.4, *) {
            addInteraction(UIPointerInteraction(delegate: self))
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
  
        loadAnimations(for: ThemeManager.shared.currentTheme)
        
        updateShieldImageView(for: icon)
        updateAccessibilityLabels(for: icon)
    }
    
    func loadAnimations(for theme: Theme, animationCache cache: AnimationCacheProvider = LRUAnimationCache.sharedCache) {
        let useLightStyle = theme.currentImageSet == .light
        
        let shieldAnimation = Animation.named(useLightStyle ? "shield" : "dark-shield", animationCache: cache)
        shieldAnimationView.animation = shieldAnimation
        staticShieldAnimationView.animation = shieldAnimation
        staticShieldAnimationView.currentProgress = 0.0
        
        let shieldWithDotAnimation = Animation.named(useLightStyle ? "shield-dot" : "dark-shield-dot", animationCache: cache)
        shieldDotAnimationView.animation = shieldWithDotAnimation
        staticShieldDotAnimationView.animation = shieldWithDotAnimation
        staticShieldDotAnimationView.currentProgress = 1.0
    }
    
    func updateIcon(_ newIcon: PrivacyIcon) {
        icon = newIcon
    }
    
    private(set) var icon: PrivacyIcon {
        willSet {
            guard newValue != icon else { return }
            updateShieldImageView(for: newValue)
            updateAccessibilityLabels(for: newValue)
        }
    }
    
    private func updateShieldImageView(for icon: PrivacyIcon) {
        switch icon {
        case .daxLogo:
            daxLogoImageView.isHidden = false
            staticShieldAnimationView.isHidden = true
            staticShieldDotAnimationView.isHidden = true
        case .shield:
            daxLogoImageView.isHidden = true
            staticShieldAnimationView.isHidden = false
            staticShieldDotAnimationView.isHidden = true
        case .shieldWithDot:
            daxLogoImageView.isHidden = true
            staticShieldAnimationView.isHidden = true
            staticShieldDotAnimationView.isHidden = false
        }
    }
    
    private func updateAccessibilityLabels(for icon: PrivacyIcon) {
        switch icon {
        case .daxLogo:
            accessibilityLabel = UserText.privacyIconDax
            accessibilityHint = nil
            accessibilityTraits = .image
        case .shield, .shieldWithDot:
            accessibilityLabel = UserText.privacyIconShield
            accessibilityHint = UserText.privacyIconOpenDashboardHint
            accessibilityTraits = .button
        }
    }
    
    func refresh() {
        updateShieldImageView(for: icon)
        updateAccessibilityLabels(for: icon)
        shieldAnimationView.isHidden = true
        shieldDotAnimationView.isHidden = true
    }
    
    func prepareForAnimation(for icon: PrivacyIcon) {
        let showDot = (icon == .shieldWithDot)
        
        shieldAnimationView.isHidden = showDot
        shieldDotAnimationView.isHidden = !showDot

        staticShieldAnimationView.isHidden = true
        staticShieldDotAnimationView.isHidden = true
        daxLogoImageView.isHidden = true
    }
    
    func shieldAnimationView(for icon: PrivacyIcon) -> AnimationView? {
        switch icon {
        case .shield:
            return shieldAnimationView
        case .shieldWithDot:
            return shieldDotAnimationView
        default:
            return nil
        }
    }
    
    var isAnimationPlaying: Bool {
        shieldAnimationView.isAnimationPlaying || shieldDotAnimationView.isAnimationPlaying
    }
    
}

extension PrivacyIconView: UIPointerInteractionDelegate {
    
    public func pointerInteraction(_ interaction: UIPointerInteraction, styleFor region: UIPointerRegion) -> UIPointerStyle? {
        return .init(effect: .lift(.init(view: self)))
    }
    
}
