//
//  WhitelistManager.swift
//  DuckDuckGo
//
//  Created by Christopher Brind on 19/10/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

public class WhitelistManager {

    private let contentBlockerConfigurationStore: ContentBlockerConfigurationStore

    public var count: Int {
        get {
            return contentBlockerConfigurationStore.domainWhitelist.count
        }
    }

    private var domains: [String]?

    public init(contentBlockerConfigurationStore: ContentBlockerConfigurationStore = ContentBlockerConfigurationUserDefaults()) {
        self.contentBlockerConfigurationStore = contentBlockerConfigurationStore
    }

    public func add(domain: String) {
        contentBlockerConfigurationStore.addToWhitelist(domain: domain)
        domains = nil
    }

    public func remove(domain: String) {
        contentBlockerConfigurationStore.removeFromWhitelist(domain: domain)
        domains = nil
    }

    public func isWhitelisted(domain: String) -> Bool {
        return contentBlockerConfigurationStore.domainWhitelist.contains(domain)
    }

    public func domain(at index: Int) -> String? {
        if self.domains == nil {
            self.domains = Array(contentBlockerConfigurationStore.domainWhitelist).sorted()
        }
        return self.domains?[index]
    }

}
