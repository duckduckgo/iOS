//
//  GroupData.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 06/02/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

public class GroupData {
    
    private let groupName = "group.com.duckduckgo.extension"
    private let quickLinksKey = "quickLinksKey"
    
    public init() {
    }
    
    public var quickLinks: [Link]? {
        get {
            if let data = userDefaults()?.data(forKey: quickLinksKey) {
                return NSKeyedUnarchiver.unarchiveObject(with: data) as? [Link]
            }
            return nil
        }
        set(newQuickLinks) {
            if let newQuickLinks = newQuickLinks {
                let data = NSKeyedArchiver.archivedData(withRootObject: newQuickLinks)
                userDefaults()?.set(data, forKey: quickLinksKey)
            }
        }
    }
    
    public func addQuickLink(link: Link) {
        var links = quickLinks ?? [Link]()
        links.append(link)
        quickLinks = links
    }
    
    private func userDefaults() -> UserDefaults? {
        return UserDefaults(suiteName: groupName)
    }
}
