//
//  HomeMessageStorage.swift
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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

import Core

public class HomeMessageStorage {

    private struct Keys {
        static let dateDismissed = "com.duckduckgo.homeMessage.dateDismissed."
    }
    
    private func key(forHomeMessage homeMessage: HomeMessage) -> String {
        return Keys.dateDismissed + homeMessage.rawValue
    }
    
    func dateDismissed(forHomeMessage homeMessage: HomeMessage) -> Date? {
        if let interval = userDefaults.object(forKey: key(forHomeMessage: homeMessage)) as? Double {
            return Date(timeIntervalSince1970: interval)
        }
        return nil
    }
    
    func setDateDismissed(forHomeMessage homeMessage: HomeMessage, date: Date? = Date()) {
        let defaultsKey = key(forHomeMessage: homeMessage)
        if let date = date {
            //TODO uncomment
            userDefaults.set(date.timeIntervalSince1970, forKey: defaultsKey)
        } else {
            userDefaults.removeObject(forKey: defaultsKey)
        }
    }

    private let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }

}
