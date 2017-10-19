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

    public init(contentBlockerConfigurationStore: ContentBlockerConfigurationStore = ContentBlockerConfigurationUserDefaults()) {
        self.contentBlockerConfigurationStore = contentBlockerConfigurationStore
    }

    public func add(host: String) {
        contentBlockerConfigurationStore.addToWhitelist(domain: host)
    }

    public func remove(host: String) {
        contentBlockerConfigurationStore.removeFromWhitelist(domain: host)
    }

    public func isWhitelisted(host: String) -> Bool {
        return contentBlockerConfigurationStore.domainWhitelist.contains(host)
    }

}
