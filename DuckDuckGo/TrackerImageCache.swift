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
    
    public func resetCache() {
        shadowTrackerImage = UIImage(named: "shadowtracker")!.cgImage!
        blankTrackerImage = UIImage(named: "blanktracker")!.cgImage!
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
    
    // swiftlint:disable cyclomatic_complexity
    // swiftlint:disable function_body_length
    private func loadTrackerLogoImage(for entityName: String) -> CGImage? {
        switch entityName {
        case "adform": return UIImage(named: "adform")!.cgImage!
        case "adobe": return UIImage(named: "adobe")!.cgImage!
        case "amazon": return UIImage(named: "amazon")!.cgImage!
        case "amobee": return UIImage(named: "amobee")!.cgImage!
        case "appnexus": return UIImage(named: "appnexus")!.cgImage!
        case "centro": return UIImage(named: "centro")!.cgImage!
        case "cloudflare": return UIImage(named: "cloudflare")!.cgImage!
        case "comscore": return UIImage(named: "comscore")!.cgImage!
        case "conversant": return UIImage(named: "conversant")!.cgImage!
        case "criteo": return UIImage(named: "criteo")!.cgImage!
        case "dataxu": return UIImage(named: "dataxu")!.cgImage!
        case "facebook": return UIImage(named: "facebook")!.cgImage!
        case "google": return UIImage(named: "google")!.cgImage!
        case "hotjar": return UIImage(named: "hotjar")!.cgImage!
        case "indexexchange": return UIImage(named: "indexexchange")!.cgImage!
        case "iponweb": return UIImage(named: "iponweb")!.cgImage!
        case "linkedin": return UIImage(named: "linkedin")!.cgImage!
        case "lotame": return UIImage(named: "lotame")!.cgImage!
        case "mediamath": return UIImage(named: "mediamath")!.cgImage!
        case "neustar": return UIImage(named: "neustar")!.cgImage!
        case "newrelic": return UIImage(named: "newrelic")!.cgImage!
        case "nielsen": return UIImage(named: "nielsen")!.cgImage!
        case "openx": return UIImage(named: "openx")!.cgImage!
        case "oracle": return UIImage(named: "oracle")!.cgImage!
        case "pubmatic": return UIImage(named: "pubmatic")!.cgImage!
        case "qwantcast": return UIImage(named: "qwantcast")!.cgImage!
        case "rubicon": return UIImage(named: "rubicon")!.cgImage!
        case "salesforce": return UIImage(named: "salesforce")!.cgImage!
        case "smartadserver": return UIImage(named: "smartadserver")!.cgImage!
        case "spotx": return UIImage(named: "spotx")!.cgImage!
        case "stackpath": return UIImage(named: "stackpath")!.cgImage!
        case "taboola": return UIImage(named: "taboola")!.cgImage!
        case "tapad": return UIImage(named: "tapad")!.cgImage!
        case "the trade desk": return UIImage(named: "thetradedesk")!.cgImage!
        case "towerdata": return UIImage(named: "towerdata")!.cgImage!
        case "twitter": return UIImage(named: "twitter")!.cgImage!
        case "verizon media": return UIImage(named: "verizonmedia")!.cgImage!
        case "windows": return UIImage(named: "windows")!.cgImage!
        case "xaxis": return UIImage(named: "xaxis")!.cgImage
        default: return nil
        }
    }
    
    // swiftlint:disable cyclomatic_complexity
    private func loadTrackerLetterImage(for character: Character) -> CGImage? {
        switch character {
        case "a": return UIImage(named: "a")!.cgImage!
        case "b": return UIImage(named: "b")!.cgImage!
        case "c": return UIImage(named: "c")!.cgImage!
        case "d": return UIImage(named: "d")!.cgImage!
        case "e": return UIImage(named: "e")!.cgImage!
        case "f": return UIImage(named: "f")!.cgImage!
        case "g": return UIImage(named: "g")!.cgImage!
        case "h": return UIImage(named: "h")!.cgImage!
        case "i": return UIImage(named: "i")!.cgImage!
        case "j": return UIImage(named: "j")!.cgImage!
        case "k": return UIImage(named: "k")!.cgImage!
        case "l": return UIImage(named: "l")!.cgImage!
        case "m": return UIImage(named: "m")!.cgImage!
        case "n": return UIImage(named: "n")!.cgImage!
        case "o": return UIImage(named: "o")!.cgImage!
        case "p": return UIImage(named: "p")!.cgImage!
        case "q": return UIImage(named: "q")!.cgImage!
        case "r": return UIImage(named: "r")!.cgImage!
        case "s": return UIImage(named: "s")!.cgImage!
        case "t": return UIImage(named: "t")!.cgImage!
        case "u": return UIImage(named: "u")!.cgImage!
        case "v": return UIImage(named: "v")!.cgImage!
        case "w": return UIImage(named: "w")!.cgImage!
        case "x": return UIImage(named: "x")!.cgImage!
        case "y": return UIImage(named: "y")!.cgImage!
        case "z": return UIImage(named: "z")!.cgImage!
        default: return nil
        }
    }
}
