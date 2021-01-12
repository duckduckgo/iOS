//
//  ContentBlockerRulesBuilder.swift
//  DuckDuckGo
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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

public struct ContentBlockerRulesBuilder {

    struct Constants {
        // in the scheme .* overmatches and "OR" does not work
        static let subDomainPrefix = "^(https?)?(wss?)?://([a-z0-9-]+\\.)*"
        static let domainMatchSuffix = "(:?[0-9]+)?/.*"
    }
    
    static let resourceMapping: [String: ContentBlockerRule.Trigger.ResourceType] = [
        "script": .script,
        "xmlhttprequest": .raw,
        "subdocument": .document,
        "image": .image,
        "stylesheet": .stylesheet
    ]
    
    let trackerData: TrackerData

    public init(trackerData: TrackerData) {
        self.trackerData = trackerData
    }
    
    /// Build all the rules for the given tracker data and list of exceptions.
    public func buildRules(withExceptions exceptions: [String]? = nil,
                           andTemporaryUnprotectedDomains tempUnprotectedDomains: [String]? = nil) -> [ContentBlockerRule] {
        
        let trackerRules = trackerData.trackers.values.compactMap {
            buildRules(from: $0)
        }.flatMap { $0 }
        
        var cnameTrackers = [String: KnownTracker]()
        trackerData.cnames?.forEach { key, value in
            guard let knownTracker = trackerData.findTracker(byCname: value) else { return }
            let newTracker = knownTracker.copy(withNewDomain: key)
            cnameTrackers[key] = newTracker
        }
        let cnameRules = cnameTrackers.values.compactMap {
            buildRules(from: $0)
        }.flatMap { $0 }
        
        return trackerRules + cnameRules + buildExceptions(from: exceptions, andUnprotectedDomains: tempUnprotectedDomains)
    }
    
    /// Build the rules for a specific tracker.
    public func buildRules(from tracker: KnownTracker) -> [ContentBlockerRule] {
        
        let blockingRules: [ContentBlockerRule] = buildBlockingRules(from: tracker)
        
        let specialRules = tracker.rules?.compactMap { r -> [ContentBlockerRule] in
            buildRules(fromRule: r, inTracker: tracker)
            } ?? []
        
        let sortedRules = specialRules.sorted(by: { $0.count > $1.count })
        
        let dedupedRules = sortedRules.flatMap { $0 }.removeDuplicates()
        
        return blockingRules + dedupedRules
    }
    
    private func buildExceptions(from exceptions: [String]?, andUnprotectedDomains unprotectedDomains: [String]?) -> [ContentBlockerRule] {
        let allExceptions = (exceptions ?? []) + (unprotectedDomains?.wildcards() ?? [])
        guard !allExceptions.isEmpty else { return [] }
        return [ContentBlockerRule(trigger: .trigger(urlFilter: ".*", ifDomain: allExceptions, resourceType: nil), action: .ignorePreviousRules())]
    }
    
    private func buildBlockingRules(from tracker: KnownTracker) -> [ContentBlockerRule] {
        guard tracker.defaultAction == .block else { return [] }
        guard let domain = tracker.domain else { return [] }
        let urlFilter = Constants.subDomainPrefix + domain.regexEscape() + Constants.domainMatchSuffix
        return [ ContentBlockerRule(trigger: .trigger(urlFilter: urlFilter,
                                                      unlessDomain: trackerData.relatedDomains(for: tracker.owner)?.wildcards()),
                                    action: .block()) ]        
    }

    private func buildRules(fromRule r: KnownTracker.Rule,
                            inTracker tracker: KnownTracker) -> [ContentBlockerRule] {
        
        return tracker.defaultAction == .block ?
            buildRulesForBlockingTracker(fromRule: r, inTracker: tracker) :
            buildRulesForIgnoringTracker(fromRule: r, inTracker: tracker)
    }
    
