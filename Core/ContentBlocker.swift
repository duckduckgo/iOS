//
//  ContentBlocker.swift
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


import Foundation

public class ContentBlocker {
    
    private struct FileConstants {
        static let name = "disconnectmetrackers"
        static let ext = "json"
    }
    
    private let configuration = ContentBlockerConfigurationUserDefaults()
    private let parser = DisconnectMeContentBlockerParser()
    private var categorizedEntries = CategorizedContentBlockerEntries()
    
    public init() {
        do {
            categorizedEntries = try loadContentBlockerEntries()
        } catch {
            Logger.log(text: "Could not load content blocker entries \(error)")
        }
    }
    
    public var blockingEnabled: Bool {
        return configuration.blockingEnabled
    }
    
    public var blockedEntries: [ContentBlockerEntry] {
        var entries = [ContentBlockerEntry]()
        for (categoryKey, categoryEntries) in categorizedEntries {
            let category = ContentBlockerCategory.forKey(categoryKey)
            if category == .advertising && configuration.blockAdvertisers {
                entries.append(contentsOf: categoryEntries)
            }
            if category == .analytics && configuration.blockAnalytics {
                entries.append(contentsOf: categoryEntries)
            }
            if category == .social && configuration.blockSocial {
                entries.append(contentsOf: categoryEntries)
            }
        }
        return entries
    }
    
    private func loadContentBlockerEntries() throws -> CategorizedContentBlockerEntries {
        let fileLoader = FileLoader()
        let data = try fileLoader.load(name: FileConstants.name, ext: FileConstants.ext)
        return try parser.convert(fromJsonData: data)
    }
    
    /**
        Checks if a url for a specific document should be blocked.
        - parameter url: the url to check
        - parameter documentUrl: the document requesting the url
        - returns: entry if the item matches a third party url in the block list otherwise nil
     */
    public func block(url: URL, forDocument documentUrl: URL) -> ContentBlockerEntry? {
        for entry in blockedEntries {
            if url.absoluteString.contains(entry.url) && documentUrl.host != url.host {
                Logger.log(text: "Content blocker BLOCKED \(url.absoluteString)")
                return entry
            }
        }
        Logger.log(text: "Content blocker did NOT block \(url.absoluteString)")
        return nil
    }
}

