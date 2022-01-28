//
//  ContentBlocking.swift
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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
import BrowserServicesKit
import Combine
import os.log

// ContentBlocking.trackerDataManager
// ContentBlocking.contentBlockingManager
public final class ContentBlocking {

    public static let privacyConfigurationManager
    = PrivacyConfigurationManager(fetchedETag: UserDefaultsETagStorage().etag(for: .privacyConfiguration),
                                  fetchedData: FileStore().loadAsData(forConfiguration: .privacyConfiguration),
                                      embeddedDataProvider: AppPrivacyConfigurationDataProvider(),
                                      localProtection: DomainsProtectionUserDefaultsStore(),
                                      errorReporting: debugEvents)

    public static let contentBlockingUpdating = ContentBlockingUpdating()

    public static let trackerDataManager = TrackerDataManager(etag: UserDefaultsETagStorage().etag(for: .trackerDataSet),
                                                       data: FileStore().loadAsData(forConfiguration: .trackerDataSet),
                                                       errorReporting: debugEvents)

    public static let contentBlockingManager = ContentBlockerRulesManager(rulesSource: contentBlockerRulesSource,
                                                                   exceptionsSource: exceptionsSource,
                                                                   updateListener: contentBlockingUpdating,
                                                                   logger: contentBlockingLog)
    
    private static let contentBlockerRulesSource = DefaultContentBlockerRulesListsSource(trackerDataManger: trackerDataManager)
    private static let exceptionsSource = DefaultContentBlockerRulesExceptionsSource(privacyConfigManager: privacyConfigurationManager)

    private static let debugEvents = EventMapping<ContentBlockerDebugEvents> { event, scope, error, parameters, onComplete in
        let domainEvent: PixelName
        switch event {
        case .trackerDataParseFailed:
            domainEvent = .trackerDataParseFailed

        case .trackerDataReloadFailed:
            domainEvent = .trackerDataReloadFailed

        case .trackerDataCouldNotBeLoaded:
            domainEvent = .trackerDataCouldNotBeLoaded

        case .privacyConfigurationReloadFailed:
            domainEvent = .privacyConfigurationReloadFailed

        case .privacyConfigurationParseFailed:
            domainEvent = .privacyConfigurationParseFailed

        case .privacyConfigurationCouldNotBeLoaded:
            domainEvent = .privacyConfigurationCouldNotBeLoaded

        case .contentBlockingTDSCompilationFailed:
            if scope == DefaultContentBlockerRulesListsSource.Constants.trackerDataSetRulesListName {
                domainEvent = .contentBlockingTDSCompilationFailed
            } else {
                domainEvent = .contentBlockingErrorReportingIssue
            }

        case .contentBlockingTempListCompilationFailed:
            if scope == DefaultContentBlockerRulesListsSource.Constants.trackerDataSetRulesListName {
                domainEvent = .contentBlockingTempListCompilationFailed
            } else {
                domainEvent = .contentBlockingErrorReportingIssue
            }

        case .contentBlockingAllowListCompilationFailed:
            if scope == DefaultContentBlockerRulesListsSource.Constants.trackerDataSetRulesListName {
                domainEvent = .contentBlockingAllowListCompilationFailed
            } else {
                domainEvent = .contentBlockingErrorReportingIssue
            }

        case .contentBlockingUnpSitesCompilationFailed:
            if scope == DefaultContentBlockerRulesListsSource.Constants.trackerDataSetRulesListName {
                domainEvent = .contentBlockingUnpSitesCompilationFailed
            } else {
                domainEvent = .contentBlockingErrorReportingIssue
            }

        case .contentBlockingFallbackCompilationFailed:
            if scope == DefaultContentBlockerRulesListsSource.Constants.trackerDataSetRulesListName {
                domainEvent = .contentBlockingFallbackCompilationFailed
            } else {
                domainEvent = .contentBlockingErrorReportingIssue
            }
        }

        if let error = error {
            Pixel.fire(pixel: domainEvent,
                       error: error,
                       withAdditionalParameters: parameters ?? [:],
                       onComplete: onComplete)
        } else {
            Pixel.fire(pixel: domainEvent,
                       withAdditionalParameters: parameters ?? [:],
                       onComplete: onComplete)
        }
        
    }
}

public struct ContentBlockerProtectionChangedNotification {
    public static let name = Notification.Name(rawValue: "com.duckduckgo.contentblocker.storeChanged")

    public static let diffKey = "ContentBlockingDiff"
}

public final class ContentBlockingUpdating: ContentBlockerRulesUpdating {
    
    public func rulesManager(_ manager: ContentBlockerRulesManager,
                             didUpdateRules rules: [ContentBlockerRulesManager.Rules],
                             changes: [String: ContentBlockerRulesIdentifier.Difference],
                             completionTokens: [ContentBlockerRulesManager.CompletionToken]) {
        NotificationCenter.default.post(name: ContentBlockerProtectionChangedNotification.name,
                                        object: self,
                                        userInfo: [ContentBlockerProtectionChangedNotification.diffKey: changes])
    }

}

extension ContentBlockerRulesManager {
    
    public var currentTDSRules: Rules? {
        return currentRules.first(where: { $0.name == DefaultContentBlockerRulesListsSource.Constants.trackerDataSetRulesListName })
    }
}

public class DomainsProtectionUserDefaultsStore: DomainsProtectionStore {

    private struct Keys {
        static let unprotectedDomains = "com.duckduckgo.contentblocker.whitelist"
        static let trackerList = "com.duckduckgo.trackerList"
    }

    private let suiteName: String

    public init(suiteName: String = ContentBlockerStoreConstants.groupName) {
        self.suiteName =  suiteName
    }

    private var userDefaults: UserDefaults? {
        return UserDefaults(suiteName: suiteName)
    }

    public private(set) var unprotectedDomains: Set<String> {
        get {
            guard let data = userDefaults?.data(forKey: Keys.unprotectedDomains) else { return Set<String>() }
            guard let unprotectedDomains = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSSet.self, from: data) as? Set<String> else {
                return Set<String>()
            }
            return unprotectedDomains
        }
        set(newUnprotectedDomain) {
            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: newUnprotectedDomain, requiringSecureCoding: false) else { return }
            userDefaults?.set(data, forKey: Keys.unprotectedDomains)
            onStoreChanged()
        }
    }

    public func disableProtection(forDomain domain: String) {
        var domains = unprotectedDomains
        domains.insert(domain)
        unprotectedDomains = domains
    }

    public func enableProtection(forDomain domain: String) {
        var domains = unprotectedDomains
        domains.remove(domain)
        unprotectedDomains = domains
    }

    private func onStoreChanged() {
        ContentBlocking.contentBlockingManager.scheduleCompilation()
    }

}
