//
//  DuckPlayerLaunchExperiment.swift
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

protocol DuckPlayerExperimentHandling {
    var isEnrolled: Bool { get }
    var enrollmentDate: Date? { get set }
    var experimentCohort: String? { get set }
    init(referrer: DuckPlayerReferrer, duckPlayerMode: DuckPlayerMode?)
    func assignUserToCohort()
    func fireEnrollmentPixel()
    func fireSearchPixels()
    func fireYoutubePixel()
}

final class DuckPlayerLaunchExperiment: DuckPlayerExperimentHandling {
        
    private struct Constants {
        static let dateFormat = "yyyyMMDD"
        static let enrollmentKey = "enrollment"
        static let variantKey = "variant"
        static let dayKey = "day"
        static let weekKey = "week"
        static let stateKey = "state"
        static let referrerKey = "referrer"
    }
    
    private let referrer: DuckPlayerReferrer
    private let duckPlayerMode: DuckPlayerMode?
            
    @UserDefaultsWrapper(key: .duckPlayerPixelExperimentEnrollmentDate, defaultValue: nil)
    var enrollmentDate: Date?

    @UserDefaultsWrapper(key: .duckPlayerPixelExperimentCohort, defaultValue: nil)
    var experimentCohort: String?
    
    @UserDefaultsWrapper(key: .duckPlayerPixelExperimentLastWeekPixelFired, defaultValue: nil)
    var lastWeekPixelFired: String?
    
    
    enum Cohort: String {
        case control
        case experiment
    }
    
    init(referrer: DuckPlayerReferrer, duckPlayerMode: DuckPlayerMode?) {
        self.referrer = referrer
        self.duckPlayerMode = duckPlayerMode
    }
    
    var isEnrolled: Bool {
        return enrollmentDate != nil && experimentCohort != nil
    }
    
    private func getPixelParameters() -> [String: String]? {
        guard isEnrolled,
              let experimentCohort = experimentCohort,
              let enrollmentDate = enrollmentDate else { return nil }

        let currentDate = Date()
        let calendar = Calendar.current
        let dayDifference = calendar.dateComponents([.day], from: enrollmentDate, to: currentDate).day ?? 0
        let weekDifference = dayDifference / 7
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.dateFormat
        let enrollmentDateString = dateFormatter.string(from: enrollmentDate)
        
        return [
            Constants.enrollmentKey: enrollmentDateString,
            Constants.variantKey: experimentCohort,
            Constants.dayKey: "\(dayDifference)",
            Constants.weekKey: "\(weekDifference+1)",
            Constants.stateKey: duckPlayerMode?.stringValue ?? "",
            Constants.referrerKey: referrer.stringValue
        ]
    }
    
    func assignUserToCohort() {
        if !isEnrolled {
            //let cohort: Cohort = Bool.random() ? .experiment : .control
            let cohort: Cohort = Bool.random() ? .experiment : .control
            experimentCohort = cohort.rawValue
            enrollmentDate = Date()
            fireEnrollmentPixel()
        }
    }

    func fireEnrollmentPixel() {
        guard isEnrolled, let params = getPixelParameters() else {
            return
        }
        Pixel.fire(pixel: .duckplayerExperimentCohortAssign, withAdditionalParameters: params)
    }
    
    func fireSearchPixels() {
        if isEnrolled {
            guard isEnrolled, let params = getPixelParameters() else {
                return
            }
            Pixel.fire(pixel: .duckplayerExperimentSearch, withAdditionalParameters: params)
            DailyPixel.fire(pixel: .duckplayerExperimentDailySearch, withAdditionalParameters: params)
            
            if params[Constants.weekKey] != lastWeekPixelFired {
                Pixel.fire(pixel: .duckplayerExperimentWeeklySearch, withAdditionalParameters: params)
                lastWeekPixelFired = params[Constants.weekKey]
            }
        }
    }
    
    func fireYoutubePixel() {
        guard isEnrolled, let params = getPixelParameters() else {
            return
        }
        Pixel.fire(pixel: .duckplayerExperimentYoutubePageView, withAdditionalParameters: params)
    }
    
}
