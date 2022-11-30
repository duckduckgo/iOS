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
import PrivacyDashboard

private enum Constants {
    static let textFieldFadeDuration = 0.2
    static let allTrackersRevealedAnimationFrame = 45.0
}

final class PrivacyIconAndTrackersAnimator {

    private let trackerAnimationImageProvider = TrackerAnimationImageProvider()
    private(set) var isAnimatingForDaxDialog: Bool = false
    
    func configure(_ container: PrivacyInfoContainerView, with privacyInfo: PrivacyInfo) {
        isAnimatingForDaxDialog = false
        
        container.trackers1Animation.currentFrame = 0
        container.trackers2Animation.currentFrame = 0
        container.trackers3Animation.currentFrame = 0
        
        container.privacyIcon.shieldAnimationView.currentFrame = 0
        container.privacyIcon.shieldDotAnimationView.currentFrame = 0
        
        if TrackerAnimationLogic.shouldAnimateTrackers(for: privacyInfo.trackerInfo) {
            // For
            trackerAnimationImageProvider.loadTrackerImages(for: privacyInfo.trackerInfo)
      
            if let trackerAnimationView = container.trackerAnimationView(for: trackerAnimationImageProvider.trackerImagesCount) {
                trackerAnimationView.imageProvider = trackerAnimationImageProvider
                trackerAnimationView.reloadImages()
            }
            
            container.privacyIcon.updateIcon(.shield)
        } else {
            // No animation directly set icon
            let icon = PrivacyIconLogic.privacyIcon(for: privacyInfo)
            container.privacyIcon.updateIcon(icon)
        }
    }
    
    func startAnimating(in omniBar: OmniBar, with privacyInfo: PrivacyInfo) {
        guard let container = omniBar.privacyInfoContainer else { return }
        
        let privacyIcon = PrivacyIconLogic.privacyIcon(for: privacyInfo)
        
        container.privacyIcon.prepareForAnimation(for: privacyIcon)
                
        UIView.animate(withDuration: Constants.textFieldFadeDuration) {
            omniBar.textField.alpha = 0
        }

        let currentTrackerAnimation = container.trackerAnimationView(for: trackerAnimationImageProvider.trackerImagesCount)
        currentTrackerAnimation?.play()
        
        let currentShieldAnimation = container.privacyIcon.shieldAnimationView(for: privacyIcon)
        currentShieldAnimation?.play { [weak container] _ in
            container?.privacyIcon.updateIcon(privacyIcon)
            
            UIView.animate(withDuration: Constants.textFieldFadeDuration) {
                omniBar.textField.alpha = 1
            }
            
            container?.privacyIcon.refresh()
        }
    }
    
    func startAnimationForDaxDialog(in omniBar: OmniBar, with privacyInfo: PrivacyInfo) {
        guard let container = omniBar.privacyInfoContainer else { return }
        
        isAnimatingForDaxDialog = true
        
        let privacyIcon = PrivacyIconLogic.privacyIcon(for: privacyInfo)
        
        container.privacyIcon.prepareForAnimation(for: privacyIcon)
                        
        UIView.animate(withDuration: Constants.textFieldFadeDuration) {
            omniBar.textField.alpha = 0
        }
        
        let currentTrackerAnimation = container.trackerAnimationView(for: trackerAnimationImageProvider.trackerImagesCount)
        currentTrackerAnimation?.play(toFrame: Constants.allTrackersRevealedAnimationFrame)
    }
    
    func completeAnimationForDaxDialog(in omniBar: OmniBar) {
        guard let container = omniBar.privacyInfoContainer else { return }
        
        let currentTrackerAnimation = container.trackerAnimationView(for: trackerAnimationImageProvider.trackerImagesCount)
        currentTrackerAnimation?.play()
        
        let currentShieldAnimation = [container.privacyIcon.shieldAnimationView, container.privacyIcon.shieldDotAnimationView].first { !$0.isHidden }
        currentShieldAnimation?.currentFrame = Constants.allTrackersRevealedAnimationFrame
        currentShieldAnimation?.play(completion: { [weak container] _ in
            self.isAnimatingForDaxDialog = false
            
            container?.privacyIcon.refresh()
            
            UIView.animate(withDuration: Constants.textFieldFadeDuration) {
                omniBar.textField.alpha = 1
            }
        })
    }
    
    func cancelAnimations(in omniBar: OmniBar) {
        guard let container = omniBar.privacyInfoContainer else { return }
        
        isAnimatingForDaxDialog = false
        
        container.trackers1Animation.stop()
        container.trackers2Animation.stop()
        container.trackers3Animation.stop()
        
        container.privacyIcon.shieldAnimationView.stop()
        container.privacyIcon.shieldDotAnimationView.stop()
        
        container.privacyIcon.refresh()
        
        omniBar.textField.layer.removeAllAnimations()
        omniBar.textField.alpha = 1
    }
    
    func resetImageProvider() {
        trackerAnimationImageProvider.reset()
    }
}
