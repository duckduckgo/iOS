//
//  ContentBlocker.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 19/05/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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
    
    public init() {
        do {
            categorizedEntries = try loadContentBlockerEntries()
        } catch {
            Logger.log(text: "Could not load content blocker entries \(error)")
        }
    }
    
    private func loadContentBlockerEntries() throws -> CategorizedContentBlockerEntries {
        let fileLoader = FileLoader()
        let data = try fileLoader.load(name: FileConstants.name, ext: FileConstants.ext)
        return try parser.convert(fromJsonData: data)
    }
    
    public func block(url: URL, forDocument documentUrl: URL) -> Bool {
        for entry in blockedEntries {
            if url.absoluteString.contains(entry.url) && !documentUrl.absoluteString.contains(entry.domain){
                Logger.log(text: "Content blocker BLOCKED \(url.absoluteString)")
                return true
            }
        }
        Logger.log(text: "Content blocker did NOT block \(url.absoluteString)")
        return false
    }
}

