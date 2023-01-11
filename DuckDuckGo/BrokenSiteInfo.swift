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
import PrivacyDashboard

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
        static let ampUrl = "ampUrl"
        static let urlParametersRemoved = "urlParametersRemoved"
        static let consentManaged = "consentManaged"
        static let consentOptoutFailed = "consentOptoutFailed"
        static let consentSelftestFailed = "consentSelftestFailed"
    }
    
    private let url: URL?
    private let httpsUpgrade: Bool
    private let blockedTrackerDomains: [String]
    private let installedSurrogates: [String]
    private let isDesktop: Bool
    private let tdsETag: String?
    private let ampUrl: String?
    private let urlParametersRemoved: Bool
    private let model: String
    private let manufacturer: String
    private let systemVersion: String
    private let gpc: Bool
    
    private let consentManaged: Bool?
    private let consentOptoutFailed: Bool?
    private let consentSelftestFailed: Bool?
    
    public init(url: URL?, httpsUpgrade: Bool,
                blockedTrackerDomains: [String], installedSurrogates: [String],
                isDesktop: Bool, tdsETag: String?,
                ampUrl: String?,
                urlParametersRemoved: Bool,
                model: String = UIDevice.current.model,
                manufacturer: String = "Apple",
                systemVersion: String = UIDevice.current.systemVersion,
                gpc: Bool? = nil,
                cookieConsentInfo: CookieConsentInfo?) {
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
        
        if let gpcParam = gpc {
            self.gpc = gpcParam
        } else {
            self.gpc = AppDependencyProvider.shared.appSettings.sendDoNotSell
        }
        
        self.consentManaged = cookieConsentInfo?.consentManaged
        self.consentOptoutFailed = cookieConsentInfo?.optoutFailed
        self.consentSelftestFailed = cookieConsentInfo?.selftestFailed
    }
    
    func send(with category: String) {
        
        var parameters = [Keys.url: normalize(url),
                          Keys.category: category,
                          Keys.upgradedHttps: httpsUpgrade ? "true" : "false",
                          Keys.siteType: isDesktop ? "desktop" : "mobile",
                          Keys.tds: tdsETag?.trimmingCharacters(in: CharacterSet(charactersIn: "\"")) ?? "",
                          Keys.blockedTrackers: blockedTrackerDomains.joined(separator: ","),
                          Keys.surrogates: installedSurrogates.joined(separator: ","),
                          Keys.atb: StatisticsUserDefaults().atb ?? "",
                          Keys.os: systemVersion,
                          Keys.manufacturer: manufacturer,
                          Keys.model: model,
                          Keys.gpc: gpc ? "true" : "false",
                          Keys.ampUrl: ampUrl ?? "",
                          Keys.urlParametersRemoved: urlParametersRemoved ? "true" : "false"]

        parameters.merge(makeCookieConsentParameters(), uniquingKeysWith: { (_, new) in new })
        
        Pixel.fire(pixel: .brokenSiteReport, withAdditionalParameters: parameters)
    }
    
    private func normalize(_ url: URL?) -> String {
        return url?.normalized()?.absoluteString ?? ""
    }

    private func makeCookieConsentParameters() -> [String: String] {
        var cookieConsentParameters: [String: String] = [:]
        
        if let consentManaged = consentManaged {
            cookieConsentParameters[Keys.consentManaged] = consentManaged ? "true" : "false"
            
            if let consentOptoutFailed = consentOptoutFailed {
                cookieConsentParameters[Keys.consentOptoutFailed] = consentOptoutFailed ? "true" : "false"
            }
            if let consentSelftestFailed = consentSelftestFailed {
                cookieConsentParameters[Keys.consentSelftestFailed] = consentSelftestFailed ? "true" : "false"
            }
        }
        
        return cookieConsentParameters
    }
}
