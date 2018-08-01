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

public class StatisticsLoader {

    public typealias Completion =  (() -> Void)

    public static let shared = StatisticsLoader()

    private let statisticsStore: StatisticsStore
    private let appUrls = AppUrls()
    private let parser = AtbParser()

    init(statisticsStore: StatisticsStore = StatisticsUserDefaults()) {
        self.statisticsStore = statisticsStore
    }

    public func load(completion: @escaping Completion = {}) {
        if statisticsStore.hasInstallStatistics {
            completion()
            return
        }
        requestInstallStatistics(completion: completion)
    }

    private func requestInstallStatistics(completion: @escaping Completion = {}) {
        APIRequest.request(url: appUrls.atb) { response, error in

            if let error = error {
                Logger.log(text: "Initial atb request failed with error \(error.localizedDescription)")
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
        let retentionAtb = atb.version

        APIRequest.request(url: appUrls.exti(forAtb: installAtb)) { _, error in
            if let error = error {
                Logger.log(text: "Exti request failed with error \(error.localizedDescription)")
                completion()
                return
            }
            self.statisticsStore.atb = atb.version
            self.statisticsStore.retentionAtb = retentionAtb
            completion()
        }
    }

    public func refreshRetentionAtb(completion: @escaping Completion = {}) {
        print("***", #function, "IN")
        
        guard statisticsStore.hasInstallStatistics else {
            requestInstallStatistics()
            print("***", #function, "requesting install stats, OUT")
            return
        }

        APIRequest.request(url: appUrls.atb) { response, error in
            print("***", #function, "API: IN")
            if let error = error {
                print("***", #function, "API: error calling ATB", error)
                Logger.log(text: "Atb request failed with error \(error.localizedDescription)")
                completion()
                return
            }

            if let data = response?.data, let atb  = try? self.parser.convert(fromJsonData: data) {
                print("***", #function, "API: ATB updated", atb.version)
                self.statisticsStore.retentionAtb = atb.version
            }

            print("***", #function, "API: OUT")
            completion()
        }
        print("***", #function, "API call made, OUT")
    }
}
