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

    // swiftlint:disable:next cyclomatic_complexity
    private func loadTrackerLogoImage(for entityName: String) -> CGImage? {
        switch entityName {
        case "adform": return UIImage(named: "adform", in: nil, compatibleWith: trait)!.cgImage!
        case "adobe": return UIImage(named: "adobe", in: nil, compatibleWith: trait)!.cgImage!
        case "amazon": return UIImage(named: "amazon", in: nil, compatibleWith: trait)!.cgImage!
        case "amobee": return UIImage(named: "amobee", in: nil, compatibleWith: trait)!.cgImage!
        case "appnexus": return UIImage(named: "appnexus", in: nil, compatibleWith: trait)!.cgImage!
        case "centro": return UIImage(named: "centro", in: nil, compatibleWith: trait)!.cgImage!
        case "cloudflare": return UIImage(named: "cloudflare", in: nil, compatibleWith: trait)!.cgImage!
        case "comscore": return UIImage(named: "comscore", in: nil, compatibleWith: trait)!.cgImage!
        case "conversant": return UIImage(named: "conversant", in: nil, compatibleWith: trait)!.cgImage!
        case "criteo": return UIImage(named: "criteo", in: nil, compatibleWith: trait)!.cgImage!
        case "dataxu": return UIImage(named: "dataxu", in: nil, compatibleWith: trait)!.cgImage!
        case "facebook": return UIImage(named: "facebook", in: nil, compatibleWith: trait)!.cgImage!
        case "google": return UIImage(named: "google", in: nil, compatibleWith: trait)!.cgImage!
        case "hotjar": return UIImage(named: "hotjar", in: nil, compatibleWith: trait)!.cgImage!
        case "indexexchange": return UIImage(named: "indexexchange", in: nil, compatibleWith: trait)!.cgImage!
        case "iponweb": return UIImage(named: "iponweb", in: nil, compatibleWith: trait)!.cgImage!
        case "linkedin": return UIImage(named: "linkedin", in: nil, compatibleWith: trait)!.cgImage!
        case "lotame": return UIImage(named: "lotame", in: nil, compatibleWith: trait)!.cgImage!
        case "mediamath": return UIImage(named: "mediamath", in: nil, compatibleWith: trait)!.cgImage!
        case "microsoft": return UIImage(named: "microsoft", in: nil, compatibleWith: trait)!.cgImage!
        case "neustar": return UIImage(named: "neustar", in: nil, compatibleWith: trait)!.cgImage!
        case "newrelic": return UIImage(named: "newrelic", in: nil, compatibleWith: trait)!.cgImage!
        case "nielsen": return UIImage(named: "nielsen", in: nil, compatibleWith: trait)!.cgImage!
        case "openx": return UIImage(named: "openx", in: nil, compatibleWith: trait)!.cgImage!
        case "oracle": return UIImage(named: "oracle", in: nil, compatibleWith: trait)!.cgImage!
        case "pubmatic": return UIImage(named: "pubmatic", in: nil, compatibleWith: trait)!.cgImage!
        case "qwantcast": return UIImage(named: "qwantcast", in: nil, compatibleWith: trait)!.cgImage!
        case "rubicon": return UIImage(named: "rubicon", in: nil, compatibleWith: trait)!.cgImage!
        case "salesforce": return UIImage(named: "salesforce", in: nil, compatibleWith: trait)!.cgImage!
        case "smartadserver": return UIImage(named: "smartadserver", in: nil, compatibleWith: trait)!.cgImage!
        case "spotx": return UIImage(named: "spotx", in: nil, compatibleWith: trait)!.cgImage!
        case "stackpath": return UIImage(named: "stackpath", in: nil, compatibleWith: trait)!.cgImage!
        case "taboola": return UIImage(named: "taboola", in: nil, compatibleWith: trait)!.cgImage!
        case "tapad": return UIImage(named: "tapad", in: nil, compatibleWith: trait)!.cgImage!
        case "the trade desk": return UIImage(named: "thetradedesk", in: nil, compatibleWith: trait)!.cgImage!
        case "towerdata": return UIImage(named: "towerdata", in: nil, compatibleWith: trait)!.cgImage!
        case "twitter": return UIImage(named: "twitter", in: nil, compatibleWith: trait)!.cgImage!
        case "verizon media": return UIImage(named: "verizonmedia", in: nil, compatibleWith: trait)!.cgImage!
        case "windows": return UIImage(named: "windows", in: nil, compatibleWith: trait)!.cgImage!
        case "xaxis": return UIImage(named: "xaxis")!.cgImage
        default: return nil
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    private func loadTrackerLetterImage(for character: Character) -> CGImage? {
        switch character {
        case "a": return UIImage(named: "a", in: nil, compatibleWith: trait)!.cgImage!
        case "b": return UIImage(named: "b", in: nil, compatibleWith: trait)!.cgImage!
        case "c": return UIImage(named: "c", in: nil, compatibleWith: trait)!.cgImage!
        case "d": return UIImage(named: "d", in: nil, compatibleWith: trait)!.cgImage!
        case "e": return UIImage(named: "e", in: nil, compatibleWith: trait)!.cgImage!
        case "f": return UIImage(named: "f", in: nil, compatibleWith: trait)!.cgImage!
        case "g": return UIImage(named: "g", in: nil, compatibleWith: trait)!.cgImage!
        case "h": return UIImage(named: "h", in: nil, compatibleWith: trait)!.cgImage!
        case "i": return UIImage(named: "i", in: nil, compatibleWith: trait)!.cgImage!
        case "j": return UIImage(named: "j", in: nil, compatibleWith: trait)!.cgImage!
        case "k": return UIImage(named: "k", in: nil, compatibleWith: trait)!.cgImage!
        case "l": return UIImage(named: "l", in: nil, compatibleWith: trait)!.cgImage!
        case "m": return UIImage(named: "m", in: nil, compatibleWith: trait)!.cgImage!
        case "n": return UIImage(named: "n", in: nil, compatibleWith: trait)!.cgImage!
        case "o": return UIImage(named: "o", in: nil, compatibleWith: trait)!.cgImage!
        case "p": return UIImage(named: "p", in: nil, compatibleWith: trait)!.cgImage!
        case "q": return UIImage(named: "q", in: nil, compatibleWith: trait)!.cgImage!
        case "r": return UIImage(named: "r", in: nil, compatibleWith: trait)!.cgImage!
        case "s": return UIImage(named: "s", in: nil, compatibleWith: trait)!.cgImage!
        case "t": return UIImage(named: "t", in: nil, compatibleWith: trait)!.cgImage!
        case "u": return UIImage(named: "u", in: nil, compatibleWith: trait)!.cgImage!
        case "v": return UIImage(named: "v", in: nil, compatibleWith: trait)!.cgImage!
        case "w": return UIImage(named: "w", in: nil, compatibleWith: trait)!.cgImage!
        case "x": return UIImage(named: "x", in: nil, compatibleWith: trait)!.cgImage!
        case "y": return UIImage(named: "y", in: nil, compatibleWith: trait)!.cgImage!
        case "z": return UIImage(named: "z", in: nil, compatibleWith: trait)!.cgImage!
        default: return nil
        }
    }
}
