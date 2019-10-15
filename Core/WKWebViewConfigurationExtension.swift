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

    public static var ddgNameForUserAgent: String {
        return "DuckDuckGo/\(AppVersion.shared.majorVersionNumber)"
    }
    
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

        let defaultNameForUserAgent = configuration.applicationNameForUserAgent ?? ""
        configuration.applicationNameForUserAgent = "\(defaultNameForUserAgent) \(WKWebViewConfiguration.ddgNameForUserAgent)"
        configuration.allowsAirPlayForMediaPlayback = true
        configuration.allowsInlineMediaPlayback = true
        configuration.allowsPictureInPictureMediaPlayback = true
        configuration.ignoresViewportScaleLimits = true

        return configuration
    }

    public func loadScripts(storageCache: StorageCache, contentBlockingEnabled: Bool) {
        Loader(contentController: userContentController,
               storageCache: storageCache,
               injectContentBlockingScripts: contentBlockingEnabled).load()
    }

}

private class Loader {

    struct CacheNames {

        static let surrogateJson = "surrogateJson"

    }
    
    let cache = ContentBlockerStringCache()
    let javascriptLoader = JavascriptLoader()
    let storageCache: StorageCache

    let userContentController: WKUserContentController
    let injectContentBlockingScripts: Bool

    init(contentController: WKUserContentController, storageCache: StorageCache, injectContentBlockingScripts: Bool) {
        self.storageCache = storageCache
        self.userContentController = contentController
        self.injectContentBlockingScripts = injectContentBlockingScripts
    }

    func load() {
        Logger.log(text: "Loading scripts")
        loadDocumentLevelScripts()

        if injectContentBlockingScripts {
            loadContentBlockingScripts()
        }
    }

    private func loadDocumentLevelScripts() {
        if #available(iOS 13, *) {
            load(scripts: [ .findinpage ] )
        } else {
            load(scripts: [ .document, .findinpage ] )
        }
    }

    private func loadContentBlockingScripts() {
        loadContentBlockerDependencyScripts()
        loadBlockerData()
        load(scripts: [ .disconnectme, .contentblocker ], forMainFrameOnly: false)
        load(scripts: [ .detection ], forMainFrameOnly: false)
    }

    private func loadContentBlockerDependencyScripts() {
        let tlds = storageCache.tld

        if #available(iOS 10, *) {
            load(scripts: [ .messaging, .apbfilter], forMainFrameOnly: false)
        } else {
            load(scripts: [ .messaging, .apbfilterES2015 ], forMainFrameOnly: false)
        }
        
        if isDebugBuild {
            javascriptLoader.load(script: .debugMessagingEnabled,
                                  into: userContentController,
                                  forMainFrameOnly: false)
        } else {
            javascriptLoader.load(script: .debugMessagingDisabled,
                                  into: userContentController,
                                  forMainFrameOnly: false)
        }

        javascriptLoader.load(script: .tlds, withReplacements: [ "${tlds}": tlds.json ], into: userContentController, forMainFrameOnly: false)
    }

    private func loadBlockerData() {

        let surrogates = loadSurrogateJson(storageCache.surrogateStore)
        let blockingEnabled = storageCache.configuration.enabled
        let whitelist = storageCache.configuration.domainWhitelist.toJsonLookupString()
        let disconnectMeStore = storageCache.disconnectMeStore

        javascriptLoader.load(script: .blockerData, withReplacements: [
            "${blocking_enabled}": "\(blockingEnabled)",
            "${disconnectmeBanned}": disconnectMeStore.bannedTrackersJson,
            "${disconnectmeAllowed}": disconnectMeStore.allowedTrackersJson,
            "${whitelist}": whitelist,
            "${surrogates}": surrogates
            ],
                              into: userContentController,
                              forMainFrameOnly: false)

        loadEasylist()

    }

    private func loadSurrogateJson(_ store: SurrogateStore) -> String {
        if let surrogateJson = cache.get(named: CacheNames.surrogateJson) {
            Logger.log(text: "Using cached surrogate json")
            return surrogateJson
        }

        guard let functions = store.jsFunctions else { return "{}" }
        let functionUris = functions.mapValues({ "data:application/javascript;base64,\($0.toBase64())" })
        guard let jsonData = try? JSONEncoder().encode(functionUris) else { return "{}" }
        guard let surrogateJson = String(data: jsonData, encoding: .utf8) else { return "{}" }
        cache.put(name: CacheNames.surrogateJson, value: surrogateJson)
        Logger.log(text: "Caching surrogate json")
        return surrogateJson
    }

    fileprivate func injectCompiledEasylist(_ cachedEasylistWhitelist: String) {
        Logger.log(text: "using cached easylist")

        if #available(iOS 10, *) {
            javascriptLoader.load(.bloom, into: userContentController, forMainFrameOnly: false)
        } else {
            javascriptLoader.load(.bloomES2015, into: userContentController, forMainFrameOnly: false)
        }

        javascriptLoader.load(script: .cachedEasylist, withReplacements: [
            "${easylist_privacy_json}": "{}",
            "${easylist_general_json}": "{}",
            "${easylist_whitelist_json}": cachedEasylistWhitelist ],
                              into: userContentController,
                              forMainFrameOnly: false)
    }

    fileprivate func injectRawEasylist(_ easylistWhitelist: String) {
        Logger.log(text: "parsing easylist")

        javascriptLoader.load(script: .easylistParsing, withReplacements: [
            "${easylist_privacy}": "",
            "${easylist_general}": "",
            "${easylist_whitelist}": easylistWhitelist ],
                              into: userContentController,
                              forMainFrameOnly: false)

    }

    private func loadEasylist() {
        
        if let cachedEasylistWhitelist = cache.get(named: EasylistStore.CacheNames.easylistWhitelist) {
            injectCompiledEasylist(cachedEasylistWhitelist)
            return
        }
        
        let easylistStore = storageCache.easylistStore

        if let easylistWhitelist = easylistStore.easylistWhitelist {
            injectRawEasylist(easylistWhitelist)
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
