//
//  TrackerImageCache.swift
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

final class TrackerImageCache {
    
    public var shadowTrackerImage: CGImage!
    private var blankTrackerImage: CGImage!
    private var cachedTrackerImages: [String: CGImage]!
    
    init() {
        resetCache()
    }
    
    private var trait: UITraitCollection { ThemeManager.shared.currentTheme.currentImageSet.trait }
    
    public func resetCache() {
        shadowTrackerImage = UIImage(named: "shadowtracker", in: nil, compatibleWith: trait)!.cgImage!
        blankTrackerImage = UIImage(named: "blanktracker", in: nil, compatibleWith: trait)!.cgImage!
        cachedTrackerImages = [:]
    }
   
    public func trackerImage(for entityName: String) -> CGImage {
        if let cachedImage = cachedTrackerImages[entityName] {
            return cachedImage
        } else {
            let image = makeTrackerImage(for: entityName)
            cachedTrackerImages[entityName] = image
            return image
        }
    }
    
    private func makeTrackerImage(for  entityName: String) -> CGImage {
        if let logoImage = loadTrackerLogoImage(for: entityName) {
            return logoImage
        } else if let firstLetter = entityName.first, let letterImage = loadTrackerLetterImage(for: firstLetter) {
            return letterImage
        } else {
            return blankTrackerImage
        }
    }

    private func loadTrackerLogoImage(for entityName: String) -> CGImage? {
        // To support logo entityName must match asset name in Trackers.xcassets
        UIImage(named: entityName, in: nil, compatibleWith: trait)?.cgImage
    }

    private func loadTrackerLetterImage(for character: Character) -> CGImage? {
        UIImage(named: String(character), in: nil, compatibleWith: trait)?.cgImage
    }
}
