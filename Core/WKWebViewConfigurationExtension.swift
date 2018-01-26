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
        return configuration
    }
    
    public func loadScripts(with id: String, restrictedDevice: Bool) {
        Loader(id, userContentController, restrictedDevice).load()
    }
    
}

fileprivate class Loader {
    
    let javascriptLoader = JavascriptLoader()
    
    let id: String
    let userContentController: WKUserContentController
    let restrictedDevice: Bool

    init(_ id: String, _ userContentController: WKUserContentController, _ restrictedDevice: Bool) {
        self.id = id
        self.userContentController = userContentController
        self.restrictedDevice = restrictedDevice
    }
    
    func load() {
        loadDocumentLevelScripts()
        loadSiteMonitoringScripts()
    }
    
    private func loadDocumentLevelScripts() {
        load(scripts: [ .document, .favicon ] )
    }
    
    private func loadSiteMonitoringScripts() {
        let configuration = ContentBlockerConfigurationUserDefaults()
        let whitelist = configuration.domainWhitelist.toJsonLookupString()
        loadContentBlockerDependencyScripts()
        loadBlockerData(with: whitelist, and:  configuration.enabled, with: id)
        load(scripts: [ .disconnectme, .contentblocker ], forMainFrameOnly: false)
    }

    private func loadContentBlockerDependencyScripts() {

        if #available(iOS 10, *) {
            load(scripts: [ .messaging, .apbfilter, .tlds ], forMainFrameOnly: false)
        } else {
            load(scripts: [ .messaging, .apbfilterES2015, .tlds ], forMainFrameOnly: false)
        }
    }
    
    private func loadBlockerData(with whitelist: String, and blockingEnabled: Bool, with id: String) {
        let disconnectMeStore = DisconnectMeStore()
        
        javascriptLoader.load(script: .blockerData, withReplacements: [
            "${protectionId}": id,
            "${blocking_enabled}": "\(blockingEnabled)",
            "${disconnectmeBanned}": disconnectMeStore.bannedTrackersJson,
            "${disconnectmeAllowed}": disconnectMeStore.allowedTrackersJson,
            "${whitelist}": whitelist ],
                              andController:userContentController,
                              forMainFrameOnly: false)
        
        loadEasylist()
    
    }
    
    fileprivate func injectCompiledEasylist(_ cachedEasylistPrivacy: String, _ cachedEasylist: String, _ cachedEasylistWhitelist: String) {
        Logger.log(text: "using cached easylist")
        
        if #available(iOS 10, *) {
            javascriptLoader.load(.bloom, withController: userContentController, forMainFrameOnly: false)
        } else {
            javascriptLoader.load(.bloomES2015, withController: userContentController, forMainFrameOnly: false)
        }
        
        javascriptLoader.load(script: .cachedEasylist, withReplacements: [
            "${easylist_privacy_json}": cachedEasylistPrivacy,
            "${easylist_general_json}": cachedEasylist,
            "${easylist_whitelist_json}": cachedEasylistWhitelist ],
                              andController: userContentController,
                              forMainFrameOnly: false)
    }
    
    fileprivate func injectRawEasylist(_ easylistPrivacy: String, _ easylist: String, _ easylistWhitelist: String) {
        Logger.log(text: "parsing easylist")
        
        javascriptLoader.load(script: .easylistParsing, withReplacements: [
            "${easylist_privacy}": restrictedDevice ? "" : easylistPrivacy,
            "${easylist_general}": restrictedDevice ? "" : easylist,
            "${easylist_whitelist}": easylistWhitelist ],
                              andController: userContentController,
                              forMainFrameOnly: false)
        
    }
    
    private func loadEasylist() {
        let easylistStore = EasylistStore()
        let cache = ContentBlockerStringCache()
        
        if let cachedEasylist = cache.get(named: EasylistStore.CacheNames.easylist),
            let cachedEasylistPrivacy = cache.get(named: EasylistStore.CacheNames.easylistPrivacy),
            let cachedEasylistWhitelist = cache.get(named: EasylistStore.CacheNames.easylistWhitelist) {
            
            injectCompiledEasylist(cachedEasylistPrivacy, cachedEasylist, cachedEasylistWhitelist)
            
        } else if let easylist = easylistStore.easylist,
            let easylistPrivacy = easylistStore.easylistPrivacy,
            let easylistWhitelist = easylistStore.easylistWhitelist {
            
            injectRawEasylist(easylistPrivacy, easylist, easylistWhitelist)
            
        }
    }
    
    private func load(scripts: [JavascriptLoader.Script], forMainFrameOnly: Bool = true) {
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


