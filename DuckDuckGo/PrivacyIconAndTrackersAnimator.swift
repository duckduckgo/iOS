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

extension SiteRating {
    var privacyIcon: PrivacyIcon {
        let icon: PrivacyIcon
        
        if AppUrls().isDuckDuckGoSearch(url: url) {
            icon = .daxLogo
        } else {
            let config = ContentBlocking.privacyConfigurationManager.privacyConfig
            let isUserUnprotected = config.isUserUnprotected(domain: url.host)
 
            let notFullyProtected = !https || isMajorTrackerNetwork || isUserUnprotected
            
            icon = notFullyProtected ? .shieldWithDot : .shield
        }
        
        return icon
    }
    
    var willAnimateTrackers: Bool {
        !trackersBlocked.isEmpty
    }
}

final class PrivacyIconAndTrackersAnimator {
    
    let trackerAnimationImageProvider = TrackerAnimationImageProvider()
    
    func resetPrivacyIcon(in container: PrivacyInfoContainerView, for url: URL?) {
        guard let url = url, !AppUrls().isDuckDuckGoSearch(url: url) else {
            container.privacyIcon.icon = .daxLogo
            return
        }
        
        container.privacyIcon.icon = .shield
    }
    
    func updatePrivacyIcon(in container: PrivacyInfoContainerView, for siteRating: SiteRating) {
//        container.privacyIcon.icon = siteRating.privacyIcon
        container.privacyIcon.icon = siteRating.willAnimateTrackers ? .shield : siteRating.privacyIcon
    }
    
    func configure(_ container: PrivacyInfoContainerView, for siteRating: SiteRating) {
        container.trackers1Animation.currentFrame = 0
        container.trackers2Animation.currentFrame = 0
        container.trackers3Animation.currentFrame = 0
        container.privacyIcon.shieldAnimationView.currentFrame = 0
        container.privacyIcon.shieldDotAnimationView.currentFrame = 0
        
        if siteRating.willAnimateTrackers {
            trackerAnimationImageProvider.loadTrackerImages(from: siteRating)
      
            if let trackerAnimationView = currentTrackerAnimationView(in: container, for: trackerAnimationImageProvider.trackerImagesCount) {
                trackerAnimationView.imageProvider = trackerAnimationImageProvider
                trackerAnimationView.reloadImages()
            }
            
            container.privacyIcon.icon = .shield
        } else {
            // No animation directly set icon
            container.privacyIcon.icon = siteRating.privacyIcon
        }
    }
    
    private func currentTrackerAnimationView(in container: PrivacyInfoContainerView, for trackerCount: Int) -> AnimationView? {
        switch trackerCount {
        case 0: return nil
        case 1: return container.trackers1Animation
        case 2: return container.trackers2Animation
        default: return container.trackers3Animation
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
    func startAnimating(in omniBar: OmniBar, with siteRating: SiteRating) {
        guard let container = omniBar.privacyInfoContainer else { return }
        
        let privacyIcon = siteRating.privacyIcon
        
        let showDot = (privacyIcon == .shieldWithDot)
        
        container.privacyIcon.shieldAnimationView.isHidden = showDot
        container.privacyIcon.shieldDotAnimationView.isHidden = !showDot
        container.privacyIcon.shieldImageView.setHiddenWithAnimation(true)

        let currentShieldAnimation = (showDot ? container.privacyIcon.shieldDotAnimationView : container.privacyIcon.shieldAnimationView)
        
        UIView.animate(withDuration: 0.2) {
            omniBar.textField.alpha = 0
        }
        
        let currentTrackerAnimation = currentTrackerAnimationView(in: container, for: trackerAnimationImageProvider.trackerImagesCount)
            
//        container.trackersAnimation.play()
        currentTrackerAnimation?.play()
        
        currentShieldAnimation?.play { [weak container] _ in
            container?.privacyIcon.icon = privacyIcon
            container?.privacyIcon.shieldImageView.isHidden = false
            currentShieldAnimation?.setHiddenWithAnimation(true)
            
            UIView.animate(withDuration: 0.2) {
                omniBar.textField.alpha = 1
            }
        }
    }
    
    func startAnimationForDaxDialog(in omniBar: OmniBar, with siteRating: SiteRating) {
        guard let container = omniBar.privacyInfoContainer else { return }
        
        let privacyIcon = siteRating.privacyIcon
        
        let showDot = (privacyIcon == .shieldWithDot)
        
        container.privacyIcon.shieldAnimationView.isHidden = showDot
        container.privacyIcon.shieldDotAnimationView.isHidden = !showDot
        container.privacyIcon.setHiddenWithAnimation(true)
        
        container.privacyIcon.icon = privacyIcon
        
//        let currentShieldAnimation = (showDot ? container.shieldDotAnimation : container.shieldAnimation)
        
        UIView.animate(withDuration: 0.2) {
            omniBar.textField.alpha = 0
        }
        
        let currentTrackerAnimation = currentTrackerAnimationView(in: container, for: trackerAnimationImageProvider.trackerImagesCount)
            
        currentTrackerAnimation?.play(toFrame: 45)  // stop frame for all 3 tracker animations
//        currentShieldAnimation.play(toFrame: 63) // stop frame for forcefield animation
    }
    
    func completeAnimationForDaxDialog(in omniBar: OmniBar) {
        guard let container = omniBar.privacyInfoContainer else { return }
        
        let currentTrackerAnimation = currentTrackerAnimationView(in: container,
                                                                  for: trackerAnimationImageProvider.trackerImagesCount)
        let currentShieldAnimation = [container.privacyIcon.shieldAnimationView, container.privacyIcon.shieldDotAnimationView].first { !$0.isHidden }
        
        currentTrackerAnimation?.play()
        currentShieldAnimation?.play(completion: { [weak container] _ in
//            container?.privacyIcon.icon = privacyIcon
            container?.privacyIcon.isHidden = false
            currentShieldAnimation?.setHiddenWithAnimation(true)
        })
        
        let animationDelay: TimeInterval
        
        if let currentProgress = currentTrackerAnimation?.currentProgress, let duration = currentTrackerAnimation?.animation?.duration {
            animationDelay = duration * (1 - currentProgress)
        } else {
            animationDelay = 0
        }
        
        UIView.animate(withDuration: 0.2, delay: animationDelay) {
            omniBar.textField.alpha = 1
        }
        
    }
    
    func cancelAnimations(in omniBar: OmniBar) {
        guard let container = omniBar.privacyInfoContainer else { return }
        
        container.trackers1Animation.stop()
        container.trackers2Animation.stop()
        container.trackers3Animation.stop()
        container.privacyIcon.shieldAnimationView.stop()
        container.privacyIcon.shieldDotAnimationView.stop()
        
        container.privacyIcon.shieldAnimationView.isHidden = true
        container.privacyIcon.shieldDotAnimationView.isHidden = true
    }
    
    func resetImageProvider() {
        trackerAnimationImageProvider.reset()
    }
}
