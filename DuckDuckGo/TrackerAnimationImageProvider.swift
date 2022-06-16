//
//  TrackerAnimationImageProvider.swift
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

import Core
import UIKit
import Lottie

private enum Const {
    static let maxNumberOfIcons = 4
}

extension TrackerAnimationImageProvider: AnimationImageProvider {
    
    func imageForAsset(asset: ImageAsset) -> CGImage? {
        switch asset.name {
        case "img_0.png": return lastTrackerImages[safe: 0]
        case "img_1.png": return lastTrackerImages[safe: 1]
        case "img_2.png": return lastTrackerImages[safe: 2]
        case "img_3.png": return lastTrackerImages[safe: 3]
        default: return nil
        }
    }
}

final class TrackerAnimationImageProvider {
    
    public var trackerImagesCount: Int { lastTrackerImages.count }
    
    private var lastTrackerImages = [CGImage]()
    private let trackerImageCache = TrackerImageCache()
    
    public func reset() {
        trackerImageCache.resetCache()
    }
    
    public func loadTrackerImages(from siteRating: SiteRating) {
        let sortedEntities = sortedEntities(from: siteRating).prefix(Const.maxNumberOfIcons)
        
        var images: [CGImage] = sortedEntities.map {
            trackerImageCache.trackerImage(for: $0)
        }
        
        if images.count == Const.maxNumberOfIcons {
            images[Const.maxNumberOfIcons - 1] = trackerImageCache.shadowTrackerImage
        }
        
        lastTrackerImages = images
    }
    
    private func sortedEntities(from siteRating: SiteRating) -> [String] {
        struct LightEntity: Hashable {
            let name: String
            let prevalence: Double
        }
        
        let blockedEntities: Set<LightEntity> =
        // Filter entity duplicates by using Set
        Set(siteRating.trackersBlocked
            // Filter trackers without entity or entity name
            .compactMap {
                if let entityName = $0.entity?.displayName, entityName.count > 0 {
                    return LightEntity(name: entityName, prevalence: $0.entity?.prevalence ?? 0)
                }
                return nil
            })
        
        return blockedEntities
        // Sort by prevalence
            .sorted { l, r -> Bool in
                return l.prevalence > r.prevalence
            }
        // Get first character
            .map {
                return $0.name.lowercased()
            }
        // Prioritise entities with images
            .sorted { _, r -> Bool in
                return "aeiou".contains(r[r.startIndex])
            }
    }
}
