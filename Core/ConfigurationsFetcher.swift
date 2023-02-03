//
//  ConfigurationFetcher.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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


// Business model
enum Configuration {
    
    case privacyConfig
    case bloomFilter
    
}

extension Configuration {
    
    var url: URL {
        let appUrls = AppUrls()
        switch self {
        case .privacyConfig: return URL(string: "abc")!
        case .bloomFilter: return appUrls.httpsBloomFilterSpec
        }
    }
    
}

struct ConfigurationData {
    
    let etag: String
    let data: Data
    
}

struct ConfigurationFetchTask {
    
    let configuration: Configuration
    let etag: String?
    let url: URL?
    
    fileprivate var endpoint: URL { url ?? configuration.url }
    
    init(configuration: Configuration, etag: String? = nil, url: URL? = nil) {
        self.configuration = configuration
        self.etag = etag
        self.url = url
    }
    
}

protocol ConfigurationFetching {
    
    func fetch(_ tasks: [ConfigurationFetchTask]) async throws -> [Configuration: ConfigurationData]
    
}

struct ConfigurationFetcher: ConfigurationFetching {
    
    func fetch(_ tasks: [ConfigurationFetchTask]) async throws -> [Configuration: ConfigurationData] {
        try await withThrowingTaskGroup(of: (Configuration, ConfigurationData).self) { group in
            for task in tasks {
                group.addTask {
                    let (etag, data) = try await fetch(from: task.endpoint)
                    return (task.configuration, ConfigurationData(etag: etag, data: data))
                }
            }
            
            var configurations = [Configuration: ConfigurationData]()
            for try await (configuration, data) in group {
                configurations[configuration] = data
            }
            return configurations
        }
    }
    
    private func fetch(from url: URL) async throws -> (etag: String, data: Data) {
               
//        let cacheHeaders = APIHeaders().defaultHeaders(with: etag(for: configuration))

        let abc = try! await APIRequest.request(url: url)
        return ("", Data())
//        APIRequest.request(url: url(for: configuration), headers: cacheHeaders) { (response, error) in
//
//            guard error == nil,
//                let response = response,
//                let data = response.data else {
////                    Instruments.shared.endTimedEvent(for: spid, result: "error")
//                completion(.error)
//                return
//            }
//
////            Instruments.shared.endTimedEvent(for: spid, result: "success")
//            completion(.success(etag: response.etag, data: data))
    }
    
}

public final class ConfigurationManager {
    public static func doSomething() async {
        let fetcher = ConfigurationFetcher()
        do {
            let configurations = try await fetcher.fetch([ConfigurationFetchTask(configuration: .bloomFilter)])
        } catch {
            
        }
    }
}
