//
//  TrackerData.swift
//  Core
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
            Logger.log(text: "error loading downloaded tds [\(error.localizedDescription)], falling back to embedded")
            
            // The embedded data should NEVER fail, so fall back to it
            let embeddedData = try? JSONDecoder().decode(TrackerData.self, from: Self.loadEmbeddedAsData())
            self.trackerData = embeddedData!
            Pixel.fire(pixel: .reloadTrackerDataFailed)
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
