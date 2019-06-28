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

class ContentBlockerRequest: ContentBlockerRemoteDataSource {
    
    internal enum Response {
        case error
        case success(etag: String?, data: Data)
    }
    
    enum Configuration: String {
        case disconnectMe = "disconnectme"
        case easylist = "easylist"
        case easylistPrivacy = "easyprivacy"
        case trackersWhitelist
        case httpsBloomFilterSpec
        case httpsBloomFilter
        case httpsWhitelist
        case surrogates
        case entitylist = "entitylist2"
    }
    
    var requestCount = 0
    
    func request(_ configuration: Configuration, completion:@escaping (Response) -> Void) {
        requestCount += 1
        
        let spid = Instruments.shared.startTimedEvent(.fetchingContentBlockerData, info: configuration.rawValue)
        
        APIRequest.request(url: url(for: configuration)) { (response, error) in
            
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
        case .disconnectMe: return appUrls.disconnectMeBlockList
        case .easylist: return appUrls.easylistBlockList
        case .easylistPrivacy: return appUrls.easylistPrivacyBlockList
        case .httpsBloomFilterSpec: return appUrls.httpsBloomFilterSpec
        case .httpsBloomFilter: return appUrls.httpsBloomFilter
        case .httpsWhitelist: return appUrls.httpsWhitelist
        case .trackersWhitelist: return appUrls.trackersWhitelist
        case .surrogates: return appUrls.surrogates
        case .entitylist: return appUrls.entitylist
        }
    }
}
