//
//  TrackerData.swift
//  Core
//
//  Created by Chris Brind on 26/11/2019.
//  Copyright © 2019 DuckDuckGo. All rights reserved.
//

import Foundation

public class TrackerDataManager {
    
    public static let shared = TrackerDataManager()
    
    private(set) public var trackerData: TrackerData!
    
    init() {
        reload()
    }
    
    public func reload() {
        // valid use case is we don't have downloaded data yet
        let data = FileStore().loadAsData(forConfiguration: .trackerDataSet) ?? Self.loadEmbeddedAsData()
        do {
            self.trackerData = try JSONDecoder().decode(TrackerData.self, from: data)
        } catch {
            Logger.log(text: error.localizedDescription)
            
            // The embedded data should NEVER fail, so fall back to it
            let embeddedData = try? JSONDecoder().decode(TrackerData.self, from: Self.loadEmbeddedAsData())
            self.trackerData = embeddedData!
            // TODO fire a pixel
        }
    }
    
    public func findTracker(forUrl url: String) -> KnownTracker? {
        guard let host = URL(string: url)?.host else { return nil }
        for host in variations(of: host) {
            if let tracker = trackerData.trackers[host] {
                return tracker                
            }
        }
        return nil
    }
    
    public func findEntity(byName name: String) -> Entity? {
        return trackerData.entities[name]
    }
    
    public func findEntity(forHost host: String) -> Entity? {
        for host in variations(of: host) {
            if let entityName = trackerData.domains[host] {
                return trackerData.entities[entityName]
            }
        }
        return nil
    }

    private func variations(of host: String) -> [String] {
        var parts = host.components(separatedBy: ".")
        var domains = [String]()
        while parts.count > 1 {
            let domain = parts.joined(separator: ".")
            domains.append(domain)
            parts.removeFirst()
        }
        return domains
    }
    
    static var embeddedUrl: URL {
        return Bundle(for: Self.self).url(forResource: "trackerData", withExtension: "json")!
    }

    static func loadEmbeddedAsData() -> Data {
        let json = try? Data(contentsOf: embeddedUrl)
        return json!
    }
    
    static func loadEmbeddedAsString() -> String {
        let json = try? String(contentsOf: embeddedUrl, encoding: .utf8)
        return json!
    }
    
}

public struct Entity: Codable, Hashable {
    
    public let displayName: String?
    public let domains: [String]?
    public let prevalence: Double?
    
}

public struct TrackerData: Codable {

    public typealias EntityName = String
    public typealias TrackerDomain = String

    public struct TrackerRules {
        
        let tracker: KnownTracker
        
    }
    
    public let trackers: [TrackerDomain: KnownTracker]
    public let entities: [EntityName: Entity]
    public let domains: [TrackerDomain: EntityName]
    
    public init(trackers: [String: KnownTracker], entities: [String: Entity], domains: [String: String]) {
        self.trackers = trackers
        self.entities = entities
        self.domains = domains
    }

    func relatedDomains(for owner: KnownTracker.Owner?) -> [String]? {
        return entities[owner?.name ?? ""]?.domains
    }
    
}
