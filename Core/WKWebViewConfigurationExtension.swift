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

        if #available(iOS 11, *) {
            configuration.installHideAtbModals()
        }

        let defaultNameForUserAgent = configuration.applicationNameForUserAgent ?? ""
        configuration.applicationNameForUserAgent = "\(defaultNameForUserAgent) \(WKWebViewConfiguration.ddgNameForUserAgent)"
        configuration.allowsAirPlayForMediaPlayback = true
        configuration.allowsInlineMediaPlayback = true
        configuration.allowsPictureInPictureMediaPlayback = true
        configuration.ignoresViewportScaleLimits = true

        return configuration
    }

    @available(iOS 11, *)
    private func installHideAtbModals() {
        guard let store = WKContentRuleListStore.default() else { return }
        let rules = """
        [
          {
            "trigger": {
              "url-filter": ".*",
              "if-domain": ["*duckduckgo.com"]
            },
            "action": {
              "type": "css-display-none",
              "selector": ".ddg-extension-hide"
            }
          }
        ]
        """
        store.compileContentRuleList(forIdentifier: "hide-extension-css", encodedContentRuleList: rules) { rulesList, _ in
            guard let rulesList = rulesList else { return }
            self.userContentController.add(rulesList)
        }
    }

    public func loadScripts(storageCache: StorageCache, contentBlockingEnabled: Bool) {
        Loader(contentController: userContentController,
               storageCache: storageCache,
               injectContentBlockingScripts: contentBlockingEnabled).load()
    }

}

private struct Loader {

    struct CacheNames {

        static let surrogateJson = "surrogateJson"

    }
    
    let cache = ContentBlockerStringCache()
    let javascriptLoader = JavascriptLoader()

    let userContentController: WKUserContentController
    let injectContentBlockingScripts: Bool
    
    let whitelist: String
    let surrogates: String
    let trackerData: String

    init(contentController: WKUserContentController, storageCache: StorageCache, injectContentBlockingScripts: Bool) {
        self.userContentController = contentController
        self.injectContentBlockingScripts = injectContentBlockingScripts
        
        self.whitelist = (WhitelistManager().domains?.joined(separator: "\n") ?? "")
            + "\n"
            + (storageCache.fileStore.loadAsString(forConfiguration: .temporaryWhitelist) ?? "")
        self.surrogates = storageCache.fileStore.loadAsString(forConfiguration: .surrogates) ?? ""

        // Encode whatever the tracker data manager is using to ensure it's in sync and because we know it will work
        let encodedTrackerData = try? JSONEncoder().encode(TrackerDataManager.shared.trackerData)
        self.trackerData = String(data: encodedTrackerData!, encoding: .utf8)!
    }

    func load() {
        let spid = Instruments.shared.startTimedEvent(.injectScripts)
        loadDocumentLevelScripts()

        if injectContentBlockingScripts {
            loadContentBlockingScripts()
        }
        
        Instruments.shared.endTimedEvent(for: spid)
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
        javascriptLoader.load(script: .contentblocker, withReplacements: [
            "${whitelist}": whitelist,
            "${trackerData}": trackerData,
            "${surrogates}": surrogates
        ], into: userContentController, forMainFrameOnly: false)
        load(scripts: [ .detection ], forMainFrameOnly: false)
    }

    private func loadContentBlockerDependencyScripts() {
        load(scripts: [ .messaging ], forMainFrameOnly: false)

        if isDebugBuild {
            javascriptLoader.load(script: .debugMessagingEnabled,
                                  into: userContentController,
                                  forMainFrameOnly: false)
        } else {
            javascriptLoader.load(script: .debugMessagingDisabled,
                                  into: userContentController,
                                  forMainFrameOnly: false)
        }
    }

    private func load(scripts: [JavascriptLoader.Script], forMainFrameOnly: Bool = true) {
        for script in scripts {
            javascriptLoader.load(script, into: userContentController, forMainFrameOnly: forMainFrameOnly)
        }
    }

}
