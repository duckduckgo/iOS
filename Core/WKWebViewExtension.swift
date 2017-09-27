//
//  WKWebView.swift
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

extension WKWebView {

    public static func createWebView(frame: CGRect, persistsData: Bool) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        if !persistsData {
            configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        }
        if #available(iOSApplicationExtension 10.0, *) {
            configuration.dataDetectorTypes = [.link, .phoneNumber]
        }
        let webView = WKWebView(frame: frame, configuration: configuration)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return webView
    }
    
    public func loadScripts(contentBlocker: ContentBlockerConfigurationStore) {
        loadDocumentLevelScripts()
        loadContentBlockerScripts(with: contentBlocker.domainWhitelist, and: contentBlocker.enabled)
    }

    private func loadContentBlockerScripts(with whitelistedDomains: Set<String>, and blockingEnabled: Bool) {
        loadContentBlockerDependencyScripts()
        loadBlockerData(with: whitelistedDomains.toJsonLookupString(), and: blockingEnabled)
        load(scripts: [ .disconnectme, .contentblocker ], forMainFrameOnly: false)
    }

    private func loadContentBlockerDependencyScripts() {
        load(scripts: [ .messaging, .apbfilter, .tlds ], forMainFrameOnly: false)
    }

    private func loadDocumentLevelScripts() {
        load(scripts: [ .document, .favicon ])
    }

    private func loadBlockerData(with whitelist: String, and blockingEnabled: Bool) {

        let javascriptLoader = JavascriptLoader()

        javascriptLoader.load(script: .blockerData, withReplacements: [
            "${blocking_enabled}": "\(blockingEnabled)",
            "${disconnectme}": DisconnectMeStore.shared.bannedTrackersJson,
            "${whitelist}": whitelist ],
             andController:configuration.userContentController,
             forMainFrameOnly: false)

        let cache = ContentBlockerStringCache()
        if let cachedEasylist = cache.get(named: EasylistStore.CacheNames.easylist), let cachedEasylistPrivacy = cache.get(named: EasylistStore.CacheNames.easylistPrivacy) {

            Logger.log(text: "using cached easylist")

            javascriptLoader.load(.bloom, withController: configuration.userContentController, forMainFrameOnly: false)

            javascriptLoader.load(script: .cachedEasylist, withReplacements: [
                "${easylist_privacy_json}": cachedEasylistPrivacy,
                "${easylist_general_json}": cachedEasylist ],
                andController: configuration.userContentController,
                forMainFrameOnly: false)

        } else {

            Logger.log(text: "parsing easylist")

            let easylistStore = EasylistStore()

            javascriptLoader.load(script: .easylistParsing, withReplacements: [
                "${easylist_privacy}": easylistStore.easylistPrivacy,
                "${easylist_general}": easylistStore.easylist ],
                andController: configuration.userContentController,
                forMainFrameOnly: false)

        }

    }

    private func load(scripts: [JavascriptLoader.Script], forMainFrameOnly: Bool = true) {
        let javascriptLoader = JavascriptLoader()
        for script in scripts {
            javascriptLoader.load(script, withController: configuration.userContentController, forMainFrameOnly: forMainFrameOnly)
        }
    }
    
    public func getUrlAtPoint(x: Int, y: Int, completion: @escaping (URL?) -> Swift.Void) {
        let javascript = "duckduckgoDocument.getHrefFromPoint(\(x), \(y))"
        evaluateJavaScript(javascript) { (result, error) in
            if let text = result as? String {
                let url = URL(string: text)
                completion(url)
            } else {
                completion(nil)
            }
        }
    }
    
    public func getUrlAtPointSynchronously(x: Int, y: Int) -> URL? {
        var complete = false
        var url: URL?
        let javascript = "duckduckgoDocument.getHrefFromPoint(\(x), \(y))"
        evaluateJavaScript(javascript) { (result, error) in
            if let text = result as? String {
                url = URL(string: text)
            }
            complete = true
        }
        
        while (!complete) {
            RunLoop.current.run(mode: .defaultRunLoopMode, before: .distantFuture)
        }
        return url
    }
    
    public func getFavicon(completion: @escaping (URL?) -> Swift.Void) {
        let javascript = "duckduckgoFavicon.getFavicon()"
        evaluateJavaScript(javascript) { (result, error) in
            guard let urlString = result as? String else { completion(nil); return }
            guard let url = URL(string: urlString) else { completion(nil); return }
            completion(url)
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


