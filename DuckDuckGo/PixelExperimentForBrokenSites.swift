//
//  PixelExperimentForBrokenSites.swift
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
import Core

// This class serves the singular purpose of facilitating a specific experiment, necessitated by the limitation of the current API, which precludes running multiple experiments concurrently. It will be removed once this experiment is concluded.
public enum PixelExperimentForBrokenSites: String, CaseIterable {

    fileprivate static var logic: PixelExperimentLogic { defaultLogic }
    fileprivate static let defaultLogic = PixelExperimentLogic {
        Pixel.fire(pixel: $0, withAdditionalParameters: PixelExperimentForBrokenSites.parameters)
    }

    /// When `cohort` is accessed for the first time after the experiment is installed with `install()`,
    ///  allocate and return a cohort.  Subsequently, return the same cohort.
    public static var cohort: PixelExperimentForBrokenSites? {
        logic.cohort
    }

    static var isExperimentInstalled: Bool {
        logic.isInstalled
    }

    static var allocatedCohortDoesNotMatchCurrentCohorts: Bool {
        guard let allocatedCohort = logic.allocatedCohort else { return false }
        if PixelExperimentForBrokenSites(rawValue: allocatedCohort) == nil {
            return true
        }
        return false
    }

    /// Enables this experiment for new users when called from the new installation path.
    public static func install() {
        // Disable the experiment until all other experiments are finished
        logic.install()
    }

    static func cleanup() {
        logic.cleanup()
    }

    // Internal state for users not included in any variant
    case noVariant

    case reloadTwiceWithin12SecondsShowsPrompt
    case reloadTwiceWithin24SecondsShowsPrompt

    case reloadAndRestartWithin30SecondsShowsPrompt
    case reloadAndRestartWithin50SecondsShowsPrompt

    case reloadThreeTimesWithin20SecondsShowsPrompt
    case reloadThreeTimesWithin40SecondsShowsPrompt

}

extension PixelExperimentForBrokenSites {

    // Pixel parameter - cohort
    public static var parameters: [String: String] {
        guard let cohort, cohort != .noVariant else {
            return [:]
        }

        return [PixelParameters.cohort: cohort.rawValue]
    }

}

final internal class PixelExperimentLogic {

    private let promptCohorts: [PixelExperimentForBrokenSites] = [
        .reloadTwiceWithin12SecondsShowsPrompt,
        .reloadTwiceWithin24SecondsShowsPrompt,
        .reloadAndRestartWithin30SecondsShowsPrompt,
        .reloadAndRestartWithin50SecondsShowsPrompt,
        .reloadThreeTimesWithin20SecondsShowsPrompt,
        .reloadThreeTimesWithin40SecondsShowsPrompt
    ]

    var cohort: PixelExperimentForBrokenSites? {
        guard isInstalled else { return nil }

        // Check if a cohort is already allocated and valid
        if let allocatedCohort,
           let cohort = PixelExperimentForBrokenSites(rawValue: allocatedCohort) {
            return cohort
        }

        let bucketIndex = Int.random(in: 0..<6)
        let cohort = promptCohorts[bucketIndex]

        // Store and use the selected cohort
        allocatedCohort = cohort.rawValue
        return cohort
    }

    @UserDefaultsWrapper(key: .pixelExperimentForBrokenSitesInstalled, defaultValue: false)
    var isInstalled: Bool

    @UserDefaultsWrapper(key: .pixelExperimentForBrokenSitesCohort, defaultValue: nil)
    var allocatedCohort: String?

    private let fire: (Pixel.Event) -> Void
    init(fire: @escaping (Pixel.Event) -> Void) {
        self.fire = fire
    }

    func install() {
        isInstalled = true
    }

    func cleanup() {
        isInstalled = false
        allocatedCohort = nil
    }

}
