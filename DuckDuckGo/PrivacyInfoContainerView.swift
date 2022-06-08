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
    
    @IBOutlet var shieldButton: UIImageView!
    @IBOutlet var maskingView: UIView!
    
    let shieldAnimation = AnimationView(name: "shield")
    let shieldDotAnimation = AnimationView(name: "shield-dot")
    
    let trackersAnimation = AnimationView(name: "trackers-3")
    
    var trackerimage = UIImage(named: "amazon")?.cgImage
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        
        maskingView.round(corners: .allCorners, radius: 75)
        maskingView.backgroundColor = ThemeManager.shared.currentTheme.searchBarBackgroundColor
        
        addAndOrderSubviews()
        configureAnimationView()
    }
    
    private func addAndOrderSubviews() {
        addSubview(trackersAnimation)
        addSubview(shieldAnimation)
        addSubview(shieldDotAnimation)
        
        
        bringSubviewToFront(maskingView)
        bringSubviewToFront(shieldButton)
        bringSubviewToFront(shieldAnimation)
        bringSubviewToFront(shieldDotAnimation)
    }
        
    private func configureAnimationView() {
        // Trackers
        trackersAnimation.imageProvider = self
        trackersAnimation.contentMode = .scaleAspectFill
        
        trackersAnimation.frame = CGRect(x: 0, y: 0, width: 158, height: 40)
        trackersAnimation.center = CGPoint(x: bounds.midX - 4, y: bounds.midY)
        
        // Shield animations
        [shieldAnimation, shieldDotAnimation].forEach { animationView in
            animationView.frame = trackersAnimation.frame
            animationView.center = CGPoint(x: bounds.midX - 9, y: bounds.midY)
            animationView.isHidden = true
        }
    }
    
    public func startTrackerAnimation() {
        let showDot = false
        
        shieldAnimation.isHidden = showDot
        shieldDotAnimation.isHidden = !showDot
//        shieldButton.isHidden = true
        shieldButton.setHiddenWithAnimation(true)
        
        shieldButton.image = UIImage(named: "Shield")
        
        let currentShieldAnimation = (showDot ? shieldDotAnimation : shieldAnimation)
        
        trackersAnimation.play()
        currentShieldAnimation.play { [weak self] _ in
            self?.shieldButton.image = showDot ? UIImage(named: "ShieldDot") : UIImage(named: "Shield")
            self?.shieldButton.isHidden = false
//            self?.shieldButton.setHiddenWithAnimation(false)
//            currentShieldAnimation.isHidden = true
            currentShieldAnimation.setHiddenWithAnimation(true)
        }
        
        
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

extension PrivacyInfoContainerView: AnimationImageProvider {
    
    func imageForAsset(asset: ImageAsset) -> CGImage? {
        if asset.name == "img_3.png" {
            return nil
        }
        
        return trackerimage
    }
}
