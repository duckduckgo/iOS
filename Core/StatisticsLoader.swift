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
import PixelKit
import PixelExperimentKit
import os.log

public class StatisticsLoader {

    public typealias Completion =  (() -> Void)

    public static let shared = StatisticsLoader()

    private let statisticsStore: StatisticsStore
    private let returnUserMeasurement: ReturnUserMeasurement
    private let usageSegmentation: UsageSegmenting
    private let parser = AtbParser()
    private let fireSearchExperimentPixels: () -> Void
    private let fireAppRetentionExperimentPixels: () -> Void
    private let pixelFiring: PixelFiring.Type

    init(statisticsStore: StatisticsStore = StatisticsUserDefaults(),
         returnUserMeasurement: ReturnUserMeasurement = KeychainReturnUserMeasurement(),
         usageSegmentation: UsageSegmenting = UsageSegmentation(pixelEvents: UsageSegmentation.pixelEvents),
         fireAppRetentionExperimentPixels: @escaping () -> Void = PixelKit.fireAppRetentionExperimentPixels,
         fireSearchExperimentPixels: @escaping () -> Void = PixelKit.fireSearchExperimentPixels,
         pixelFiring: PixelFiring.Type = Pixel.self) {
        self.statisticsStore = statisticsStore
        self.returnUserMeasurement = returnUserMeasurement
        self.usageSegmentation = usageSegmentation
        self.fireSearchExperimentPixels = fireSearchExperimentPixels
        self.fireAppRetentionExperimentPixels = fireAppRetentionExperimentPixels
        self.pixelFiring = pixelFiring
    }

    public func load(completion: @escaping Completion = {}) {
        let completion = {
            self.refreshAppRetentionAtb()
            completion()
        }
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
            self.fireInstallPixel()
            self.statisticsStore.installDate = Date()
            self.statisticsStore.atb = atb.version
            self.returnUserMeasurement.installCompletedWithATB(atb)
            completion()
        }
    }

    private func fireInstallPixel() {
        let formattedLocale = Locale.current.localeIdentifierAsJsonFormat
        let isReinstall = String(statisticsStore.variant == VariantIOS.returningUser.name)
        let parameters = [
            "locale": formattedLocale,
            "reinstall": isReinstall
        ]
        pixelFiring.fire(.appInstall, withAdditionalParameters: parameters, includedParameters: [.appVersion], onComplete: { error in
            if let error {
                Logger.general.error("Install pixel failed with error: \(error.localizedDescription, privacy: .public)")
            }
        })
    }

    public func refreshSearchRetentionAtb(completion: @escaping Completion = {}) {
        fireSearchExperimentPixels()
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
        fireAppRetentionExperimentPixels()
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

private extension BoolFileMarker.Name {
    static let isATBPresent = BoolFileMarker.Name(rawValue: "atb-present")
}

extension UsageSegmentation {

    static let pixelEvents: EventMapping<UsageSegmentationPixel> = .init { event, _, params, _ in
        switch event {
        case .usageSegments:
            guard let params = params else {
                assertionFailure("Missing pixel parameters")
                return
            }

            Pixel.fire(pixel: .usageSegments, withAdditionalParameters: params)
        }
    }
}
