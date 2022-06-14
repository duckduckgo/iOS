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
    
    private var lastTrackerImages = [CGImage]()
    public var trackerImagesCount: Int { lastTrackerImages.count }
    
    public func loadTrackerImages(from siteRating: SiteRating) {
        let sortedEntities = sortedEntities(from: siteRating).prefix(Const.maxNumberOfIcons)
        
        var images: [CGImage] = sortedEntities.map {
            if let logo = logos[$0] {
                return logo
            } else if let letter = letters[$0[$0.startIndex]] {
                return letter
            } else {
                return blankTrackerImage
            }
        }
        if images.count == Const.maxNumberOfIcons {
            images[Const.maxNumberOfIcons - 1] = shadowTrackerImage
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
    
    // MARK: - Images
    
    var shadowTrackerImage: CGImage { UIImage(named: "shadowtracker")!.cgImage! }
    var blankTrackerImage: CGImage { UIImage(named: "blanktracker")!.cgImage! }
    
    var letters: [Character: CGImage] {
        return [
            "a": UIImage(named: "a")!.cgImage!,
            "b": UIImage(named: "b")!.cgImage!,
            "c": UIImage(named: "c")!.cgImage!,
            "d": UIImage(named: "d")!.cgImage!,
            "e": UIImage(named: "e")!.cgImage!,
            "f": UIImage(named: "f")!.cgImage!,
            "g": UIImage(named: "g")!.cgImage!,
            "h": UIImage(named: "h")!.cgImage!,
            "i": UIImage(named: "i")!.cgImage!,
            "j": UIImage(named: "j")!.cgImage!,
            "k": UIImage(named: "k")!.cgImage!,
            "l": UIImage(named: "l")!.cgImage!,
            "m": UIImage(named: "m")!.cgImage!,
            "n": UIImage(named: "n")!.cgImage!,
            "o": UIImage(named: "o")!.cgImage!,
            "p": UIImage(named: "p")!.cgImage!,
            "q": UIImage(named: "q")!.cgImage!,
            "r": UIImage(named: "r")!.cgImage!,
            "s": UIImage(named: "s")!.cgImage!,
            "t": UIImage(named: "t")!.cgImage!,
            "u": UIImage(named: "u")!.cgImage!,
            "v": UIImage(named: "v")!.cgImage!,
            "w": UIImage(named: "w")!.cgImage!,
            "x": UIImage(named: "x")!.cgImage!,
            "y": UIImage(named: "y")!.cgImage!,
            "z": UIImage(named: "z")!.cgImage!
        ]
    }
    
    var logos: [String: CGImage] {
        return [
            "adform": UIImage(named: "adform")!.cgImage!,
            "adobe": UIImage(named: "adobe")!.cgImage!,
            "amazon": UIImage(named: "amazon")!.cgImage!,
            "amobee": UIImage(named: "amobee")!.cgImage!,
            "appnexus": UIImage(named: "appnexus")!.cgImage!,
            "centro": UIImage(named: "centro")!.cgImage!,
            "cloudflare": UIImage(named: "cloudflare")!.cgImage!,
            "comscore": UIImage(named: "comscore")!.cgImage!,
            "conversant": UIImage(named: "conversant")!.cgImage!,
            "criteo": UIImage(named: "criteo")!.cgImage!,
            "dataxu": UIImage(named: "dataxu")!.cgImage!,
            "facebook": UIImage(named: "facebook")!.cgImage!,
            "google": UIImage(named: "google")!.cgImage!,
            "hotjar": UIImage(named: "hotjar")!.cgImage!,
            "indexexchange": UIImage(named: "indexexchange")!.cgImage!,
            "iponweb": UIImage(named: "iponweb")!.cgImage!,
            "linkedin": UIImage(named: "linkedin")!.cgImage!,
            "lotame": UIImage(named: "lotame")!.cgImage!,
            "mediamath": UIImage(named: "mediamath")!.cgImage!,
            "neustar": UIImage(named: "neustar")!.cgImage!,
            "newrelic": UIImage(named: "newrelic")!.cgImage!,
            "nielsen": UIImage(named: "nielsen")!.cgImage!,
            "openx": UIImage(named: "openx")!.cgImage!,
            "oracle": UIImage(named: "oracle")!.cgImage!,
            "pubmatic": UIImage(named: "pubmatic")!.cgImage!,
            "qwantcast": UIImage(named: "qwantcast")!.cgImage!,
            "rubicon": UIImage(named: "rubicon")!.cgImage!,
            "salesforce": UIImage(named: "salesforce")!.cgImage!,
            "smartadserver": UIImage(named: "smartadserver")!.cgImage!,
            "spotx": UIImage(named: "spotx")!.cgImage!,
            "stackpath": UIImage(named: "stackpath")!.cgImage!,
            "taboola": UIImage(named: "taboola")!.cgImage!,
            "tapad": UIImage(named: "tapad")!.cgImage!,
            "the trade desk": UIImage(named: "thetradedesk")!.cgImage!,
            "towerdata": UIImage(named: "towerdata")!.cgImage!,
            "twitter": UIImage(named: "twitter")!.cgImage!,
            "verizon media": UIImage(named: "verizonmedia")!.cgImage!,
            "windows": UIImage(named: "windows")!.cgImage!,
            "xaxis": UIImage(named: "xaxis")!.cgImage!
        ]
    }
    
   
}
