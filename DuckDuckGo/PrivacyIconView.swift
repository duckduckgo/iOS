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
    
    private lazy var daxLogoIcon = UIImage(named: "LogoIcon")
    private lazy var shieldIcon = UIImage(named: "Shield")
    private lazy var shieldWithDotIcon = UIImage(named: "ShieldDot")
    
    
    @IBOutlet var shieldImageView: UIImageView!
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
    }
    
    func loadAnimations(for theme: Theme, animationCache cache: AnimationCacheProvider = LRUAnimationCache.sharedCache) {
        let useLightStyle = theme.currentImageSet == .light
        
        shieldAnimationView.animation = Animation.named(useLightStyle ? "shield" : "dark-shield", animationCache: cache)
        shieldDotAnimationView.animation = Animation.named(useLightStyle ? "shield-dot" : "dark-shield-dot", animationCache: cache)
    }
    
    var icon: PrivacyIcon {
        willSet {
            if newValue != icon {
                UIView.transition(with: shieldImageView,
                                  duration: 0.2,
                                  options: .transitionCrossDissolve,
                                  animations: { self.updateShieldImageView(for: newValue) },
                                  completion: nil)
            }
        }
    }
    
    private func updateShieldImageView(for icon: PrivacyIcon) {
        switch icon {
        case .daxLogo:
            shieldImageView.image = daxLogoIcon
            shieldImageView.contentMode = .center
        case .shield:
            shieldImageView.image = shieldIcon
            shieldImageView.contentMode = .scaleAspectFill
        case .shieldWithDot:
            shieldImageView.image = shieldWithDotIcon
            shieldImageView.contentMode = .scaleAspectFill
        }
    }
    
    var isAnimationPlaying: Bool {
        shieldAnimationView.isAnimationPlaying || shieldDotAnimationView.isAnimationPlaying
    }
}

@available(iOS 13.4, *)
extension PrivacyIconView: UIPointerInteractionDelegate {
    
    public func pointerInteraction(_ interaction: UIPointerInteraction, styleFor region: UIPointerRegion) -> UIPointerStyle? {
        return .init(effect: .lift(.init(view: self)))
    }
    
}
