//
//  TrackersAnimator.swift
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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
import Core

class TrackersAnimator {
    
    var nextAnimation: DispatchWorkItem?
    
    struct Constants {
        static let iconWidth: CGFloat = 22
        static let iconHeight: CGFloat = 22
        static let iconSpacing: CGFloat = -4
        
        static let hideRevealAnimatonTime: TimeInterval = 0.2
        static let delayBeforeCrossOut: TimeInterval = 0.8
        static let crossOutDuration: TimeInterval = 0.2
        static let delayAfterCrossOut: TimeInterval = 1.5
    }
    
    func setup(_ omniBar: OmniBar) {
        
    }
    
    func configure(_ omniBar: OmniBar,
                   toDisplay trackers: [DetectedTracker]) -> Bool {
        
        let blockedEntities = Set(trackers.compactMap { $0.entity }).sorted { l, r -> Bool in
            return (l.prevalence ?? 0) > (r.prevalence ?? 0)
        }.filter { $0.displayName != nil }
        
        guard !blockedEntities.isEmpty else { return false }
        
        let imageViews: [UIImageView]! = omniBar.siteRatingContainer.trackerIcons
        
        var iconImages: [UIImage]
        let iconSize = CGSize(width: Constants.iconWidth, height: Constants.iconHeight)
        
        let showMoreIcon = blockedEntities.count > imageViews.count
        
        if blockedEntities.count > imageViews.count {
            iconImages = blockedEntities.prefix(2).compactMap { entity -> UIImage? in
                let img = PrivacyProtectionIconSource.iconImage(forNetworkName: entity.displayName!, iconSize: iconSize)
                return PrivacyProtectionIconSource.stackedIconImage(withBaseImage: img!,
                                                                    foregroundColor: omniBar.siteRatingContainer.tintColor!,
                                                                    borderColor: omniBar.siteRatingContainer.crossOutBackgroundColor,
                                                                    borderWidth: 2)
            }
            
            if let baseIcon = PrivacyProtectionIconSource.iconImage(forNetworkName: blockedEntities[2].displayName!, iconSize: iconSize) {
                iconImages.append(PrivacyProtectionIconSource.moreIconImage(withBaseImage: baseIcon))
            }
        } else {
            iconImages = blockedEntities.prefix(3).compactMap { entity -> UIImage? in
                let img = PrivacyProtectionIconSource.iconImage(forNetworkName: entity.displayName!, iconSize: iconSize)
                return PrivacyProtectionIconSource.stackedIconImage(withBaseImage: img!,
                                                                    foregroundColor: omniBar.siteRatingContainer.tintColor!,
                                                                    borderColor: omniBar.siteRatingContainer.crossOutBackgroundColor,
                                                                    borderWidth: 2)
            }
        }
        
        for imageView in imageViews {
            guard !iconImages.isEmpty else {
                imageView.isHidden = true
                continue
            }
            let iconImage = iconImages.removeFirst()
            imageView.isHidden = false
            imageView.image = iconImage
        }
        
        return true
    }
    
    func startLoadingAnimation(in omniBar: OmniBar) {
        
        let animation = CAKeyframeAnimation()
        animation.keyPath = "transform.scale"
        animation.values = [1, 0.9, 1, 0.9, 1]
        animation.keyTimes = [0, 0.25, 0.5, 0.75, 1]
        
        animation.duration = 3
        animation.repeatCount = .greatestFiniteMagnitude
        omniBar.siteRatingView.layer.add(animation, forKey: "scale")
    }
    
    func stopLoadingAnimation(in omniBar: OmniBar) {
        omniBar.siteRatingView.layer.removeAnimation(forKey: "scale")
    }
    
    func showSiteRating(in omniBar: OmniBar) {
        UIView.transition(with: omniBar.siteRatingView,
                          duration: Constants.hideRevealAnimatonTime,
                          options: .transitionCrossDissolve,
                          animations: {
                            omniBar.siteRatingView.mode = .ready
                            omniBar.siteRatingView.refresh(with: AppDependencyProvider.shared.storageCache.current)
        })
    }
    
    func startAnimating(in omniBar: OmniBar) {
        guard let container = omniBar.siteRatingContainer else { return }
        
        stopLoadingAnimation(in: omniBar)
        
        UIView.animateKeyframes(withDuration: Constants.hideRevealAnimatonTime, delay: 0, options: [], animations: {
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0) {
                let gradeIconX = container.siteRatingView.frame.origin.x + container.siteRatingView.circleIndicator.frame.origin.x
                for icon in container.trackerIcons {
                    icon.frame.origin.x = gradeIconX
                    icon.alpha = 1
                }
            }

            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                
                omniBar.textField.alpha = 0
    
                var offset = container.siteRatingView.frame.origin.x + container.siteRatingView.frame.size.width + 1
                for icon in omniBar.siteRatingContainer.trackerIcons {
                    icon.frame.origin.x = offset
                    offset += Constants.iconSpacing + 26
                }
            }
        }, completion: { _ in
            let animateCrossOut = DispatchWorkItem(block: {
                omniBar.siteRatingContainer.crossOutTrackerIcons(duration: Constants.crossOutDuration)
                
                let hideTrackers = DispatchWorkItem {
                    self.collapseIcons(in: omniBar)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + Constants.delayAfterCrossOut,
                                              execute: hideTrackers)
                self.nextAnimation = hideTrackers
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.delayBeforeCrossOut,
                                          execute: animateCrossOut)
            self.nextAnimation = animateCrossOut
        })
        
    }
    
    func collapseIcons(in omniBar: OmniBar) {
        nextAnimation?.cancel()
        nextAnimation = nil
        
        showSiteRating(in: omniBar)
        
        UIView.animate(withDuration: Constants.hideRevealAnimatonTime, animations: {
            guard let container = omniBar.siteRatingContainer else { return }
            for icon in container.trackerIcons {
                icon.center.x = container.siteRatingView.center.x
                icon.alpha = 0
            }
            omniBar.textField.alpha = 1
        }, completion: { _ in
            omniBar.siteRatingContainer.resetTrackerIcons()
        })
        
    }
    
    func stopAnimating(in omniBar: OmniBar) {
        nextAnimation?.cancel()
        nextAnimation = nil
        
        stopLoadingAnimation(in: omniBar)
        showSiteRating(in: omniBar)
        
        UIView.animate(withDuration: Constants.hideRevealAnimatonTime, animations: {
            omniBar.textField.alpha = 1
            omniBar.siteRatingContainer.resetTrackerIcons()
        }, completion: { _ in })
    }
    
}