    private func buildRulesForIgnoringTracker(fromRule r: KnownTracker.Rule,
                                              inTracker tracker: KnownTracker) -> [ContentBlockerRule] {
        if r.action == .some(.ignore) {
            return [
                block(r, withOwner: tracker.owner),
                ignorePrevious(r, matching: r.options)
            ]
        } else if r.options == nil && r.exceptions == nil {
            return [
                block(r, withOwner: tracker.owner)
            ]
        } else if r.exceptions != nil && r.options != nil {
            return [
                block(r, withOwner: tracker.owner, matching: r.options),
                ignorePrevious(r, matching: r.exceptions)
            ]
        } else if r.options != nil {
            return [
                block(r, withOwner: tracker.owner, matching: r.options)
            ]
        } else if r.exceptions != nil {
            return [
                block(r, withOwner: tracker.owner),
                ignorePrevious(r, matching: r.exceptions)
            ]
        }
        
        return []
    }
    
    private func buildRulesForBlockingTracker(fromRule r: KnownTracker.Rule,
                                              inTracker tracker: KnownTracker) -> [ContentBlockerRule] {
        
        if r.options != nil && r.exceptions != nil {
            return [
                ignorePrevious(r),
                block(r, withOwner: tracker.owner, matching: r.options),
                ignorePrevious(r, matching: r.exceptions)
            ]
        } else if r.action == .some(.ignore) {
            return [
                ignorePrevious(r, matching: r.options)
            ]
        } else if r.options != nil {
            return [
                ignorePrevious(r),
                block(r, withOwner: tracker.owner, matching: r.options)
            ]
        } else if r.exceptions != nil {
            return [
                ignorePrevious(r, matching: r.exceptions)
            ]
        } else {
            return [
                block(r, withOwner: tracker.owner)
            ]
        }
    }
    
    private func block(_ rule: KnownTracker.Rule,
                       withOwner owner: KnownTracker.Owner?,
                       matching: KnownTracker.Rule.Matching? = nil) -> ContentBlockerRule {
        
        if let matching = matching {
            return ContentBlockerRule(trigger: .trigger(urlFilter: rule.normalizedRule(),
                                                        ifDomain: matching.domains?.prefixAll(with: "*"),
                                                        resourceType: matching.types?.mapResources()),
                                      action: .block())
            
        } else {
            return ContentBlockerRule(trigger: .trigger(urlFilter: rule.normalizedRule(),
                                                        unlessDomain: trackerData.relatedDomains(for: owner)?.wildcards()),
                                      action: .block())
        }
    }
    
    private func ignorePrevious(_ rule: KnownTracker.Rule, matching: KnownTracker.Rule.Matching? = nil) -> ContentBlockerRule {
        return ContentBlockerRule(trigger: .trigger(urlFilter: rule.normalizedRule(),
                                                    ifDomain: matching?.domains?.prefixAll(with: "*"),
                                                    resourceType: matching?.types?.mapResources()),
                                  action: .ignorePreviousRules())
    }
    
}

fileprivate extension String {
    
    func regexEscape() -> String {
        return replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: ".", with: "\\.")
    }
    
}

fileprivate extension Array where Element: Hashable {
    
    func removeDuplicates() -> [Element] {
        return Array(Set(self))
    }
    
}

fileprivate extension Array where Element == String {
    
    func prefixAll(with prefix: String) -> [String] {
        return map { prefix + $0 }
    }
    
    func wildcards() -> [String] {
        return prefixAll(with: "*")
    }
    
    func normalizeAsUrls() -> [String] {
        return map { ContentBlockerRulesBuilder.Constants.subDomainPrefix + $0 + "/.*" }
    }
    
    func mapResources() -> [ContentBlockerRule.Trigger.ResourceType] {
        return compactMap { ContentBlockerRulesBuilder.resourceMapping[$0] }
    }
    
}

fileprivate extension KnownTracker.Rule {
    
    func normalizedRule() -> String {
        guard !rule!.hasPrefix("http") else { return rule! }
        return ContentBlockerRulesBuilder.Constants.subDomainPrefix + rule!
    }
    
}
