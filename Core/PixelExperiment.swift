//
//  PixelExperiment.swift
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

public enum PixelExperiment: String, CaseIterable {

    fileprivate static let logic = PixelExperimentLogic {
        Pixel.fire(pixel: $0)
    }

    /// When `cohort` is accessed for the first time after the experiment is installed with `install()`,
    ///  allocate and return a cohort.  Subsequently, return the same cohort.
    public static var cohort: PixelExperiment? {
        logic.cohort
    }

    static var isExperimentInstalled: Bool {
        return logic.isInstalled
    }

    static var allocatedCohortDoesNotMatchCurrentCohorts: Bool {
        guard let allocatedCohort = logic.allocatedCohort else { return false }
        if PixelExperiment(rawValue: allocatedCohort) == nil {
            return true
        }
        return false
    }

    /// Enables this experiment for new users when called from the new installation path.
    public static func install() {
        // Disable the experiment until all other experiments are finished
        // logic.install()
    }

    static func cleanup() {
        logic.cleanup()
    }

    // These are the variants. Rename or add/remove them as needed.  If you change the string value
    //  remember to keep it clear for privacy triage.
    case control
    case newSettings = "variant1"
}

extension PixelExperiment {

    // Pixel parameter - cohort
    public static var parameters: [String: String] {
        guard let cohort else {
            return [:]
        }

        return [PixelParameters.cohort: cohort.rawValue]
    }

}

final internal class PixelExperimentLogic {

    var cohort: PixelExperiment? {
        guard isInstalled else { return nil }

        if let allocatedCohort,
           // if the stored cohort doesn't match, allocate a new one
           let cohort = PixelExperiment(rawValue: allocatedCohort) {
            return cohort
        }

        // For now, just use equal distribution of all cohorts.
        let cohort = PixelExperiment.allCases.randomElement()!
        allocatedCohort = cohort.rawValue
        fireEnrollmentPixel()
        return cohort
    }

    @UserDefaultsWrapper(key: .pixelExperimentInstalled, defaultValue: false)
    var isInstalled: Bool

    @UserDefaultsWrapper(key: .pixelExperimentCohort, defaultValue: nil)
    var allocatedCohort: String?

    private let fire: (Pixel.Event) -> Void

    init(fire: @escaping (Pixel.Event) -> Void) {
        self.fire = fire
    }

    func install() {
        isInstalled = true
    }

    func fireEnrollmentPixel() {
        Pixel.fire(pixel: .pixelExperimentEnrollment,
                   withAdditionalParameters: PixelExperiment.parameters)
    }

    func cleanup() {
        isInstalled = false
        allocatedCohort = nil
    }

}
