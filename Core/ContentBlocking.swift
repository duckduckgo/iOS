//
//  ContentBlocking.swift
//  Core
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
import Common


public final class ContentBlocking {
    public static let shared = ContentBlocking()

    public let privacyConfigurationManager: PrivacyConfigurationManaging
    public let adClickAttribution: AdClickAttributionFeature
    public let adClickAttributionRulesProvider: AdClickAttributionRulesProvider
    public let trackerDataManager: TrackerDataManager
    public let contentBlockingManager: ContentBlockerRulesManager
    private let contentBlockerRulesSource: DefaultContentBlockerRulesListsSource
    private let exceptionsSource: DefaultContentBlockerRulesExceptionsSource
    private let lastCompiledRulesStore: AppLastCompiledRulesStore

    public var onCriticalError: (() -> Void)? {
        didSet {
            contentBlockingManager.onCriticalError = onCriticalError
        }
    }

    private init(privacyConfigurationManager: PrivacyConfigurationManaging? = nil) {
        let internalUserDecider = DefaultInternalUserDecider(store: InternalUserStore())
        let statisticsStore = StatisticsUserDefaults()
        let privacyConfigurationManager = privacyConfigurationManager
            ?? PrivacyConfigurationManager(fetchedETag: UserDefaultsETagStorage().loadEtag(for: .privacyConfiguration),
                                           fetchedData: FileStore().loadAsData(for: .privacyConfiguration),
                                           embeddedDataProvider: AppPrivacyConfigurationDataProvider(),
                                           localProtection: DomainsProtectionUserDefaultsStore(),
                                           errorReporting: Self.debugEvents,
                                           internalUserDecider: internalUserDecider,
                                           installDate: statisticsStore.installDate)
        self.privacyConfigurationManager = privacyConfigurationManager

        trackerDataManager = TrackerDataManager(etag: UserDefaultsETagStorage().loadEtag(for: .trackerDataSet),
                                                data: FileStore().loadAsData(for: .trackerDataSet),
                                                embeddedDataProvider: AppTrackerDataSetProvider(),
                                                errorReporting: Self.debugEvents)

        adClickAttribution = AdClickAttributionFeature(with: privacyConfigurationManager)
        contentBlockerRulesSource = ContentBlockerRulesLists(trackerDataManager: trackerDataManager,
                                                             adClickAttribution: adClickAttribution)

        exceptionsSource = DefaultContentBlockerRulesExceptionsSource(privacyConfigManager: privacyConfigurationManager)
        lastCompiledRulesStore = AppLastCompiledRulesStore()

        contentBlockingManager = ContentBlockerRulesManager(rulesSource: contentBlockerRulesSource,
                                                            exceptionsSource: exceptionsSource,
                                                            lastCompiledRulesStore: lastCompiledRulesStore,
                                                            errorReporting: Self.debugEvents,
                                                            log: .contentBlockingLog)

        adClickAttributionRulesProvider = AdClickAttributionRulesProvider(config: adClickAttribution,
                                                                          compiledRulesSource: contentBlockingManager,
                                                                          exceptionsSource: exceptionsSource,
                                                                          errorReporting: attributionDebugEvents,
                                                                          compilationErrorReporting: Self.debugEvents)
    }

    private static let debugEvents = EventMapping<ContentBlockerDebugEvents> { event, error, parameters, onComplete in
        let domainEvent: Pixel.Event
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
            
        case .contentBlockingCompilationFailed(let listName, let component):
            let defaultTDSListName = DefaultContentBlockerRulesListsSource.Constants.trackerDataSetRulesListName
            
            let listType: Pixel.Event.CompileRulesListType
            switch listName {
            case defaultTDSListName:
                listType = .tds
            case AdClickAttributionRulesSplitter.blockingAttributionRuleListName(forListNamed: defaultTDSListName):
                listType = .blockingAttribution
            case AdClickAttributionRulesProvider.Constants.attributedTempRuleListName:
                listType = .attributed
            default:
                listType = .unknown
            }

            domainEvent = .contentBlockingCompilationFailed(listType: listType, component: component)
            
        case .contentBlockingCompilationTime:
            domainEvent = .contentBlockingCompilationTime
        }
        
