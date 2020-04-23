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
        
        static let hideRevealAnimatonTime: TimeInterval = 0.2
        static let delayBeforeCrossOut: TimeInterval = 0.8
        static let crossOutDuration: TimeInterval = 0.2
        static let delayAfterCrossOut: TimeInterval = 1.5
    }
    
    func setup(_ omniBar: OmniBar) {
        omniBar.siteRatingContainer.widthEqualToSiteRating.isActive = true
        omniBar.siteRatingContainer.widthToAccommodateTrackerIcons.isActive = false
    }
    
    func configure(_ trackersStackView: TrackersStackView,
                   toDisplay trackers: [DetectedTracker]) -> Bool {
        
        let entities = Set(trackers.compactMap { $0.entity }).sorted { l, r -> Bool in
            return (l.prevalence ?? 0) > (r.prevalence ?? 0)
        }.filter { $0.displayName != nil }
        
        guard !entities.isEmpty else { return false }
        
        let imageViews: [UIImageView]! = trackersStackView.trackerIcons
        
        var iconImages: [UIImage]
        let iconSize = CGSize(width: Constants.iconWidth, height: Constants.iconHeight)
        if entities.count > imageViews.count {
            iconImages = entities.prefix(2).compactMap { entity -> UIImage? in
                return PrivacyProtectionIconSource.iconImage(for: entity.displayName!, iconSize: iconSize)
            }
            iconImages.append(UIImage(named: "PP Network Icon more")!)
        } else {
            iconImages = entities.prefix(3).compactMap { entity -> UIImage? in
                return PrivacyProtectionIconSource.iconImage(for: entity.displayName!, iconSize: iconSize)
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
    
    func startAnimating(in omniBar: OmniBar) {
        UIView.animate(withDuration: Constants.hideRevealAnimatonTime, animations: {
//            omniBar.trackersStackView.isHidden = false
//            omniBar.trackersStackView.alpha = 1
            omniBar.siteRatingContainer.widthEqualToSiteRating.isActive = false
            omniBar.siteRatingContainer.widthToAccommodateTrackerIcons.isActive = true
            omniBar.textField.alpha = 0
        }, completion: { _ in
            
            let animateCrossOut = DispatchWorkItem(block: {
                omniBar.siteRatingContainer.crossOutTrackerIcons(duration: Constants.crossOutDuration)
                
                let hideTrackers = DispatchWorkItem {
                    self.stopAnimating(in: omniBar)
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
    
    func stopAnimating(in omniBar: OmniBar) {
        nextAnimation?.cancel()
        nextAnimation = nil
        
        UIView.animate(withDuration: Constants.hideRevealAnimatonTime, animations: {
            omniBar.siteRatingContainer.widthEqualToSiteRating.isActive = true
            omniBar.siteRatingContainer.widthToAccommodateTrackerIcons.isActive = false
            omniBar.textField.alpha = 1
        }, completion: { _ in
//            omniBar.trackersStackView.isHidden = true
            omniBar.siteRatingContainer.resetTrackerIcons()
        })
    }
    
}
