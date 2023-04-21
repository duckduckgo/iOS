//
//  AppTrackerImageCache.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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
import SwiftUI
import PrivacyDashboardResources

enum TrackerEntityRepresentable {
    case svg(UIImage)
    case view(GenericIconData)
}

struct GenericIconData {
    let trackerLetter: String
    let trackerColor: Color
}

final class AppTrackerImageCache {
    
    private var blankTrackerImage: TrackerEntityRepresentable!
    private var cachedTrackerImages: [String: TrackerEntityRepresentable]!
    
    private enum ImageDir: String {
        case letters
        case logos
    }
    
    let bundleModule = Bundle.privacyDashboardResourcesBundle
    
    let colors: [Color] = [
        Color("Blue"),
        Color("DarkBlue"),
        Color("GrayPurple"),
        Color("Green"),
        Color("GreenBlue"),
        Color("LightBlue"),
        Color("LightGreen"),
        Color("LightGreenBlue"),
        Color("LightPurple"),
        Color("Mint"),
        Color("Orange"),
        Color("OrangeRed"),
        Color("Purple"),
        Color("Red"),
        Color("Violet"),
        Color("Yellow")
    ]
    
    init() {
        resetCache()
    }
    
    private func resetCache() {
        cachedTrackerImages = [:]
        blankTrackerImage = .view(GenericIconData(trackerLetter: "T", trackerColor: colors.randomElement()!))
    }
    
    public func loadTrackerImage(for entityName: String) -> TrackerEntityRepresentable {
        if let cachedImage = cachedTrackerImages[entityName] {
            return cachedImage
        } else {
            let trackerImage = makeTrackerImage(for: entityName)
            cachedTrackerImages[entityName] = trackerImage
            return trackerImage
        }
    }
    
    private func makeTrackerImage(for entityName: String) -> TrackerEntityRepresentable {
        if let image = loadTrackerLogoImage(for: entityName) {
            return .svg(image)
        } else if let firstLetter = entityName.first {
            return .view(GenericIconData(trackerLetter: String(firstLetter),
                                         trackerColor: colors.randomElement()!))
        } else {
            return blankTrackerImage
        }
    }
    
    private func loadTrackerLogoImage(for entityName: String) -> UIImage? {
        switch entityName {
        case "Adform A/S": return UIImage(named: "Adform AS")
        case "cloudflare": return UIImage(named: "cloudflare-app")
        case "linkedin": return UIImage(named: "linkedin-app")
        default: return UIImage(named: entityName)
        }
    }
    
}
