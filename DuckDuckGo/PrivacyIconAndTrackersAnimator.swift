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

enum TrackersAnimationState {
    case noAnimations, beforeAnimations, afterAnimations, animatingForDaxDialog
}

final class PrivacyIconAndTrackersAnimator {

    private let trackerAnimationImageProvider = TrackerAnimationImageProvider()
    private(set) var animationState: TrackersAnimationState = .noAnimations
    
    
    func updateAnimationState(for siteRating: SiteRating) {
        guard animationState != .animatingForDaxDialog else { return }
        
        if animationState == .noAnimations && TrackerAnimationLogic.shouldAnimateTrackers(for: siteRating) {
            animationState = .beforeAnimations
        }
    }
    
    func configure(_ container: PrivacyInfoContainerView, for siteRating: SiteRating) {
        container.trackers1Animation.currentFrame = 0
        container.trackers2Animation.currentFrame = 0
        container.trackers3Animation.currentFrame = 0
        container.privacyIcon.shieldAnimationView.currentFrame = 0
        container.privacyIcon.shieldDotAnimationView.currentFrame = 0
        
        if TrackerAnimationLogic.shouldAnimateTrackers(for: siteRating) {
            trackerAnimationImageProvider.loadTrackerImages(from: siteRating)
      
            if let trackerAnimationView = currentTrackerAnimationView(in: container, for: trackerAnimationImageProvider.trackerImagesCount) {
                trackerAnimationView.imageProvider = trackerAnimationImageProvider
                trackerAnimationView.reloadImages()
            }
            
            container.privacyIcon.updateIcon(.shield)
        } else {
            // No animation directly set icon
            let icon = PrivacyIconLogic.privacyIcon(for: siteRating)
            container.privacyIcon.updateIcon(icon)
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
    
    func startAnimating(in omniBar: OmniBar, with siteRating: SiteRating) {
        guard let container = omniBar.privacyInfoContainer else { return }
        
        let privacyIcon = PrivacyIconLogic.privacyIcon(for: siteRating)
        let showDot = (privacyIcon == .shieldWithDot)
        
        container.privacyIcon.shieldAnimationView.isHidden = showDot
        container.privacyIcon.shieldDotAnimationView.isHidden = !showDot
        container.privacyIcon.daxLogoImageView.isHidden = true
                
        UIView.animate(withDuration: 0.2) {
            omniBar.textField.alpha = 0
        }

        let currentTrackerAnimation = currentTrackerAnimationView(in: container, for: trackerAnimationImageProvider.trackerImagesCount)
        currentTrackerAnimation?.play()
        
        let currentShieldAnimation = (showDot ? container.privacyIcon.shieldDotAnimationView : container.privacyIcon.shieldAnimationView)
        currentShieldAnimation?.play { [weak container] _ in
            self.animationState = .afterAnimations
            
            container?.privacyIcon.updateIcon(privacyIcon)
            
            UIView.animate(withDuration: 0.2) {
                omniBar.textField.alpha = 1
            }
        }
    }
    
    func startAnimationForDaxDialog(in omniBar: OmniBar, with siteRating: SiteRating) {
        guard let container = omniBar.privacyInfoContainer else { return }
        
        animationState = .animatingForDaxDialog
        
        let privacyIcon = PrivacyIconLogic.privacyIcon(for: siteRating)
        let showDot = (privacyIcon == .shieldWithDot)
        
        container.privacyIcon.shieldAnimationView.isHidden = showDot
        container.privacyIcon.shieldDotAnimationView.isHidden = !showDot
        container.privacyIcon.daxLogoImageView.isHidden = true
        
        container.privacyIcon.updateIcon(privacyIcon)
                
        UIView.animate(withDuration: 0.2) {
            omniBar.textField.alpha = 0
        }
        
        let currentTrackerAnimation = currentTrackerAnimationView(in: container, for: trackerAnimationImageProvider.trackerImagesCount)
        currentTrackerAnimation?.play(toFrame: 45)  // stop frame for all 3 tracker animations
    }
    
    func completeAnimationForDaxDialog(in omniBar: OmniBar) {
        guard let container = omniBar.privacyInfoContainer else { return }
        
        let currentTrackerAnimation = currentTrackerAnimationView(in: container,
                                                                  for: trackerAnimationImageProvider.trackerImagesCount)
        currentTrackerAnimation?.play()
        
        let currentShieldAnimation = [container.privacyIcon.shieldAnimationView, container.privacyIcon.shieldDotAnimationView].first { !$0.isHidden }
        currentShieldAnimation?.currentFrame = 45
        currentShieldAnimation?.play(completion: { [weak container] _ in
            self.animationState = .afterAnimations
            
            container?.privacyIcon.refresh()
            
            UIView.animate(withDuration: 0.2) {
                omniBar.textField.alpha = 1
            }
        })
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
        
        container.privacyIcon.refresh()
        
        omniBar.textField.layer.removeAllAnimations()
        omniBar.textField.alpha = 1
        
        animationState = .noAnimations
    }
    
    func resetImageProvider() {
        trackerAnimationImageProvider.reset()
    }
}
