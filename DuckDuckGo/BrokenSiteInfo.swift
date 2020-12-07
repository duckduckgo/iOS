//
//  BrokenSiteInfo.swift
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

public struct BrokenSiteInfo {
    
    private struct Keys {
        static let url = "siteUrl"
        static let category = "category"
        static let upgradedHttps = "upgradedHttps"
        static let tds = "tds"
        static let blockedTrackers = "blockedTrackers"
        static let surrogates = "surrogates"
        static let atb = "atb"
        static let os = "os"
        static let manufacturer = "manufacturer"
        static let model = "model"
        static let siteType = "siteType"
        static let gpc = "gpc"
    }
    
    private let url: URL?
    private let httpsUpgrade: Bool
    private let blockedTrackerDomains: [String]
    private let installedSurrogates: [String]
    private let isDesktop: Bool
    private let tdsETag: String?
    
    public init(url: URL?, httpsUpgrade: Bool, blockedTrackerDomains: [String], installedSurrogates: [String], isDesktop: Bool, tdsETag: String?) {
        self.url = url
        self.httpsUpgrade = httpsUpgrade
        self.blockedTrackerDomains = blockedTrackerDomains
        self.installedSurrogates = installedSurrogates
        self.isDesktop = isDesktop
        self.tdsETag = tdsETag
    }
    
    func send(with category: String) {
        
        let parameters = [Keys.url: normalize(url),
                          Keys.category: category,
                          Keys.upgradedHttps: httpsUpgrade ? "true" : "false",
                          Keys.siteType: isDesktop ? "desktop" : "mobile",
                          Keys.tds: tdsETag?.trimmingCharacters(in: CharacterSet(charactersIn: "\"")) ?? "",
                          Keys.blockedTrackers: blockedTrackerDomains.joined(separator: ","),
                          Keys.surrogates: installedSurrogates.joined(separator: ","),
                          Keys.atb: StatisticsUserDefaults().atb ?? "",
                          Keys.os: UIDevice.current.systemVersion,
                          Keys.manufacturer: "Apple",
                          Keys.model: UIDevice.current.model,
                          Keys.gpc: AppDependencyProvider.shared.appSettings.sendDoNotSell ? "true" : "false"]
        
        Pixel.fire(pixel: .brokenSiteReport, withAdditionalParameters: parameters)
    }
    
    private func normalize(_ url: URL?) -> String {
        guard let url = url else { return "" }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.queryItems = nil
        
        guard let nomalizedUrl = components?.url else { return "" }
        return nomalizedUrl.absoluteString
    }
    
}
