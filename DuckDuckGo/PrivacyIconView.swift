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
    case daxLogo, shield, shieldWithDot, alert

    fileprivate var staticImage: UIImage? {
        switch self {
        case .daxLogo: return UIImage(resource: .logoIcon)
        case .alert: return UIImage(resource: .alertColor24)
        default: return nil
        }
    }
}

class PrivacyIconView: UIView {

    @IBOutlet var staticImageView: UIImageView!
    @IBOutlet var staticShieldAnimationView: LottieAnimationView!
    @IBOutlet var staticShieldDotAnimationView: LottieAnimationView!

    @IBOutlet var shieldAnimationView: LottieAnimationView!
    @IBOutlet var shieldDotAnimationView: LottieAnimationView!

    public required init?(coder aDecoder: NSCoder) {
        icon = .shield
        
        super.init(coder: aDecoder)
        
        
        if #available(iOS 13.4, *) {
            addInteraction(UIPointerInteraction(delegate: self))
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
  
        loadAnimations()
        
        updateShieldImageView(for: icon)
        updateAccessibilityLabels(for: icon)

        // Animations are not rendering properly when going back from background, hence the change.
        [staticShieldAnimationView,
         staticShieldDotAnimationView,
         shieldAnimationView,
         shieldDotAnimationView].forEach { animationView in
            animationView?.configuration = LottieConfiguration(renderingEngine: .mainThread)
        }
    }
    
    func loadAnimations(animationCache cache: AnimationCacheProvider = DefaultAnimationCache.sharedCache) {
        let useDarkStyle = traitCollection.userInterfaceStyle == .dark

        let shieldAnimation = LottieAnimation.named(useDarkStyle ? "dark-shield" : "shield", animationCache: cache)

        shieldAnimationView.animation = shieldAnimation
        staticShieldAnimationView.animation = shieldAnimation
        staticShieldAnimationView.currentProgress = 0.0

        let shieldWithDotAnimation = LottieAnimation.named(useDarkStyle ? "dark-shield-dot" : "shield-dot", animationCache: cache)
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
        case .daxLogo, .alert:
            staticImageView.isHidden = false
            staticImageView.image = icon.staticImage
            staticShieldAnimationView.isHidden = true
            staticShieldDotAnimationView.isHidden = true
        case .shield:
            staticImageView.isHidden = true
            staticShieldAnimationView.isHidden = false
            staticShieldDotAnimationView.isHidden = true
        case .shieldWithDot:
            staticImageView.isHidden = true
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
            accessibilityIdentifier = "privacy-icon-shield.button"
            accessibilityLabel = UserText.privacyIconShield
            accessibilityHint = UserText.privacyIconOpenDashboardHint
            accessibilityTraits = .button
        case .alert:
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
        staticImageView.isHidden = true
    }
    
    func shieldAnimationView(for icon: PrivacyIcon) -> LottieAnimationView? {
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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            loadAnimations()
        }
    }
}

extension PrivacyIconView: UIPointerInteractionDelegate {
    
    public func pointerInteraction(_ interaction: UIPointerInteraction, styleFor region: UIPointerRegion) -> UIPointerStyle? {
        return .init(effect: .lift(.init(view: self)))
    }
    
}
