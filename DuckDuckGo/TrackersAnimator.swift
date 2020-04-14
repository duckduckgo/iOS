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
    
    func configure(_ trackersStackView: TrackersStackView,
                   toDisplay trackers: [DetectedTracker]) -> Bool {
        
        let entities = Set(trackers.compactMap { $0.entity }).sorted { l, r -> Bool in
            return (l.prevalence ?? 0) > (r.prevalence ?? 0)
        }.filter { $0.displayName != nil }
        
        guard !entities.isEmpty else { return false }
        
        var iconImages: [UIImage]
        if entities.count > 3 {
            iconImages = entities.prefix(2).compactMap { entity -> UIImage? in
                return PrivacyProtectionIconSource.iconImage(for: entity.displayName!)
            }
            iconImages.append(UIImage(named: "PP Network Icon more")!)
        } else {
            iconImages = entities.prefix(3).compactMap { entity -> UIImage? in
                return PrivacyProtectionIconSource.iconImage(for: entity.displayName!)
            }
        }
        
        let imageViews = [trackersStackView.firstIcon,
                          trackersStackView.secondIcon,
                          trackersStackView.thirdIcon]
        
        for imageView in imageViews {
            guard !iconImages.isEmpty else {
                imageView?.isHidden = true
                continue
            }
            let iconImage = iconImages.removeFirst()
            imageView?.isHidden = false
            imageView?.image = iconImage
        }
        
        return true
    }
    
    func startAnimating(in omniBar: OmniBar) {
        UIView.animate(withDuration: 0.2, animations: {
            omniBar.trackersStackView.isHidden = false
            omniBar.trackersStackView.alpha = 1
            omniBar.textField.alpha = 0
            omniBar.siteRatingView.alpha = 0
        }, completion: { _ in
            
            let animateWorkItem = DispatchWorkItem(block: {
                omniBar.trackersStackView.animateTrackers()
                
                let hideWorkItem = DispatchWorkItem {
                    self.stopAnimating(in: omniBar)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.6, execute: hideWorkItem)
                self.nextAnimation = hideWorkItem
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: animateWorkItem)
            self.nextAnimation = animateWorkItem
        })
    }
    
    func stopAnimating(in omniBar: OmniBar) {
        nextAnimation?.cancel()
        nextAnimation = nil
        
        UIView.animate(withDuration: 0.2, animations: {
            omniBar.trackersStackView.alpha = 0
            omniBar.textField.alpha = 1
            omniBar.siteRatingView.alpha = 1
        }, completion: { _ in
            omniBar.trackersStackView.isHidden = true
            omniBar.trackersStackView.resetTrackers()
        })
    }
    
}
