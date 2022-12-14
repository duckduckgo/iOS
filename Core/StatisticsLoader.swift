//
//  StatisticsLoader.swift
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
import os.log
import BrowserServicesKit

public class StatisticsLoader {
    
    public typealias Completion =  (() -> Void)
    
    public static let shared = StatisticsLoader()
    
    private let statisticsStore: StatisticsStore
    private let appUrls: AppUrls
    private let parser = AtbParser()
    
    init(statisticsStore: StatisticsStore = StatisticsUserDefaults()) {
        self.statisticsStore = statisticsStore
        self.appUrls = AppUrls(statisticsStore: statisticsStore)
    }
    
    public func load(completion: @escaping Completion = {}) {
        if statisticsStore.hasInstallStatistics {
            completion()
            return
        }
        requestInstallStatistics(completion: completion)
    }
    
    private func requestInstallStatistics(completion: @escaping Completion = {}) {
        APIRequest.request(url: appUrls.initialAtb) { response, error in
            if let error = error {
                os_log("Initial atb request failed with error %s", log: generalLog, type: .debug, error.localizedDescription)
                completion()
                return
            }
            
            if let data = response?.data, let atb  = try? self.parser.convert(fromJsonData: data) {
                self.requestExti(atb: atb, completion: completion)
            } else {
                completion()
            }
        }
    }
    
    private func requestExti(atb: Atb, completion: @escaping Completion = {}) {
        
        let installAtb = atb.version + (statisticsStore.variant ?? "")
        APIRequest.request(url: appUrls.exti(forAtb: installAtb)) { _, error in
            if let error = error {
                os_log("Exti request failed with error %s", log: generalLog, type: .debug, error.localizedDescription)
                completion()
                return
            }
            self.statisticsStore.installDate = Date()
            self.statisticsStore.atb = atb.version
            completion()
        }
    }
    
    public func refreshSearchRetentionAtb(completion: @escaping Completion = {}) {
        
        guard let url = appUrls.searchAtb else {
            requestInstallStatistics(completion: completion)
            return
        }
        
        APIRequest.request(url: url) { response, error in
            if let error = error {
                os_log("Search atb request failed with error %s", log: generalLog, type: .debug, error.localizedDescription)
                completion()
                return
            }
            if let data = response?.data, let atb  = try? self.parser.convert(fromJsonData: data) {
                self.statisticsStore.searchRetentionAtb = atb.version
                self.storeUpdateVersionIfPresent(atb)
            }
            completion()
        }
    }
    
    public func refreshAppRetentionAtb(completion: @escaping Completion = {}) {
        
        guard let url = appUrls.appAtb else {
            requestInstallStatistics(completion: completion)
            return
        }
        
        APIRequest.request(url: url) { response, error in
            if let error = error {
                os_log("App atb request failed with error %s", log: generalLog, type: .debug, error.localizedDescription)
                completion()
                return
            }
            if let data = response?.data, let atb = try? self.parser.convert(fromJsonData: data) {
                self.statisticsStore.appRetentionAtb = atb.version
                self.storeUpdateVersionIfPresent(atb)
            }
            completion()
        }
    }

    public func storeUpdateVersionIfPresent(_ atb: Atb) {
        if let updateVersion = atb.updateVersion {
            statisticsStore.atb = updateVersion
        }
    }
}
