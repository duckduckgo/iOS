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
import BrowserServicesKit

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
        
        static let gradeLoadingAnimationKey = "gradeLoadingAnimation"
    }
    
    var shouldCollapse = true
    
    func configure(_ omniBar: OmniBar,
                   toDisplay trackers: [DetectedRequest],
                   shouldCollapse: Bool) -> Bool {
        self.shouldCollapse = shouldCollapse
        
        let blockedEntityNames = trackers.removingDuplicates { $0.entityName }
            .sorted { l, r -> Bool in
                return (l.prevalence ?? 0) > (r.prevalence ?? 0)
            }
            .compactMap { $0.entityName }
            .sorted { _, r -> Bool in
                "AEIOU".contains(r[r.startIndex])
            }
        
        guard !blockedEntityNames.isEmpty else { return false }

        let imageViews: [UIImageView]! = omniBar.siteRatingContainer.trackerIcons
        
        let iconSource = PrivacyProtectionIconSource.self
        let iconSize = CGSize(width: Constants.iconWidth, height: Constants.iconHeight)
        let shouldShowMoreIcon = blockedEntityNames.count > imageViews.count
        
        var iconImages = [UIImage]()
        for (index, entityName) in blockedEntityNames.enumerated() {
            guard index != imageViews.endIndex else {
                break
            }
            
            let iconTemplate = iconSource.iconImageTemplate(forNetworkName: entityName,
                                                 iconSize: iconSize)
            let iconToDisplay: UIImage
            if index == imageViews.endIndex - 1 && shouldShowMoreIcon {
                iconToDisplay = iconSource.moreIconImageTemplate(withIconImage: iconTemplate)
            } else {
                iconToDisplay = iconSource.stackedIconImage(withIconImage: iconTemplate,
                                                            foregroundColor: omniBar.siteRatingContainer.tintColor!,
                                                            borderColor: omniBar.siteRatingContainer.crossOutBackgroundColor)
            }
            
            iconImages.append(iconToDisplay)
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
    
    func startLoadingAnimation(in omniBar: OmniBar, for url: URL?) {
        
        guard let url = url, !AppUrls().isDuckDuckGoSearch(url: url) else {
            omniBar.siteRatingView.mode = .ready
            return
        }
        
        let animation = CAKeyframeAnimation()
        animation.keyPath = "transform.scale"
        animation.values = [1, 0.9, 1, 0.9, 1]
        animation.keyTimes = [0, 0.25, 0.5, 0.75, 1]
        
        animation.duration = 3
        animation.repeatCount = .greatestFiniteMagnitude
        
        omniBar.siteRatingView.mode = .loading
        omniBar.siteRatingView.layer.add(animation, forKey: Constants.gradeLoadingAnimationKey)
    }
    
    func stopLoadingAnimation(in omniBar: OmniBar) {
        omniBar.siteRatingView.layer.removeAnimation(forKey: Constants.gradeLoadingAnimationKey)
    }
    
    func showSiteRating(in omniBar: OmniBar) {
        guard omniBar.siteRatingView.mode != .ready else { return }
        
        UIView.transition(with: omniBar.siteRatingView,
                          duration: Constants.hideRevealAnimatonTime,
                          options: .transitionCrossDissolve,
                          animations: {
            omniBar.siteRatingView.mode = .ready
            omniBar.siteRatingView.refresh(with: ContentBlocking.shared.privacyConfigurationManager.privacyConfig)
        })
    }
    
    func startAnimating(in omniBar: OmniBar) {
        guard let container = omniBar.siteRatingContainer else { return }
        
        stopLoadingAnimation(in: omniBar)
        
        UIView.animateKeyframes(withDuration: Constants.hideRevealAnimatonTime, delay: 0, options: [], animations: {
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0) {
                for constraint in container.trackerIconConstraints {
                    constraint.constant = container.siteRatingIconOffset
                }
                for icon in container.trackerIcons {
                    icon.alpha = 1
                }
                omniBar.siteRatingContainer.layoutIfNeeded()
            }

            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                
                omniBar.textField.alpha = 0
                
                let iconWidth = container.trackerIcons.first?.frame.width ?? 0
                var offset = container.siteRatingView.frame.origin.x + container.siteRatingView.frame.size.width + 1
                for constraint in container.trackerIconConstraints {
                    constraint.constant = offset
                    offset += Constants.iconSpacing + iconWidth
                }
                omniBar.siteRatingContainer.layoutIfNeeded()
            }
        }, completion: { _ in
            let animateCrossOut = DispatchWorkItem(block: {
                omniBar.siteRatingContainer.crossOutTrackerIcons(duration: Constants.crossOutDuration)

                let hideTrackers = DispatchWorkItem {
                    self.collapseIcons(in: omniBar)
                }

                if self.shouldCollapse {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Constants.delayAfterCrossOut,
                                                  execute: hideTrackers)
                }
                
                self.nextAnimation = hideTrackers
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.delayBeforeCrossOut,
                                          execute: animateCrossOut)
            self.nextAnimation = animateCrossOut
        })
        
    }
    
    private func collapseIcons(in omniBar: OmniBar) {
        nextAnimation?.cancel()
        nextAnimation = nil
        
        showSiteRating(in: omniBar)
        
        UIView.animate(withDuration: Constants.hideRevealAnimatonTime, animations: {
            guard let container = omniBar.siteRatingContainer else { return }

            for constraint in container.trackerIconConstraints {
                constraint.constant = container.siteRatingIconOffset
            }
            for icon in container.trackerIcons {
                icon.alpha = 0
            }
            omniBar.textField.alpha = 1
            
            container.layoutIfNeeded()
        }, completion: { _ in
            omniBar.siteRatingContainer.resetTrackerIcons()
        })
        
    }
    
    func cancelAnimations(in omniBar: OmniBar) {
        nextAnimation?.cancel()
        nextAnimation = nil
        
        stopLoadingAnimation(in: omniBar)
        showSiteRating(in: omniBar)
        
        UIView.animate(withDuration: Constants.hideRevealAnimatonTime, animations: {
            omniBar.textField.alpha = 1
            omniBar.siteRatingContainer.resetTrackerIcons()
        }, completion: { _ in })
    }
    
    func completeAnimations(in omniBar: OmniBar) {
        collapseIcons(in: omniBar)
    }
    
}
