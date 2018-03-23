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
        
        configuration.allowsAirPlayForMediaPlayback = true
        configuration.allowsInlineMediaPlayback = true
        configuration.allowsPictureInPictureMediaPlayback = true
        return configuration
    }
    
    public func loadScripts(with id: String, restrictedDevice: Bool, contentBlocking: Bool) {
        Loader(id, userContentController, restrictedDevice, contentBlocking).load()
    }
    
}

fileprivate class Loader {
    
    // TODO Need to refactor so that that easylist and disconnect use the cache here instead of in their loader/parsers
    // https://app.asana.com/0/414709148257752/543604604366287
    struct CacheNames {
        
        static let surrogateJson = "surrogateJson"
        
    }
    
    let tlds = TLD()
    let cache = ContentBlockerStringCache()
    let javascriptLoader = JavascriptLoader()
    
    let id: String
    let userContentController: WKUserContentController
    let restrictedDevice: Bool
    let contentBlocking: Bool
    
    init(_ id: String, _ userContentController: WKUserContentController, _ restrictedDevice: Bool, _ contentBlocking: Bool) {
        self.id = id
        self.userContentController = userContentController
        self.restrictedDevice = restrictedDevice
        self.contentBlocking = contentBlocking
    }
    
    func load() {
        Logger.log(text: "Loading scripts")
        loadDocumentLevelScripts()
        
        if contentBlocking {
            loadContentBlockingScripts()
        }
    }
    
    private func loadDocumentLevelScripts() {
        load(scripts: [ .document, .favicon ] )
    }
    
    private func loadContentBlockingScripts() {
        let configuration = ContentBlockerConfigurationUserDefaults()
        let whitelist = configuration.domainWhitelist.toJsonLookupString()
        loadContentBlockerDependencyScripts()
        loadBlockerData(with: whitelist, and:  configuration.enabled, with: id)
        load(scripts: [ .disconnectme, .contentblocker ], forMainFrameOnly: false)
        load(scripts: [ .detection ], forMainFrameOnly: false)
    }

    private func loadContentBlockerDependencyScripts() {

        if #available(iOS 10, *) {
            load(scripts: [ .messaging, .apbfilter], forMainFrameOnly: false)
        } else {
            load(scripts: [ .messaging, .apbfilterES2015 ], forMainFrameOnly: false)
        }
        
        javascriptLoader.load(script: .tlds, withReplacements: [ "${tlds}" : tlds.json ], into: userContentController, forMainFrameOnly: false)
    }
    
    private func loadBlockerData(with whitelist: String, and blockingEnabled: Bool, with id: String) {
        
        let surrogates = loadSurrogateJson()
        let disconnectMeStore = DisconnectMeStore()
        
        javascriptLoader.load(script: .blockerData, withReplacements: [
            "${protectionId}": id,
            "${blocking_enabled}": "\(blockingEnabled)",
            "${disconnectmeBanned}": disconnectMeStore.bannedTrackersJson,
            "${disconnectmeAllowed}": disconnectMeStore.allowedTrackersJson,
            "${whitelist}": whitelist,
            "${surrogates}": surrogates
            ],
                              into:userContentController,
                              forMainFrameOnly: false)
        
        loadEasylist()
    
    }
    
    private func loadSurrogateJson() -> String {
        if let surrogateJson = cache.get(named: CacheNames.surrogateJson) {
            Logger.log(text: "Using cached surrogate json")
            return surrogateJson
        }
        
        let store = SurrogateStore()
        guard let functions = store.jsFunctions else { return "{}" }
        let functionUris = functions.mapValues({ "data:application/javascript;base64,\($0.toBase64())" })
        guard let jsonData = try? JSONEncoder().encode(functionUris) else { return "{}" }
        guard let surrogateJson = String(data: jsonData, encoding: .utf8) else { return "{}" }
        cache.put(name: CacheNames.surrogateJson, value: surrogateJson)
        Logger.log(text: "Caching surrogate json")
        return surrogateJson
    }
    
    fileprivate func injectCompiledEasylist(_ cachedEasylistPrivacy: String, _ cachedEasylist: String, _ cachedEasylistWhitelist: String) {
        Logger.log(text: "using cached easylist")
        
        if #available(iOS 10, *) {
            javascriptLoader.load(.bloom, into: userContentController, forMainFrameOnly: false)
        } else {
            javascriptLoader.load(.bloomES2015, into: userContentController, forMainFrameOnly: false)
        }
        
        javascriptLoader.load(script: .cachedEasylist, withReplacements: [
            "${easylist_privacy_json}": cachedEasylistPrivacy,
            "${easylist_general_json}": cachedEasylist,
            "${easylist_whitelist_json}": cachedEasylistWhitelist ],
                              into: userContentController,
                              forMainFrameOnly: false)
    }
    
    fileprivate func injectRawEasylist(_ easylistPrivacy: String, _ easylist: String, _ easylistWhitelist: String) {
        Logger.log(text: "parsing easylist")
        
        javascriptLoader.load(script: .easylistParsing, withReplacements: [
            "${easylist_privacy}": restrictedDevice ? "" : easylistPrivacy,
            "${easylist_general}": restrictedDevice ? "" : easylist,
            "${easylist_whitelist}": easylistWhitelist ],
                              into: userContentController,
                              forMainFrameOnly: false)
        
    }
    
    private func loadEasylist() {
        
        if let cachedEasylist = cache.get(named: EasylistStore.CacheNames.easylist),
            let cachedEasylistPrivacy = cache.get(named: EasylistStore.CacheNames.easylistPrivacy),
            let cachedEasylistWhitelist = cache.get(named: EasylistStore.CacheNames.easylistWhitelist) {

            injectCompiledEasylist(cachedEasylistPrivacy, cachedEasylist, cachedEasylistWhitelist)

            return
        }
        
        let easylistStore = EasylistStore()
        
        if let easylist = easylistStore.easylist,
            let easylistPrivacy = easylistStore.easylistPrivacy,
            let easylistWhitelist = easylistStore.easylistWhitelist {
            
            injectRawEasylist(easylistPrivacy, easylist, easylistWhitelist)
            
        }
    }
    
    private func load(scripts: [JavascriptLoader.Script], forMainFrameOnly: Bool = true) {
        for script in scripts {
            javascriptLoader.load(script, into: userContentController, forMainFrameOnly: forMainFrameOnly)
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

fileprivate extension String {
    
    func toBase64() -> String {
        guard let data = self.data(using: String.Encoding.utf8) else {
            return ""
        }
        return data.base64EncodedString()
    }
    
}


