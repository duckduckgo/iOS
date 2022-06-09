//
//  PrivacyIconAndTrackersAnimator.swift
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
import BrowserServicesKit

final class PrivacyIconAndTrackersAnimator {
    
    var trackerimage = UIImage(named: "amazon")?.cgImage
    
    func startLoadingAnimation(in privacyContainerView: PrivacyInfoContainerView, for url: URL?) {
        
    }
    
    func configure(_ privacyContainerView: PrivacyInfoContainerView, toDisplay trackers: [DetectedTracker], shouldCollapse: Bool) -> Bool {
        
        privacyContainerView.trackersAnimation.imageProvider = self
        privacyContainerView.trackersAnimation.reloadImages()
        
        return true
    }
    
    func startAnimating(in container: PrivacyInfoContainerView) {
        let showDot = false
        
        container.shieldAnimation.isHidden = showDot
        container.shieldDotAnimation.isHidden = !showDot
//        shieldButton.isHidden = true
        container.shieldButton.setHiddenWithAnimation(true)
        
        container.shieldButton.image = UIImage(named: "Shield")
        
        let currentShieldAnimation = (showDot ? container.shieldDotAnimation : container.shieldAnimation)
        
        container.trackersAnimation.play()
        currentShieldAnimation.play { [weak container] _ in
            container?.shieldButton.image = showDot ? UIImage(named: "ShieldDot") : UIImage(named: "Shield")
            container?.shieldButton.isHidden = false
//            self?.shieldButton.setHiddenWithAnimation(false)
//            currentShieldAnimation.isHidden = true
            currentShieldAnimation.setHiddenWithAnimation(true)
        }
    }
    
    func cancelAnimations(in container: PrivacyInfoContainerView) {
        container.trackersAnimation.stop()
        container.shieldAnimation.stop()
        container.shieldDotAnimation.stop()
        
        container.shieldAnimation.isHidden = true
        container.shieldDotAnimation.isHidden = true
    }
    
    func completeAnimations(in privacyContainerView: PrivacyInfoContainerView) {
 
    }

}


extension PrivacyIconAndTrackersAnimator: AnimationImageProvider {
    
    func imageForAsset(asset: ImageAsset) -> CGImage? {
        if asset.name == "img_3.png" {
            return nil
        }
        
        return trackerimage
    }
}
