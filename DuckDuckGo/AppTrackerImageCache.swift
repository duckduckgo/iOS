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
import PrivacyDashboardResources

final class AppTrackerImageCache {
    
    private var blankTrackerImage: Data!
    private var cachedTrackerImages: [String: Data]!
    
    private enum ImageDir: String {
        case letters
        case logos
    }
    
    let bundleModule = Bundle.privacyDashboardResourcesBundle
    
    init() {
        resetCache()
    }
    
    private func pathForImage(named name: String, subdir: ImageDir) -> URL? {
        return bundleModule.url(forResource: name, withExtension: "svg", subdirectory: "img/refresh-assets/tracker-icons/\(subdir)")
    }
    
    private func dataFromBundle(for name: String, subdir: ImageDir) -> Data? {
        guard let path = pathForImage(named: name, subdir: subdir) else { return nil }
        
        do {
            return try Data(contentsOf: path)
        } catch {
            print(error.localizedDescription)
        }
        
        return nil
    }
    
    private func resetCache() {
        cachedTrackerImages = [:]
        blankTrackerImage = dataFromBundle(for: "T", subdir: .letters)
    }
    
    public func loadTrackerImage(for entityName: String) -> Data {
        if let cachedImage = cachedTrackerImages[entityName] {
            return cachedImage
        } else {
            let trackerImage = makeTrackerImage(for: entityName)
            cachedTrackerImages[entityName] = trackerImage
            return trackerImage
        }
    }
    
    private func makeTrackerImage(for entityName: String) -> Data {
        if let image = loadTrackerLogoImage(for: entityName) {
            return image
        } else if let firstLetter = entityName.first,
                  let letterImage = loadTrackerImage(for: String(firstLetter).uppercased()) {
            return letterImage
        } else {
            return blankTrackerImage
        }
    }
    
    private func loadTrackerImage(for entityName: String) -> Data? {
        return dataFromBundle(for: entityName, subdir: .letters)
    }
    
    // swiftlint:disable:next cyclomatic_complexity
    private func loadTrackerLogoImage(for entityName: String) -> Data? {
        switch entityName {
        case "Adjust GmbH": return dataFromBundle(for: "adjust", subdir: .logos)
        case "Adobe Inc.": return dataFromBundle(for: "adobe", subdir: .logos)
        case "Amazon Technologies, Inc.": return dataFromBundle(for: "amazon", subdir: .logos)
        case "Amplitude": return dataFromBundle(for: "amplitude", subdir: .logos)
        case "appnexus": return dataFromBundle(for: "appnexus", subdir: .logos)
        case "AppsFlyer": return dataFromBundle(for: "appsflyer", subdir: .logos)
        case "Beeswax": return dataFromBundle(for: "beeswax", subdir: .logos)
        case "Braze, Inc.": return dataFromBundle(for: "braze", subdir: .logos)
        case "Branch Metrics, Inc.": return dataFromBundle(for: "branchmetrics", subdir: .logos)
        case "Bugsnag Inc.": return dataFromBundle(for: "bugsnag", subdir: .logos)
        case "cloudflare": return dataFromBundle(for: "cloudflare", subdir: .logos)
        case "comScore, Inc": return dataFromBundle(for: "comscore", subdir: .logos)
        case "Criteo SA": return dataFromBundle(for: "criteo", subdir: .logos)
        case "Facebook, Inc.": return dataFromBundle(for: "facebook", subdir: .logos)
        case "Google LLC": return dataFromBundle(for: "google", subdir: .logos)
        case "Index Exchange, Inc.": return dataFromBundle(for: "indexexchange", subdir: .logos)
        case "IPONWEB GmbH": return dataFromBundle(for: "iponweb", subdir: .logos)
        case "Kochava": return dataFromBundle(for: "kochava", subdir: .logos)
        case "linkedin": return dataFromBundle(for: "linkedin", subdir: .logos)
        case "LiveRamp": return dataFromBundle(for: "liveramp", subdir: .logos)
        case "MediaMath, Inc.": return dataFromBundle(for: "mediamath", subdir: .logos)
        case "Microsoft Corporation": return dataFromBundle(for: "microsoft", subdir: .logos)
        case "Neustar, Inc.": return dataFromBundle(for: "neustar", subdir: .logos)
        case "New Relic": return dataFromBundle(for: "newrelic", subdir: .logos)
        case "OpenX Technologies Inc": return dataFromBundle(for: "openx", subdir: .logos)
        case "Oracle Corporation": return dataFromBundle(for: "oracle", subdir: .logos)
        case "Outbrain": return dataFromBundle(for: "outbrain", subdir: .logos)
        case "Pinterest, Inc.": return dataFromBundle(for: "pinterest", subdir: .logos)
        case "PubMatic, Inc.": return dataFromBundle(for: "pubmatic", subdir: .logos)
        case "Quantcast Corporation": return dataFromBundle(for: "quantcast", subdir: .logos)
        case "RythmOne": return dataFromBundle(for: "rhythmone", subdir: .logos)
        case "Salesforce.com, Inc": return dataFromBundle(for: "salesforce", subdir: .logos)
        case "Sharethrough, Inc.": return dataFromBundle(for: "sharetrough", subdir: .logos)
        case "Smaato Inc.": return dataFromBundle(for: "smaato", subdir: .logos)
        case "SpotX, Inc.": return dataFromBundle(for: "spotx", subdir: .logos)
        case "stackpath": return dataFromBundle(for: "stackpath", subdir: .logos)
        case "Taboola, Inc.": return dataFromBundle(for: "taboola", subdir: .logos)
        case "Tapad, Inc.": return dataFromBundle(for: "tapad", subdir: .logos)
        case "The Trade Desk Inc": return dataFromBundle(for: "thetradedesk", subdir: .logos)
        case "Twitter, Inc.": return dataFromBundle(for: "twitter", subdir: .logos)
        case "Urban Airship, Inc.": return dataFromBundle(for: "urbanairship", subdir: .logos)
        case "Verizon Media": return dataFromBundle(for: "verizonmedia", subdir: .logos)
        case "WarnerMedia, LLC": return dataFromBundle(for: "warnermedia", subdir: .logos)
        case "Xaxis": return dataFromBundle(for: "xaxis", subdir: .logos)
        case "Yandex LLC": return dataFromBundle(for: "yandex", subdir: .logos)
        case "Zeotap GmbH": return dataFromBundle(for: "zeotap", subdir: .logos)
        default: return nil
        }
    }
    
}
