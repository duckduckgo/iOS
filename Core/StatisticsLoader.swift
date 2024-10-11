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

import Common
import Foundation
import BrowserServicesKit
import Networking
import os.log

public class StatisticsLoader {

    public typealias Completion =  (() -> Void)

    public static let shared = StatisticsLoader()

    private let statisticsStore: StatisticsStore
    private let returnUserMeasurement: ReturnUserMeasurement
    private let usageSegmentation: UsageSegmenting
    private let parser = AtbParser()

    init(statisticsStore: StatisticsStore = StatisticsUserDefaults(),
         returnUserMeasurement: ReturnUserMeasurement = KeychainReturnUserMeasurement(),
         usageSegmentation: UsageSegmenting = UsageSegmentation()) {
        self.statisticsStore = statisticsStore
        self.returnUserMeasurement = returnUserMeasurement
        self.usageSegmentation = usageSegmentation
    }

    public func load(completion: @escaping Completion = {}) {
        if statisticsStore.hasInstallStatistics {
            completion()
            return
        }
        requestInstallStatistics(completion: completion)
    }

    private func requestInstallStatistics(completion: @escaping Completion = {}) {
        let configuration = APIRequest.Configuration(url: .atb)
        let request = APIRequest(configuration: configuration, urlSession: .session())

        request.fetch { response, error in
            if let error = error {
                Logger.general.error("Initial atb request failed with error: \(error.localizedDescription, privacy: .public)")
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
        let url = URL.makeExtiURL(atb: installAtb)

        let configuration = APIRequest.Configuration(url: url)
        let request = APIRequest(configuration: configuration, urlSession: .session())

        request.fetch { _, error in
            if let error = error {
                Logger.general.error("Exit request failed with error: \(error.localizedDescription, privacy: .public)")
                completion()
                return
            }
            self.statisticsStore.installDate = Date()
            self.statisticsStore.atb = atb.version
            self.returnUserMeasurement.installCompletedWithATB(atb)
            completion()
        }
    }

    public func refreshSearchRetentionAtb(completion: @escaping Completion = {}) {
        guard let url = StatisticsDependentURLFactory(statisticsStore: statisticsStore).makeSearchAtbURL() else {
            requestInstallStatistics {
                self.updateUsageSegmentationAfterInstall(activityType: .search)
                completion()
            }
            return
        }

        let configuration = APIRequest.Configuration(url: url)
        let request = APIRequest(configuration: configuration, urlSession: .session())

        request.fetch { response, error in
            if let error = error {
                Logger.general.error("Search atb request failed with error: \(error.localizedDescription, privacy: .public)")
                completion()
                return
            }
            if let data = response?.data, let atb = try? self.parser.convert(fromJsonData: data) {
                self.statisticsStore.searchRetentionAtb = atb.version
                self.storeUpdateVersionIfPresent(atb)
                self.updateUsageSegmentationWithAtb(atb, activityType: .search)
                NotificationCenter.default.post(name: .searchDAU,
                                                object: nil, userInfo: nil)
            }
            completion()
        }
    }

    public func refreshAppRetentionAtb(completion: @escaping Completion = {}) {
        guard let url = StatisticsDependentURLFactory(statisticsStore: statisticsStore).makeAppAtbURL() else {
            requestInstallStatistics {
                self.updateUsageSegmentationAfterInstall(activityType: .appUse)
                completion()
            }
            return
        }

        let configuration = APIRequest.Configuration(url: url)
        let request = APIRequest(configuration: configuration, urlSession: .session())

        request.fetch { response, error in
            if let error = error {
                Logger.general.error("App atb request failed with error: \(error.localizedDescription, privacy: .public)")
                completion()
                return
            }
            if let data = response?.data, let atb = try? self.parser.convert(fromJsonData: data) {
                self.statisticsStore.appRetentionAtb = atb.version
                self.storeUpdateVersionIfPresent(atb)
                self.updateUsageSegmentationWithAtb(atb, activityType: .appUse)
            }
            completion()
        }
    }

    public func storeUpdateVersionIfPresent(_ atb: Atb) {
        if let updateVersion = atb.updateVersion {
            statisticsStore.atb = updateVersion
            statisticsStore.variant = nil
            returnUserMeasurement.updateStoredATB(atb)
        }
    }

    private func processUsageSegmentation(atb: Atb?, activityType: UsageActivityType) {
        guard let installAtbValue = statisticsStore.atb else { return }
        let installAtb = Atb(version: installAtbValue + (statisticsStore.variant ?? ""), updateVersion: nil)
        let usageAtb = atb ?? installAtb

        self.usageSegmentation.processATB(usageAtb, withInstallAtb: installAtb, andActivityType: activityType)
    }

    private func updateUsageSegmentationWithAtb(_ atb: Atb, activityType: UsageActivityType) {
        processUsageSegmentation(atb: atb, activityType: activityType)
    }

    private func updateUsageSegmentationAfterInstall(activityType: UsageActivityType) {
        processUsageSegmentation(atb: nil, activityType: activityType)
    }
}
