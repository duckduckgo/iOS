//
//  PrivacyInfoContainerView.swift
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

import UIKit
import Lottie

class PrivacyInfoContainerView: UIView {
    
    var currentlyLoadedStyle: ThemeManager.ImageSet!
    
    @IBOutlet var privacyIcon: PrivacyIconView!
    @IBOutlet var maskingView: UIView!
    
    let shieldAnimation = AnimationView()
    let shieldDotAnimation = AnimationView()
    
    let trackers1Animation = AnimationView()
    let trackers2Animation = AnimationView()
    var trackers3Animation = AnimationView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        
        maskingView.round(corners: .allCorners, radius: 75)
        maskingView.backgroundColor = ThemeManager.shared.currentTheme.searchBarBackgroundColor
        
        addAndOrderSubviews()
        configureAnimationView()
        loadAnimations(for: ThemeManager.shared.currentTheme)
    }
    
    private func addAndOrderSubviews() {
        addSubview(trackers1Animation)
        addSubview(trackers2Animation)
        addSubview(trackers3Animation)
        addSubview(shieldAnimation)
        addSubview(shieldDotAnimation)
        
        bringSubviewToFront(maskingView)
        bringSubviewToFront(privacyIcon)
        bringSubviewToFront(shieldAnimation)
        bringSubviewToFront(shieldDotAnimation)
    }
        
    private func configureAnimationView() {
        // Trackers
        [trackers1Animation, trackers2Animation, trackers3Animation].forEach { trackersAnimation in
            trackersAnimation.contentMode = .scaleAspectFill
            
            trackersAnimation.frame = CGRect(x: 0, y: 0, width: 158, height: 40)
            trackersAnimation.center = CGPoint(x: bounds.midX - 4, y: bounds.midY)
        }
        
        
        // Shield animations
        [shieldAnimation, shieldDotAnimation].forEach { animationView in
            animationView.frame = trackers3Animation.frame
            animationView.center = CGPoint(x: bounds.midX - 9, y: bounds.midY)
            animationView.isHidden = true
        }
    }
    
    private func loadAnimations(for theme: Theme) {
        let style = theme.currentImageSet
        let cache = LRUAnimationCache.sharedCache
        
        shieldAnimation.animation = Animation.named(style == .light ? "shield" : "dark-shield", animationCache: cache)
        shieldDotAnimation.animation = Animation.named(style == .light ? "shield-dot" : "dark-shield-dot", animationCache: cache)
        
        trackers1Animation.animation = Animation.named(style == .light ? "trackers-1" : "dark-trackers-1", animationCache: cache)
        trackers2Animation.animation = Animation.named(style == .light ? "trackers-2" : "dark-trackers-2", animationCache: cache)
        trackers3Animation.animation = Animation.named(style == .light ? "trackers-3" : "dark-trackers-3", animationCache: cache)
        
        currentlyLoadedStyle = style
    }
}

extension UIView {
    
    public func setHiddenWithAnimation(_ hidden: Bool, duration: TimeInterval = 0.25) {
        self.isHidden = false
        self.alpha = hidden ? 1.0 : 0.0
        
        UIView.animate(withDuration: duration) {
            self.alpha = hidden ? 0.0 : 1.0
        } completion: { _ in
            self.isHidden = hidden
            self.alpha = 1.0
        }

    }
}

extension PrivacyInfoContainerView: Themable {
    
    func decorate(with theme: Theme) {
        
        if theme.currentImageSet != currentlyLoadedStyle {
            loadAnimations(for: theme)
        }
    }
}
