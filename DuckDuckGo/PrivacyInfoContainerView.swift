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
    
    private var currentlyLoadedStyle: ThemeManager.ImageSet!
    
    @IBOutlet var privacyIcon: PrivacyIconView!
    @IBOutlet var maskingView: UIView!
    
    @IBOutlet var trackers1Animation: AnimationView!
    @IBOutlet var trackers2Animation: AnimationView!
    @IBOutlet var trackers3Animation: AnimationView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        
        maskingView.round(corners: .allCorners, radius: 75)
        
        trackers1Animation.contentMode = .scaleAspectFill
        trackers2Animation.contentMode = .scaleAspectFill
        trackers3Animation.contentMode = .scaleAspectFill
        
        loadAnimations(for: ThemeManager.shared.currentTheme)
    }
    
    private func loadAnimations(for theme: Theme, animationCache cache: AnimationCacheProvider = LRUAnimationCache.sharedCache) {
        let useLightStyle = theme.currentImageSet == .light

        trackers1Animation.animation = Animation.named(useLightStyle ? "trackers-1" : "dark-trackers-1", animationCache: cache)
        trackers2Animation.animation = Animation.named(useLightStyle ? "trackers-2" : "dark-trackers-2", animationCache: cache)
        trackers3Animation.animation = Animation.named(useLightStyle ? "trackers-3" : "dark-trackers-3", animationCache: cache)
        
        privacyIcon.loadAnimations(for: theme, animationCache: cache)
        
        currentlyLoadedStyle = theme.currentImageSet
    }
    
    func trackerAnimationView(for trackerCount: Int) -> AnimationView? {
        switch trackerCount {
        case 0: return nil
        case 1: return trackers1Animation
        case 2: return trackers2Animation
        default: return trackers3Animation
        }
    }
    
    var isAnimationPlaying: Bool {
        privacyIcon.isAnimationPlaying ||
        trackers1Animation.isAnimationPlaying ||
        trackers2Animation.isAnimationPlaying ||
        trackers3Animation.isAnimationPlaying
    }
}

extension PrivacyInfoContainerView: Themable {
    
    func decorate(with theme: Theme) {
        
        maskingView.backgroundColor = theme.searchBarBackgroundColor
        
        if theme.currentImageSet != currentlyLoadedStyle {
            loadAnimations(for: theme)
        }
    }
}
