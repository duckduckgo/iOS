//
//  TrackerDataManager.swift
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
import TrackerRadarKit

public class TrackerDataManager {
    
    public struct Constants {
        public static let embeddedDataSetETag = "\"b5a369bfb768bc327fb22575c792a348\""
        public static let embeddedDataSetSHA = "uFwyHaQtXyKGmC4SQtLRmFMH1EOn48LRlf2pLQEvd+8="
    }
    
    public enum ReloadResult {
        case embedded
        case embeddedFallback
        case downloaded
    }
    
    public typealias DataSet = (tds: TrackerData, etag: String)
    
    private let lock = NSLock()
    
    private var _fetchedData: DataSet?
    private(set) public var fetchedData: DataSet? {
        get {
            lock.lock()
            let data = _fetchedData
            lock.unlock()
            return data
        }
        set {
            lock.lock()
            _fetchedData = newValue
            lock.unlock()
        }
    }
    
    private var _embeddedData: DataSet!
    private(set) public var embeddedData: DataSet {
        get {
            lock.lock()
            let data: DataSet
            // List is loaded lazily when needed
            if let embedded = _embeddedData {
                data = embedded
            } else {
                let trackerData = try? JSONDecoder().decode(TrackerData.self, from: Self.loadEmbeddedAsData())
                _embeddedData = (trackerData!, Constants.embeddedDataSetETag)
                data = _embeddedData
            }
            lock.unlock()
            return data
        }
        set {
            lock.lock()
            _embeddedData = newValue
            lock.unlock()
        }
    }
    
    // remove?
    public static let shared = TrackerDataManager()
    
    public var trackerData: TrackerData {
        if let data = fetchedData {
            return data.tds
        }
        return embeddedData.tds
    }

    init(trackerData: TrackerData) {
        _fetchedData = (trackerData, "")
    }

    init() {
        reload(etag: UserDefaultsETagStorage().etag(for: .trackerDataSet))
    }
    
    @discardableResult
    public func reload(etag: String?) -> ReloadResult {
        
        let result: ReloadResult
        
        if let etag = etag, let data = FileStore().loadAsData(forConfiguration: .trackerDataSet) {
            result = .downloaded
            
            do {
                // This maigh fail if the downloaded data is corrupt or format has changed unexpectedly
                let data = try JSONDecoder().decode(TrackerData.self, from: data)
                fetchedData = (data, etag)
            } catch {
                Pixel.fire(pixel: .trackerDataParseFailed, error: error)
                fetchedData = nil
                return .embeddedFallback
            }
        } else {
            fetchedData = nil
            result = .embedded
        }
        
        return result
    }
    
    static var embeddedUrl: URL {
        return Bundle.core.url(forResource: "trackerData", withExtension: "json")!
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
