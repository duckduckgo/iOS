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
import Core
import BrowserServicesKit

struct PrivacyIconAndTrackersAnimationModel {
    let privacyIcon: PrivacyIcon
    let willAnimateTrackers: Bool
    // tracker images
    let pauseForOnboarding: Bool
    
    init(rating: SiteRating, pauseForOnboarding: Bool = false) {
//        let urlScheme = selectedTabViewModel.tab.content.url?.scheme
//        let isHypertextUrl = urlScheme == "http" || urlScheme == "https"
//        let isDuckDuckGoUrl = selectedTabViewModel.tab.content.url?.isDuckDuckGoSearch ?? false
//        let isEditingMode = controllerMode?.isEditing ?? false
//        let isTextFieldValueText = textFieldValue?.isText ?? false
        
        if AppUrls().isDuckDuckGoSearch(url: rating.url) {
            privacyIcon = .daxLogo
        } else {
            let config = ContentBlocking.privacyConfigurationManager.privacyConfig
            let isUnprotected = config.isUserUnprotected(domain: rating.url.host)

            let notFullyProtected = !rating.https || rating.isMajorTrackerNetwork || isUnprotected
            
            privacyIcon = notFullyProtected ? .shieldWithDot : .shield
        }

        willAnimateTrackers = !rating.trackersBlocked.isEmpty
        
        self.pauseForOnboarding = pauseForOnboarding
    }
}

final class PrivacyIconAndTrackersAnimator {
    
    var trackerimage = UIImage(named: "amazon")?.cgImage
    
    func startLoadingAnimation(in container: PrivacyInfoContainerView, for url: URL?) {
        guard let url = url, !AppUrls().isDuckDuckGoSearch(url: url) else {
            container.privacyIcon.icon = .daxLogo
            return
        }
        
        container.privacyIcon.icon = .shield
    }
    
    func configure(_ container: PrivacyInfoContainerView, with model: PrivacyIconAndTrackersAnimationModel) {
        if model.willAnimateTrackers {
            container.trackersAnimation.imageProvider = self
            container.trackersAnimation.reloadImages()
        } else {
            // No animation directly set icon
            container.privacyIcon.icon = model.privacyIcon
        }
    }
    
//    func configure(_ container: PrivacyInfoContainerView, toDisplay trackers: [DetectedTracker], shouldCollapse: Bool) -> Bool {
//        // Check if there are ANY trackers (decide to do animation)
//        guard !trackers.isEmpty else { return false }
//
//        // Load tracker logos
//        contzainer.trackersAnimation.imageProvider = self
//        container.trackersAnimation.reloadImages()
//
//        // Calculate privacy icon
//        container.privacyIcon.icon = .shieldWithDot
//
//        return true
//    }
    
//    func startAnimating(in container: PrivacyInfoContainerView) {
    func startAnimating(in omniBar: OmniBar, with model: PrivacyIconAndTrackersAnimationModel) {
        guard let container = omniBar.privacyInfoContainer else { return }
        
        let showDot = model.privacyIcon == .shieldWithDot
        
        // No matter that dot or no dot this is the starte for the animation
//        container.privacyIcon.icon = .shield
        
        container.shieldAnimation.isHidden = showDot
        container.shieldDotAnimation.isHidden = !showDot
//        shieldButton.isHidden = true
        container.privacyIcon.setHiddenWithAnimation(true)
        
        container.privacyIcon.image = UIImage(named: "Shield")
        
        let currentShieldAnimation = (showDot ? container.shieldDotAnimation : container.shieldAnimation)
        
        UIView.animate(withDuration: 0.2) {
            omniBar.textField.alpha = 0
        }
        
        container.trackersAnimation.play()
        currentShieldAnimation.play { [weak container] _ in
            container?.privacyIcon.icon = showDot ? .shieldWithDot : .shield
            container?.privacyIcon.isHidden = false
//            self?.shieldButton.setHiddenWithAnimation(false)
//            currentShieldAnimation.isHidden = true
            currentShieldAnimation.setHiddenWithAnimation(true)
        }
        
        
        let animationDuration = container.trackersAnimation.animation?.duration ?? 0

        UIView.animate(withDuration: 0.2, delay: animationDuration) {
            omniBar.textField.alpha = 1
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
