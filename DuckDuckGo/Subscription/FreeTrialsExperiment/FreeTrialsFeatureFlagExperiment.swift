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
import Persistence
import Core

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
protocol FreeTrialsFeatureFlagExperimenting {

    /// Retrieves the cohort assigned to the user for the experiment.
    ///
    /// This method determines the cohort for the experiment if it is enabled, allowing
    /// for differentiation of behavior or configurations.
    ///
    /// - Returns: The user's cohort, or `nil` if the experiment is not enabled.
    func getCohortIfEnabled() -> (any FeatureFlagCohortDescribing)?

    /// Implementations can use this method to provide a dictionary of parameters
    /// associated with an experiment and the user's cohort.
    ///
    /// - Parameters:
    ///   - cohort: The cohort for which the experiment parameters are being retrieved.
    ///
    /// - Returns: A dictionary containing experiment-specific parameters:
    ///   - Experiment name.
    ///   - Cohort value, which may be adjusted based on criteria (e.g., adding `"_outside"`).
    ///   Returns `nil` if parameters are not applicable.
    func oneTimeParameters(for cohort: any FeatureFlagCohortDescribing) -> [String: String]?

    /// Increments the count of paywall views if the user's enrollment date is within the conversion window.
    func incrementPaywallViewCountIfWithinConversionWindow()

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

    /// Constants used in the experiment.
    enum Constants {
        /// Unique identifier for the subfeature being tested.
        static let subfeatureIdentifier = FeatureFlag.privacyProFreeTrialJan25.rawValue

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
        static let hasReturnedFreeTrialParametersKey = "\(subfeatureIdentifier)_hasReturnedFreeTrialParameters"

        /// Experiment name key included in the free trial parameters.
        static let freeTrialParameterExperimentName = "experimentName"

        /// Cohort value key included in the free trial parameters.
        static let freeTrialParameterExperimentCohort = "experimentCohort"

        /// Key used to store the override status for the feature flag in persistent storage.
        static let featureFlagOverrideKey = "\(subfeatureIdentifier)_featureFlagOverride"
    }

    /// Identifier for the experiment.
    let rawValue = Constants.subfeatureIdentifier

    /// Persistent storage for experiment-related data.
    private let storage: KeyValueStoring

    /// A type responsible for firing experiment-related analytics pixels.
    private let experimentPixelFirer: ExperimentPixelFiring.Type

    /// A bucketer responsible for categorizing values into predefined ranges.
    private let bucketer: any Bucketer

    /// A feature flagging service for managing feature flag experiments.
    private let featureFlagger: FeatureFlagger

    /// Initializes the experiment with the specified storage.
    /// - Parameter storage: The persistent storage to use. Defaults to `UserDefaults.standard`.
    init(storage: KeyValueStoring = UserDefaults.standard,
         experimentPixelFirer: ExperimentPixelFiring.Type = PixelKit.self,
         bucketer: any Bucketer = PaywallViewBucketer(),
         featureFlagger: FeatureFlagger = AppDependencyProvider.shared.featureFlagger) {
        self.storage = storage
        self.experimentPixelFirer = experimentPixelFirer
        self.bucketer = bucketer
        self.featureFlagger = featureFlagger
    }

    /// Retrieves the cohort associated with the experiment if the feature flag is enabled or if the override is active.
    ///
    /// This method determines whether the feature flag for the experiment is enabled
    /// or overridden. If the override flag stored in persistent storage is set to `true`,
    /// it forces the method to return the `treatment` cohort regardless of the feature flag's actual state.
    /// If no override is active, it checks the feature flag and returns the cohort assigned to the user
    /// based on the feature flag configuration.
    ///
    /// - Returns: The `treatment` cohort if the override is enabled, the assigned cohort if the feature flag is enabled, or `nil` otherwise.
    func getCohortIfEnabled() -> (any FeatureFlagCohortDescribing)? {
        let isFlagOverrideEnabled = storage.object(forKey: Constants.featureFlagOverrideKey) as? Bool ?? false
        if isFlagOverrideEnabled {
            return PrivacyProFreeTrialExperimentCohort.treatment
        }

        return featureFlagger.resolveCohort(for: FeatureFlag.privacyProFreeTrialJan25)
                as? PrivacyProFreeTrialExperimentCohort
    }

