//
//  ContentBlockerEntriesProvider.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 19/05/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation


fileprivate struct Constants {
    static let filename = "disconnectmetrackers"
    static let fileExtension = "json"
}

public class ContentBlocker {

    private let configuration = ContentBlockerConfigurationUserDefaults()
    private let parser = DisconnectMeContentBlockerParser()
    
    private var categorizedEntries = CategorizedContentBlockerEntries()
    
    private var blockedEntries: [ContentBlockerEntry] {
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
        let data = loadTrackersFile()
        if let loadedEntries = parser.convert(fromJsonData: data) {
            categorizedEntries = loadedEntries
        }
    }
    
    private func loadTrackersFile() -> Data? {
        let fileLoader = FileLoader()
        return fileLoader.load(name: Constants.filename, ext: Constants.fileExtension)
    }
    
    public func block(url: URL, forDocument documentUrl: URL) -> Bool {
        for entry in blockedEntries {
            if url.absoluteString.contains(entry.url) && !documentUrl.absoluteString.contains(entry.domain){
                return true
            }
        }
        return false
    }
}

