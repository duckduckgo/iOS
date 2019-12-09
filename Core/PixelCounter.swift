//
//  PixelCounter.swift
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
import Alamofire

protocol PixelCounter {
    
    func incrementCountFor(_ pixel: PixelName) -> Int
    func countFor(_ pixel: PixelName) -> Int
    
}

class PixelCounterStore: PixelCounter {
    
    public struct Constants {
        public static let groupName = "\(Global.groupIdPrefix).database"
        
        public static let maxCount = 20
        fileprivate static let dictionaryKey = "PixelCounterStoreDictonary"
    }
    
    let store: UserDefaults
    
    init(userDefaults: UserDefaults = UserDefaults(suiteName: Constants.groupName)!) {
        store = userDefaults
    }
    
    func incrementCountFor(_ pixel: PixelName) -> Int {
        var dict = getDictionary()
        let count = dict[pixel.rawValue] ?? 0
        
        guard count < Constants.maxCount else { return count }
        
        let newCount = count + 1
        dict[pixel.rawValue] = newCount
        storeDictionary(dict)
        return newCount
    }
    
    func countFor(_ pixel: PixelName) -> Int {
        return getDictionary()[pixel.rawValue] ?? 0
    }
    
    private func getDictionary() -> [String: Int] {
        return store.dictionary(forKey: Constants.dictionaryKey) as? [String: Int] ?? [:]
    }
    
    private func storeDictionary(_ dict: [String: Int]) {
        store.set(dict, forKey: Constants.dictionaryKey)
    }
}
