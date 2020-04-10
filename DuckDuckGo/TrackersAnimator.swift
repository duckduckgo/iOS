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
    
    func configure(_ trackersStackView: TrackersStackView,
                   toDisplay trackers: [DetectedTracker]) -> Bool {
        
        let entities = Set(trackers.compactMap { $0.entity }).sorted { l, r -> Bool in
            return (l.prevalence ?? 0) > (r.prevalence ?? 0)
        }
        
        var iconImages = entities.compactMap { entity -> UIImage? in
            guard let name = entity.displayName else { return nil }
            return PrivacyProtectionIconSource.iconImage(for: name)
        }
        
        guard !iconImages.isEmpty else { return false }
        
        if iconImages.count > 3 {
            iconImages = Array(iconImages.prefix(2))
            iconImages.append(UIImage(named: "PP Network Icon more")!)
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
    
    func startAnimating(_ omniBar: OmniBar) {
        
    }
    
    func stopAnimating(_ omniBar: OmniBar) {
        
    }
    
}
