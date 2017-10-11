//
//  WKWebViewConfigurationExtension.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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


import WebKit

extension WKWebViewConfiguration {
    
    public static func persistent() -> WKWebViewConfiguration {
        return configuration(persistsData: true)
    }
    
    public static func nonPersistent() -> WKWebViewConfiguration {
        return configuration(persistsData: false)
    }
    
    private static func configuration(persistsData: Bool) -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        if !persistsData {
            configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        }
        if #available(iOSApplicationExtension 10.0, *) {
            configuration.dataDetectorTypes = [.link, .phoneNumber]
        }
        configuration.loadScripts()
        return configuration
    }
    
    public func loadScripts() {
        loadDocumentLevelScripts()
        
        loadLegacyContentBlockerScripts()
    }
    
    private func loadDocumentLevelScripts() {
        load(scripts: [ .document, .favicon ])
    }
    
    private func loadLegacyContentBlockerScripts() {
        let configuration = ContentBlockerConfigurationUserDefaults()
        let whitelist = configuration.domainWhitelist.toJsonLookupString()
        loadLegacyContentBlockerDependencyScripts()
        loadBlockerData(with: whitelist, and:  configuration.enabled)
        load(scripts: [ .disconnectme, .contentblocker ], forMainFrameOnly: false)
    }
    
    private func loadLegacyContentBlockerDependencyScripts() {
        load(scripts: [ .messaging, .apbfilter, .tlds ], forMainFrameOnly: false)
    }
    
    private func loadBlockerData(with whitelist: String, and blockingEnabled: Bool) {
        let easylistStore = EasylistStore()

        let javascriptLoader = JavascriptLoader()
        
        javascriptLoader.load(script: .blockerData, withReplacements: [
            "${blocking_enabled}": "\(blockingEnabled)",
            "${disconnectmeBanned}": DisconnectMeStore.shared.bannedTrackersJson,
            "${disconnectmeAllowed}": DisconnectMeStore.shared.allowedTrackersJson,
            "${whitelist}": whitelist ],
                              andController:userContentController,
                              forMainFrameOnly: false)
        
        let cache = ContentBlockerStringCache()
        if let cachedEasylist = cache.get(named: EasylistStore.CacheNames.easylist), let cachedEasylistPrivacy = cache.get(named: EasylistStore.CacheNames.easylistPrivacy) {
            
            Logger.log(text: "using cached easylist")
            
            javascriptLoader.load(.bloom, withController: userContentController, forMainFrameOnly: false)
            
            javascriptLoader.load(script: .cachedEasylist, withReplacements: [
                "${easylist_privacy_json}": cachedEasylistPrivacy,
                "${easylist_general_json}": cachedEasylist ],
                                  andController: userContentController,
                                  forMainFrameOnly: false)
            
        } else if let easylist = easylistStore.easylist,
            let easylistPrivacy = easylistStore.easylistPrivacy {
            
            Logger.log(text: "parsing easylist")

            javascriptLoader.load(script: .easylistParsing, withReplacements: [
                "${easylist_privacy}": easylistPrivacy,
                "${easylist_general}": easylist ],
                                  andController: userContentController,
                                  forMainFrameOnly: false)
            
        }
        
    }
    
    private func load(scripts: [JavascriptLoader.Script], forMainFrameOnly: Bool = true) {
        let javascriptLoader = JavascriptLoader()
        for script in scripts {
            javascriptLoader.load(script, withController: userContentController, forMainFrameOnly: forMainFrameOnly)
        }
    }
}

fileprivate extension Set where Element == String {
    
    func toJsonLookupString() -> String {
        return reduce("{", { (result, next) -> String in
            let separator = result != "{" ? ", " : ""
            return "\(result)\(separator) \"\(next)\" : true"
        }).appending("}")
    }
    
}
