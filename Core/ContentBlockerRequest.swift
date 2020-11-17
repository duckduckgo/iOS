//
//  ContentBlockerRequest.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

protocol ContentBlockerRemoteDataSource {
    
    var requestCount: Int { get }
    
    func request(_ configuration: ContentBlockerRequest.Configuration, completion:@escaping (ContentBlockerRequest.Response) -> Void)
}

public class ContentBlockerRequest: ContentBlockerRemoteDataSource {
    enum Response {
        case error
        case success(etag: String?, data: Data)
    }

    public enum Configuration: String {
        case httpsBloomFilterSpec
        case httpsBloomFilter
        case httpsExcludedDomains
        case surrogates
        case trackerDataSet
        case temporaryUnprotectedSites
    }
    
    var requestCount = 0

    private let etagStorage: BlockerListETagStorage

    init(etagStorage: BlockerListETagStorage) {
        self.etagStorage = etagStorage
    }
    
    func request(_ configuration: Configuration, completion: @escaping (Response) -> Void) {
        requestCount += 1
        
        let spid = Instruments.shared.startTimedEvent(.fetchingContentBlockerData, info: configuration.rawValue)
        let cacheHeaders = APIHeaders().defaultHeaders(with: etagStorage.etag(for: configuration))

        APIRequest.request(url: url(for: configuration), headers: cacheHeaders) { (response, error) in
            
            guard error == nil,
                let response = response,
                let data = response.data else {
                    Instruments.shared.endTimedEvent(for: spid, result: "error")
                completion(.error)
                return
            }

            Instruments.shared.endTimedEvent(for: spid, result: "success")
            completion(.success(etag: response.etag, data: data))
        }
    }
    
    private func url(for list: Configuration) -> URL {
        let appUrls = AppUrls()
        
        switch list {
        case .httpsBloomFilterSpec: return appUrls.httpsBloomFilterSpec
        case .httpsBloomFilter: return appUrls.httpsBloomFilter
        case .httpsExcludedDomains: return appUrls.httpsExcludedDomains
        case .surrogates: return appUrls.surrogates
        case .trackerDataSet: return appUrls.trackerDataSet
        case .temporaryUnprotectedSites: return appUrls.temporaryUnprotectedSites
        }
    }
}
