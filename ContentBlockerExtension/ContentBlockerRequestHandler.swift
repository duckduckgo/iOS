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

class ContentBlockerRequestHandler: NSObject, NSExtensionRequestHandling {
    
    private lazy var contentBlocker = ContentBlocker()
    private lazy var parser = AppleContentBlockerParser()
    
    enum ContentBlockerError: Error {
        case noData
    }
    
    func beginRequest(with context: NSExtensionContext) {
        let entries = contentBlocker.blockedEntries
        do {
            let data = try parser.toJsonData(entries: entries) as NSSecureCoding
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
