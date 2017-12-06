//
//  BlockerListRequest.swift
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

class BlockerListRequest {

    enum List: String {

        case disconnectMe = "disconnectme"
        case easylist = "easylist"
        case easylistPrivacy = "easyprivacy"
        case trackersWhitelist
        case httpsUpgrade = "https"

    }

    let etagStorage: BlockerListETagStorage

    init(etagStorage: BlockerListETagStorage = UserDefaultsETagStorage()) {
        self.etagStorage = etagStorage
    }

    func request(_ list: List, completion:@escaping (Data?) -> Void) {
        APIRequest.request(url: url(for: list)) { (response, error) in

            guard error == nil else {
                completion(nil)
                return
            }

            guard let response = response else {
                completion(nil)
                return
            }

            guard let data = response.data else {
                completion(nil)
                return
            }

            let etag = self.etagStorage.etag(for: list)

            if etag == nil || etag != response.etag {
                self.etagStorage.set(etag: response.etag, for: list)
                completion(data)
            } else {
                completion(nil)
            }
        }
    }

    private func url(for list: List) -> URL {
        let appUrls = AppUrls()

        switch(list) {
            case .disconnectMe: return appUrls.disconnectMeBlockList
            case .easylist: return appUrls.easylistBlockList
            case .easylistPrivacy: return appUrls.easylistPrivacyBlockList
            case .httpsUpgrade: return appUrls.httpsUpgradeList
            case .trackersWhitelist: return appUrls.trackersWhitelist
        }

    }
    
}

protocol BlockerListETagStorage {

    func set(etag: String?, for list: BlockerListRequest.List)

    func etag(for list: BlockerListRequest.List) -> String?

}

class UserDefaultsETagStorage: BlockerListETagStorage {

    lazy var defaults = UserDefaults(suiteName: "com.duckduckgo.blocker-list.etags")

    func etag(for list: BlockerListRequest.List) -> String? {
        let etag = defaults?.string(forKey: list.rawValue)
        Logger.log(items: "stored etag for ", list.rawValue, etag as Any)
        return etag
    }

    func set(etag: String?, for list: BlockerListRequest.List) {
        defaults?.set(etag, forKey: list.rawValue)
    }
    
}


