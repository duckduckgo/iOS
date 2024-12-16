//
//  FreeTrialsFeatureFlagExperiment.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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
import BrowserServicesKit
import PixelExperimentKit
import PixelKit

/// A protocol that defines a method for firing experiment-related analytics pixels.
///
/// Types conforming to this protocol can be used to send experiment data (e.g., metrics and user actions).
/// This protocol is particularly useful for injecting dependencies to enable testing.
protocol ExperimentPixelFiring {
    /// Fires an experiment pixel with the specified parameters.
    ///
    /// - Parameters:
    ///   - subfeatureID: The unique identifier of the subfeature associated with the experiment.
    ///   - metric: The name of the metric being tracked (e.g., impressions, clicks, conversions).
    ///   - conversionWindowDays: The time range (in days) to associate the pixel with conversion events.
    ///   - value: A string representing the value associated with the metric, such as counts or statuses.
    static func fireExperimentPixel(for subfeatureID: SubfeatureID,
                                    metric: String,
                                    conversionWindowDays: ConversionWindow,
                                    value: String)
}

/// Conforming `PixelKit` to the `ExperimentPixelFiring` protocol.
///
/// `PixelKit` provides the concrete implementation for firing experiment pixels. By extending
/// `PixelKit` to conform to `ExperimentPixelFiring`, its functionality can be injected and mocked
/// for testing purposes.
extension PixelKit: ExperimentPixelFiring {}

/// Protocol defining the functionality required for a feature flag experiment related to free trials.
protocol FreeTrialsFeatureFlagExperimenting: FeatureFlagExperimentDescribing {
    /// Increments the count of paywall views.
    func incrementPaywallViewCount()

    /// Fires a pixel tracking the impression of the paywall.
    func firePaywallImpressionPixel()

    /// Fires a pixel when the monthly subscription offer is selected.
    func fireOfferSelectionMonthlyPixel()

    /// Fires a pixel when the yearly subscription offer is selected.
    func fireOfferSelectionYearlyPixel()

    /// Fires a pixel when a monthly subscription is started.
    func fireSubscriptionStartedMonthlyPixel()

    /// Fires a pixel when a yearly subscription is started.
    func fireSubscriptionStartedYearlyPixel()
}

/// Implementation of a feature flag experiment for monitoring and optimizing the impact of free trial offers.
final class FreeTrialsFeatureFlagExperiment: FreeTrialsFeatureFlagExperimenting {

    /// Represents the cohorts in the experiment.
    typealias CohortType = Cohort
    enum Cohort: String, FlagCohort {
        /// Control cohort with no changes applied.
        case control
        /// Treatment cohort where the experiment modifications are applied.
        case treatment
    }

    /// Constants used in the experiment.
    enum Constants {
        /// Unique identifier for the subfeature being tested.
        static let subfeatureIdentifier = "privacyProFreeTrialJan25"

        /// Metric identifiers for various user actions during the experiment.
        static let metricPaywallImpressions = "paywallImpressions"
        static let metricStartClickedMonthly = "startClickedMonthly"
        static let metricStartClickedYearly = "startClickedYearly"
        static let metricSubscriptionStartedMonthly = "subscriptionStartedMonthly"
        static let metricSubscriptionStartedYearly = "subscriptionStartedYearly"

        /// Conversion window in days for tracking user actions.
        static let conversionWindowDays = 0...3

        /// Key used to store the paywall view count in persistent storage.
        static let paywallViewCountKey = "\(subfeatureIdentifier)_paywallViewCount"
    }

    /// Identifier for the experiment.
    let rawValue = Constants.subfeatureIdentifier

    /// Source of the feature flag, defining how it is retrieved and enabled.
    let source: FeatureFlagSource = .remoteReleasable(.subfeature(PrivacyProSubfeature.privacyProFreeTrialJan25))

    /// Persistent storage for experiment-related data.
    private let storage: UserDefaults

    private let experimentPixelFirer: ExperimentPixelFiring.Type

    /// Initializes the experiment with the specified storage.
    /// - Parameter storage: The persistent storage to use. Defaults to `UserDefaults.standard`.
    init(storage: UserDefaults = .standard, experimentPixelFirer: ExperimentPixelFiring.Type = PixelKit.self) {
        self.storage = storage
        self.experimentPixelFirer = experimentPixelFirer
    }

    /// Increments the paywall view count and logs the updated value.
    func incrementPaywallViewCount() {
        paywallViewCount += 1
        Logger.subscription.debug("EX SETUP: paywallViewCount = \(self.paywallViewCount)")
    }

    /// Fires a pixel tracking the impression of the paywall.
    func firePaywallImpressionPixel() {
        experimentPixelFirer.fireExperimentPixel(for: Constants.subfeatureIdentifier,
                                     metric: Constants.metricPaywallImpressions,
                                     conversionWindowDays: Constants.conversionWindowDays,
                                     value: "\(paywallViewCount)")
    }

    /// Fires a pixel when the monthly subscription offer is selected.
    func fireOfferSelectionMonthlyPixel() {
        experimentPixelFirer.fireExperimentPixel(for: Constants.subfeatureIdentifier,
                                     metric: Constants.metricStartClickedMonthly,
                                     conversionWindowDays: Constants.conversionWindowDays,
                                     value: "\(paywallViewCount)")
    }

    /// Fires a pixel when the yearly subscription offer is selected.
    func fireOfferSelectionYearlyPixel() {
        experimentPixelFirer.fireExperimentPixel(for: Constants.subfeatureIdentifier,
                                     metric: Constants.metricStartClickedYearly,
                                     conversionWindowDays: Constants.conversionWindowDays,
                                     value: "\(paywallViewCount)")
    }

    /// Fires a pixel when a monthly subscription is started.
    func fireSubscriptionStartedMonthlyPixel() {
        experimentPixelFirer.fireExperimentPixel(for: Constants.subfeatureIdentifier,
                                     metric: Constants.metricSubscriptionStartedMonthly,
                                     conversionWindowDays: Constants.conversionWindowDays,
                                     value: "\(paywallViewCount)")
    }

    /// Fires a pixel when a yearly subscription is started.
    func fireSubscriptionStartedYearlyPixel() {
        experimentPixelFirer.fireExperimentPixel(for: Constants.subfeatureIdentifier,
                                     metric: Constants.metricSubscriptionStartedYearly,
                                     conversionWindowDays: Constants.conversionWindowDays,
                                     value: "\(paywallViewCount)")
    }
}

private extension FreeTrialsFeatureFlagExperiment {
    /// Computed property for managing the paywall view count in persistent storage.
    var paywallViewCount: Int {
        get {
            Logger.subscription.debug("EX SETUP: paywallViewCount GET")
            return storage.integer(forKey: Constants.paywallViewCountKey)
        }
        set {
            Logger.subscription.debug("EX SETUP: paywallViewCount SET")
            storage.set(newValue, forKey: Constants.paywallViewCountKey)
        }
    }
}