        if let error = error {
            Pixel.fire(pixel: domainEvent,
                       error: error,
                       withAdditionalParameters: parameters ?? [:],
                       onComplete: onComplete)
        } else {
            Pixel.fire(pixel: domainEvent,
                       withAdditionalParameters: parameters ?? [:],
                       includedParameters: [],
                       onComplete: onComplete)
        }
        
    }

    public func makeAdClickAttributionDetection(tld: TLD) -> AdClickAttributionDetection {
        AdClickAttributionDetection(feature: adClickAttribution,
                                    tld: tld,
                                    eventReporting: attributionEvents,
                                    errorReporting: attributionDebugEvents,
                                    log: .adAttributionLog)
    }
    
    public func makeAdClickAttributionLogic(tld: TLD) -> AdClickAttributionLogic {
        AdClickAttributionLogic(featureConfig: adClickAttribution,
                                rulesProvider: adClickAttributionRulesProvider,
                                tld: tld,
                                eventReporting: attributionEvents,
                                errorReporting: attributionDebugEvents,
                                log: .adAttributionLog)
    }
    
    private let attributionEvents = EventMapping<AdClickAttributionEvents> { event, _, parameters, _ in
        var shouldIncludeAppVersion = true
        let domainEvent: Pixel.Event
        switch event {
        case .adAttributionDetected:
            domainEvent = .adClickAttributionDetected
        case .adAttributionActive:
            domainEvent = .adClickAttributionActive
        case .adAttributionPageLoads:
            domainEvent = .adClickAttributionPageLoads
            shouldIncludeAppVersion = false
        }
        
        Pixel.fire(pixel: domainEvent, withAdditionalParameters: parameters ?? [:], includedParameters: shouldIncludeAppVersion ? [.appVersion] : [])
    }
    
    private let attributionDebugEvents = EventMapping<AdClickAttributionDebugEvents> { event, _, _, _ in
        let domainEvent: Pixel.Event
        switch event {
        case .adAttributionCompilationFailedForAttributedRulesList:
            domainEvent = .adAttributionCompilationFailedForAttributedRulesList
        case .adAttributionGlobalAttributedRulesDoNotExist:
            domainEvent = .adAttributionGlobalAttributedRulesDoNotExist
        case .adAttributionDetectionHeuristicsDidNotMatchDomain:
            domainEvent = .adAttributionDetectionHeuristicsDidNotMatchDomain
        case .adAttributionLogicUnexpectedStateOnRulesCompiled:
            domainEvent = .adAttributionLogicUnexpectedStateOnRulesCompiled
        case .adAttributionLogicUnexpectedStateOnInheritedAttribution:
            domainEvent = .adAttributionLogicUnexpectedStateOnInheritedAttribution
        case .adAttributionLogicUnexpectedStateOnRulesCompilationFailed:
            domainEvent = .adAttributionLogicUnexpectedStateOnRulesCompilationFailed
        case .adAttributionDetectionInvalidDomainInParameter:
            domainEvent = .adAttributionDetectionInvalidDomainInParameter
        case .adAttributionLogicRequestingAttributionTimedOut:
            domainEvent = .adAttributionLogicRequestingAttributionTimedOut
        case .adAttributionLogicWrongVendorOnSuccessfulCompilation:
            domainEvent = .adAttributionLogicWrongVendorOnSuccessfulCompilation
        case .adAttributionLogicWrongVendorOnFailedCompilation:
            domainEvent = .adAttributionLogicWrongVendorOnFailedCompilation
        }
        
        Pixel.fire(pixel: domainEvent, includedParameters: [])
    }
            
}

public class DomainsProtectionUserDefaultsStore: DomainsProtectionStore {
    
    private struct Keys {
        static let unprotectedDomains = "com.duckduckgo.contentblocker.whitelist"
        static let trackerList = "com.duckduckgo.trackerList"
    }
    
    private let suiteName: String
    
    public init(suiteName: String = ContentBlockerStoreConstants.groupName) {
        self.suiteName = suiteName
    }
    
    private var userDefaults: UserDefaults? {
        return UserDefaults(suiteName: suiteName)
    }
    
    public private(set) var unprotectedDomains: Set<String> {
        get {
            guard let data = userDefaults?.data(forKey: Keys.unprotectedDomains) else { return Set<String>() }
            guard let unprotectedDomains = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSSet.self, NSString.self],
                                                                                   from: data) as? Set<String> else {
                return Set<String>()
            }
            return unprotectedDomains
        }
        set(newUnprotectedDomain) {
            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: newUnprotectedDomain, requiringSecureCoding: false) else { return }
            userDefaults?.set(data, forKey: Keys.unprotectedDomains)
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

}
