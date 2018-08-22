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

class ContentBlockerRequest {
    
    enum Configuration: String {
        case disconnectMe = "disconnectme"
        case easylist = "easylist"
        case easylistPrivacy = "easyprivacy"
        case trackersWhitelist
        case httpsBloomFilterSpec
        case httpsBloomFilter
        case httpsWhitelist
        case surrogates
    }
    
    var requestCount = 0
    
    let etagStorage: BlockerListETagStorage
    
    init(etagStorage: BlockerListETagStorage = UserDefaultsETagStorage()) {
        self.etagStorage = etagStorage
    }
    
    func request(_ configuration: Configuration, completion:@escaping (Data?, Bool) -> Void) {
        requestCount += 1
        APIRequest.request(url: url(for: configuration)) { (response, error) in
            
            guard error == nil else {
                completion(nil, false)
                return
            }
            
            guard let response = response else {
                completion(nil, false)
                return
            }
            
            guard let data = response.data else {
                completion(nil, false)
                return
            }

            let etag = self.etagStorage.etag(for: configuration)
            
            if etag == nil || etag != response.etag {
                self.etagStorage.set(etag: response.etag, for: configuration)
                completion(data, false)
            } else {
                completion(data, true)
            }
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
        }
    }
}

protocol BlockerListETagStorage {
    
    func set(etag: String?, for list: ContentBlockerRequest.Configuration)
    
    func etag(for list: ContentBlockerRequest.Configuration) -> String?
    
}

class UserDefaultsETagStorage: BlockerListETagStorage {
    
    lazy var defaults = UserDefaults(suiteName: "com.duckduckgo.blocker-list.etags")
    
    func etag(for list: ContentBlockerRequest.Configuration) -> String? {
        let etag = defaults?.string(forKey: list.rawValue)
        Logger.log(items: "stored etag for ", list.rawValue, etag as Any)
        return etag
    }
    
    func set(etag: String?, for list: ContentBlockerRequest.Configuration) {
        defaults?.set(etag, forKey: list.rawValue)
    }
    
}
