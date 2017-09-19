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
    
    public func loadScripts() {
        loadDocumentLevelScripts()
        loadContentBlockerDependencyScripts()
        loadBlockerData()
        loadContentBlockerScripts()
    }

    private func loadContentBlockerScripts() {
        load(scripts: [ .disconnectme, .contentblocker ], forMainFrameOnly: false)
    }

    private func loadContentBlockerDependencyScripts() {
        load(scripts: [ .apbfilter ], forMainFrameOnly: false)
    }

    private func loadDocumentLevelScripts() {
        load(scripts: [ .document, .favicon ])
    }

    private func loadBlockerData() {
        loadBlockerJS(file: "blockerdata", replaceVar: "${disconnectme}", withValue: DisconnectMeStore.shared.bannedTrackersJson)
        loadBlockerJS(file: "easylist", replaceVar: "${easylist}", withValue: EasylistStore.shared.easylist)
        loadBlockerJS(file: "easylistprivacy", replaceVar: "${easylist_privacy}", withValue: EasylistStore.shared.easylistPrivacy)
    }

    private func loadBlockerJS(file: String, replaceVar: String, withValue value: String) {

        let contents = try! String(contentsOfFile: JavascriptLoader.path(for: file))
        let js = contents.replacingOccurrences(of: replaceVar, with: value)
        let script = WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        configuration.userContentController.addUserScript(script)

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
