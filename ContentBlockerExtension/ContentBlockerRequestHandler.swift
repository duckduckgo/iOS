//
//  ContentBlockerRequestHandler.swift
//  ContentBlockerExtension
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


import UIKit
import MobileCoreServices
import Core

// This component was disabled however will be reenabled again soon
// after release.
//
// If reenabling consider adding whitelist support and whitelisting:
//   - any url in the ContentBlockerConfigurationStore whitelist. Be careful 
//     here, we're not talking about the tracker being on the whitellist but
//     the page the tracker is on e.g facebook might be on the whiletlist so
//     we wouldn't block any trackers while on facebook.
//   - third party trackers whose tracker.parent matches the current url. For
//     example abs-0.twimg.com is a third-party url when on twitter.com however
//     we KNOW from the disconnect list that its parent is twitter so want to
//     treat it as a first-party url and not block it when on twitter.
//
class ContentBlockerRequestHandler: NSObject, NSExtensionRequestHandling {
    
    private lazy var parser = AppleContentBlockerParser()
    
    enum ContentBlockerError: Error {
        case noData
    }
    
    func beginRequest(with context: NSExtensionContext) {
        
        TrackerLoader.shared.updateTrackers { (trackers, error) in
            
            guard let trackers = trackers ?? TrackerLoader.shared.storedTrackers else {
                let error = error ?? ContentBlockerError.noData
                Logger.log(items: "Could not load content blocker", error)
                context.cancelRequest(withError: error)
                return
            }
            
            do {
                let data = try self.parser.toJsonData(trackers: trackers) as NSSecureCoding
                let attachment = NSItemProvider(item: data, typeIdentifier: kUTTypeJSON as String)
                let item = NSExtensionItem()
                item.attachments = [attachment]
                context.completeRequest(returningItems: [item], completionHandler: nil)
            } catch {
                Logger.log(items: "Could not load content blocker", error)
                context.cancelRequest(withError: ContentBlockerError.noData)
            }

        }
    }
}
