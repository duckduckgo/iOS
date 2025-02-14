//
//  ReportingService.swift
//  DuckDuckGo
//
//  Copyright © 2025 DuckDuckGo. All rights reserved.
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
import Core
import WidgetKit
import BrowserServicesKit

final class ReportingService {

    let marketplaceAdPostbackManager = MarketplaceAdPostbackManager()
    let onboardingPixelReporter = OnboardingPixelReporter()
    let privacyProDataReporter: PrivacyProDataReporting

    var syncService: SyncService? {
        didSet {
            guard let syncService else { return }
            privacyProDataReporter.injectSyncService(syncService.sync)
        }
    }

    init(fireproofing: Fireproofing) {
        privacyProDataReporter = PrivacyProDataReporter(fireproofing: fireproofing)
        NotificationCenter.default.addObserver(forName: .didFetchConfigurationOnForeground,
                                               object: nil,
                                               queue: .main) { _ in
            self.sendAppLaunchPostback(marketplaceAdPostbackManager: self.marketplaceAdPostbackManager)
        }
        NotificationCenter.default.addObserver(forName: .didLoadStatisticsOnForeground,
                                               object: nil,
                                               queue: .main) { _ in
            self.onStatisticsLoaded()
        }
    }

    private func sendAppLaunchPostback(marketplaceAdPostbackManager: MarketplaceAdPostbackManaging) {
        // Attribution support
        let privacyConfigurationManager = ContentBlocking.shared.privacyConfigurationManager
        if privacyConfigurationManager.privacyConfig.isEnabled(featureKey: .marketplaceAdPostback) {
            marketplaceAdPostbackManager.sendAppLaunchPostback()
        }
    }

    private func onStatisticsLoaded() {
        fireAppLaunchPixel()
        reportAdAttribution()
        onboardingPixelReporter.fireEnqueuedPixelsIfNeeded()
    }

    private func fireAppLaunchPixel() {
        WidgetCenter.shared.getCurrentConfigurations { result in
            let paramKeys: [WidgetFamily: String] = [
                .systemSmall: PixelParameters.widgetSmall,
                .systemMedium: PixelParameters.widgetMedium,
                .systemLarge: PixelParameters.widgetLarge
            ]

            switch result {
            case .failure(let error):
                Pixel.fire(pixel: .appLaunch, withAdditionalParameters: [
                    PixelParameters.widgetError: "1",
                    PixelParameters.widgetErrorCode: "\((error as NSError).code)",
                    PixelParameters.widgetErrorDomain: (error as NSError).domain
                ], includedParameters: [.appVersion, .atb])

            case .success(let widgetInfo):
                let params = widgetInfo.reduce([String: String]()) {
                    var result = $0
                    if let key = paramKeys[$1.family] {
                        result[key] = "1"
                    }
                    return result
                }
                Pixel.fire(pixel: .appLaunch, withAdditionalParameters: params, includedParameters: [.appVersion, .atb])
            }
        }
    }

    private func reportAdAttribution() {
        Task.detached(priority: .background) {
            await AdAttributionPixelReporter.shared.reportAttributionIfNeeded()
        }
    }

    func setupStorageForMarketPlacePostback() {
        marketplaceAdPostbackManager.updateReturningUserValue()
    }

    // MARK: - Resume

    func resume() {
        Task {
            await privacyProDataReporter.saveWidgetAdded()
        }
        fireFailedCompilationsPixelIfNeeded()
        AppDependencyProvider.shared.persistentPixel.sendQueuedPixels { _ in }
    }

    private func fireFailedCompilationsPixelIfNeeded() {
        let store = FailedCompilationsStore()
        if store.hasAnyFailures {
            DailyPixel.fire(pixel: .compilationFailed, withAdditionalParameters: store.summary) { error in
                guard error != nil else { return }
                store.cleanup()
            }
        }
    }

    // MARK: - Suspend

    func suspend() {
        privacyProDataReporter.saveApplicationLastSessionEnded()
    }

}