    /// Provides one-time free trial experiment parameters for the user's cohort.
    ///
    /// This method ensures that experiment parameters for the user's cohort are returned only once.
    /// It checks whether the parameters have already been provided using a persistent storage key. If they
    /// have not, it calculates the cohort value based on the user's conversion window status and returns
    /// a dictionary of parameters containing the experiment name and cohort.
    ///
    /// - Cohort Value Calculation:
    ///   - If the user is within the conversion window, the `cohort.rawValue` is used as the cohort value.
    ///   - If the user is outside the conversion window, `"_outside"` is appended to the cohort value.
    ///
    /// The method also updates the storage flag to indicate that the parameters have been returned,
    /// preventing duplicate retrievals.
    ///
    /// - Returns: A dictionary containing:
    ///   - `Constants.freeTrialParameterExperimentName`: The experiment name.
    ///   - `Constants.freeTrialParameterExperimentCohort`: The cohort name.
    ///   Returns `nil` if the parameters have already been provided.
    func oneTimeParameters(for cohort: any FeatureFlagCohortDescribing) -> [String: String]? {
        let hasReturnedParameters = storage.object(forKey: Constants.hasReturnedFreeTrialParametersKey) as? Bool ?? false

        // Return parameters only if they haven't been returned before
        guard !hasReturnedParameters else {
            return nil
        }

        storage.set(true, forKey: Constants.hasReturnedFreeTrialParametersKey)

        let cohortValue: String
        if userIsInConversionWindow {
            cohortValue = cohort.rawValue
        } else {
            cohortValue = "\(cohort.rawValue)_outside"
        }

        return [
            Constants.freeTrialParameterExperimentName: rawValue,
            Constants.freeTrialParameterExperimentCohort: cohortValue
        ]
    }

    /// Increments the count of paywall views if the user's enrollment date is within the conversion window.
    func incrementPaywallViewCountIfWithinConversionWindow() {
        guard userIsInConversionWindow else { return }
        paywallViewCount += 1
    }

    /// Fires a pixel tracking the impression of the paywall.
    func firePaywallImpressionPixel() {
        let bucket = bucketer.bucket(for: paywallViewCount)
        experimentPixelFirer.fireExperimentPixel(for: Constants.subfeatureIdentifier,
                                     metric: Constants.metricPaywallImpressions,
                                     conversionWindowDays: Constants.conversionWindowDays,
                                     value: bucket)
    }

    /// Fires a pixel when the monthly subscription offer is selected.
    func fireOfferSelectionMonthlyPixel() {
        let bucket = bucketer.bucket(for: paywallViewCount)
        experimentPixelFirer.fireExperimentPixel(for: Constants.subfeatureIdentifier,
                                     metric: Constants.metricStartClickedMonthly,
                                     conversionWindowDays: Constants.conversionWindowDays,
                                     value: bucket)
    }

    /// Fires a pixel when the yearly subscription offer is selected.
    func fireOfferSelectionYearlyPixel() {
        let bucket = bucketer.bucket(for: paywallViewCount)
        experimentPixelFirer.fireExperimentPixel(for: Constants.subfeatureIdentifier,
                                     metric: Constants.metricStartClickedYearly,
                                     conversionWindowDays: Constants.conversionWindowDays,
                                     value: bucket)
    }

    /// Fires a pixel when a monthly subscription is started.
    func fireSubscriptionStartedMonthlyPixel() {
        let bucket = bucketer.bucket(for: paywallViewCount)
        experimentPixelFirer.fireExperimentPixel(for: Constants.subfeatureIdentifier,
                                     metric: Constants.metricSubscriptionStartedMonthly,
                                     conversionWindowDays: Constants.conversionWindowDays,
                                     value: bucket)
    }

    /// Fires a pixel when a yearly subscription is started.
    func fireSubscriptionStartedYearlyPixel() {
        let bucket = bucketer.bucket(for: paywallViewCount)
        experimentPixelFirer.fireExperimentPixel(for: Constants.subfeatureIdentifier,
                                     metric: Constants.metricSubscriptionStartedYearly,
                                     conversionWindowDays: Constants.conversionWindowDays,
                                     value: bucket)
    }
}

private extension FreeTrialsFeatureFlagExperiment {
    /// Computed property for managing the paywall view count in persistent storage.
    var paywallViewCount: Int {
        get {
            storage.object(forKey: Constants.paywallViewCountKey) as? Int ?? 0
        }
        set {
            storage.set(newValue, forKey: Constants.paywallViewCountKey)
        }
    }

    /// Determines if the user is within the conversion window for the experiment.
    var userIsInConversionWindow: Bool {
        guard let enrollmentDate = featureFlagger.allActiveExperiments[rawValue]?.enrollmentDate else {
            return false
        }

        let startOfWindow = enrollmentDate.addingDays(Constants.conversionWindowDays.lowerBound)
        let endOfWindow = enrollmentDate.addingDays(Constants.conversionWindowDays.upperBound)

        let today = Date().startOfDay()
        return today >= startOfWindow && today <= endOfWindow
    }
}

private extension Date {
    /// Returns a new `Date` by adding the specified number of days to the current date.
    /// - Parameter days: The number of days to add. Negative values subtract days.
    /// - Returns: A new `Date` instance.
    func addingDays(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }

    /// Returns the start of the day for the current date.
    /// - Returns: A `Date` representing the beginning of the day.
    func startOfDay() -> Date {
        Calendar.current.startOfDay(for: self)
    }
}
