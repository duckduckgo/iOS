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

    static let allowedQueryReservedCharacters =  CharacterSet(charactersIn: ",")

    enum Key: String {
        case siteUrl
        case category
        case description
        case upgradedHttps
        case tds
        case blockedTrackers
        case surrogates
        case atb
        case os
        case manufacturer
        case model
        case siteType
        case gpc
        case ampUrl
        case urlParametersRemoved
        case protectionsState
        case reportFlow
    }
    
    public enum Source: String {
        case menu
        case dashboard
    }
    
    public let url: URL?
    public let httpsUpgrade: Bool
    public let blockedTrackerDomains: [String]
    public let installedSurrogates: [String]
    public let isDesktop: Bool
    public let tdsETag: String?
    public let ampUrl: String?
    public let urlParametersRemoved: Bool
    public let model: String
    public let manufacturer: String
    public let systemVersion: String
    public let gpc: Bool
    public let protectionsState: Bool

    public init(url: URL?, httpsUpgrade: Bool,
                blockedTrackerDomains: [String],
                installedSurrogates: [String],
                isDesktop: Bool,
                tdsETag: String?,
                ampUrl: String?,
                urlParametersRemoved: Bool,
                protectionsState: Bool,
                model: String = UIDevice.current.model,
                manufacturer: String = "Apple",
                systemVersion: String = UIDevice.current.systemVersion,
                gpc: Bool? = nil) {
        self.url = url
        self.httpsUpgrade = httpsUpgrade
        self.blockedTrackerDomains = blockedTrackerDomains
        self.installedSurrogates = installedSurrogates
        self.isDesktop = isDesktop
        self.tdsETag = tdsETag
        self.ampUrl = ampUrl
        self.urlParametersRemoved = urlParametersRemoved

        self.model = model
        self.manufacturer = manufacturer
        self.systemVersion = systemVersion
        self.protectionsState = protectionsState

        if let gpcParam = gpc {
            self.gpc = gpcParam
        } else {
            self.gpc = AppDependencyProvider.shared.appSettings.sendDoNotSell
        }
    }
    
    func send(with category: String?, description: String, source: Source) {
        
        let parameters: [String: String] = [
            Key.siteUrl.rawValue: normalize(url),
            Key.category.rawValue: category ?? "",
            Key.description.rawValue: description,
            Key.reportFlow.rawValue: source.rawValue,
            Key.upgradedHttps.rawValue: httpsUpgrade ? "true" : "false",
            Key.siteType.rawValue: isDesktop ? "desktop" : "mobile",
            Key.tds.rawValue: tdsETag?.trimmingCharacters(in: CharacterSet(charactersIn: "\"")) ?? "",
            Key.blockedTrackers.rawValue: blockedTrackerDomains.joined(separator: ","),
            Key.surrogates.rawValue: installedSurrogates.joined(separator: ","),
            Key.atb.rawValue: StatisticsUserDefaults().atb ?? "",
            Key.os.rawValue: systemVersion,
            Key.manufacturer.rawValue: manufacturer,
            Key.model.rawValue: model,
            Key.gpc.rawValue: gpc ? "true" : "false",
            Key.ampUrl.rawValue: ampUrl ?? "",
            Key.urlParametersRemoved.rawValue: urlParametersRemoved ? "true" : "false",
            Key.protectionsState.rawValue: protectionsState ? "true" : "false"
        ]
        
        Pixel.fire(pixel: .brokenSiteReport,
                   withAdditionalParameters: parameters,
                   allowedQueryReservedCharacters: BrokenSiteInfo.allowedQueryReservedCharacters)
    }
    
    private func normalize(_ url: URL?) -> String {
        return url?.normalized()?.absoluteString ?? ""
    }

}
