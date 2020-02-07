//
//  EtagStorage.swift
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

protocol BlockerListETagStorage {
    
    func set(etag: String?, for list: ContentBlockerRequest.Configuration)
    
    func etag(for list: ContentBlockerRequest.Configuration) -> String?
    
}

class UserDefaultsETagStorage: BlockerListETagStorage {
    
    lazy var defaults = UserDefaults(suiteName: "com.duckduckgo.blocker-list.etags")
    
    func etag(for list: ContentBlockerRequest.Configuration) -> String? {
        let etag = defaults?.string(forKey: list.rawValue)
        os_log(items: "stored etag for ", list.rawValue, etag as Any)
        return etag
    }
    
    func set(etag: String?, for list: ContentBlockerRequest.Configuration) {
        defaults?.set(etag, forKey: list.rawValue)
    }
    
}
