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


// Date manipulation protocol to allow testing
public protocol DuckPlayerExperimentDateProvider {
    var currentDate: Date { get }
}

public class DefaultDuckPlayerExperimentDateProvider: DuckPlayerExperimentDateProvider {
    public var currentDate: Date {
        return Date()
    }
}

// Wrap Pixel firing in a protocol for better testing
protocol DuckPlayerExperimentPixelFiring {
    static func fireDuckPlayerExperimentPixel(pixel: Pixel.Event, withAdditionalParameters params: [String: String])
}

extension Pixel: DuckPlayerExperimentPixelFiring {
    static func fireDuckPlayerExperimentPixel(pixel: Pixel.Event, withAdditionalParameters params: [String: String]) {
        self.fire(pixel: pixel, withAdditionalParameters: params, onComplete: { _ in })
    }
}


// Experiment Protocol
protocol DuckPlayerLaunchExperimentHandling {
    var isEnrolled: Bool { get }
    var isExperimentCohort: Bool { get }
    var duckPlayerMode: DuckPlayerMode? { get set }
    func assignUserToCohort()
    func fireSearchPixels()
    func fireYoutubePixel(videoID: String)
}


final class DuckPlayerLaunchExperiment: DuckPlayerLaunchExperimentHandling {
        
    private struct Constants {
        static let dateFormat = "yyyyMMdd"
        static let enrollmentKey = "enrollment"
        static let variantKey = "variant"
        static let dayKey = "day"
        static let weekKey = "week"
        static let stateKey = "state"
        static let referrerKey = "referrer"
    }
    
    private let referrer: DuckPlayerReferrer?
    var duckPlayerMode: DuckPlayerMode?
    
    // Abstract Pixel firing for proper testing
    private let pixel: DuckPlayerExperimentPixelFiring.Type
    
    // Date Provider
    private let dateProvider: DuckPlayerExperimentDateProvider
    
    @UserDefaultsWrapper(key: .duckPlayerPixelExperimentLastWeekPixelFired, defaultValue: nil)
    private var lastWeekPixelFiredV2: Int?
    
    @UserDefaultsWrapper(key: .duckPlayerPixelExperimentLastDayPixelFired, defaultValue: nil)
    private var lastDayPixelFiredV2: Int?
       
    @UserDefaultsWrapper(key: .duckPlayerPixelExperimentLastVideoIDRendered, defaultValue: nil)
    private var lastVideoIDReportedV2: String?
    
    @UserDefaultsWrapper(key: .duckPlayerPixelExperimentEnrollmentDate, defaultValue: nil)
    var enrollmentDateV2: Date?

    @UserDefaultsWrapper(key: .duckPlayerPixelExperimentCohort, defaultValue: nil)
    var experimentCohortV2: String?
    
    private var isInternalUser: Bool
    
    enum Cohort: String {
        case control
        case experiment
    }
            
    init(duckPlayerMode: DuckPlayerMode? = nil,
         referrer: DuckPlayerReferrer? = nil,
         userDefaults: UserDefaults = UserDefaults.standard,
         pixel: DuckPlayerExperimentPixelFiring.Type = Pixel.self,
         dateProvider: DuckPlayerExperimentDateProvider = DefaultDuckPlayerExperimentDateProvider(),
         isInternalUser: Bool = false) {
        self.referrer = referrer
        self.duckPlayerMode = duckPlayerMode
        self.pixel = pixel
        self.dateProvider = dateProvider
        self.isInternalUser = isInternalUser
    }
    
    private var dates: (day: Int, week: Int)? {
        guard isEnrolled,
              let enrollmentDate = enrollmentDateV2 else { return nil }
        let currentDate = dateProvider.currentDate
        let calendar = Calendar.current
        let dayDifference = calendar.dateComponents([.day], from: enrollmentDate, to: currentDate).day ?? 0
        let weekDifference = (dayDifference / 7)  + 1
        return (day: dayDifference, week: weekDifference)
    }
    
    private var formattedEnrollmentDate: String? {
        guard isEnrolled,
              let enrollmentDate = enrollmentDateV2 else { return nil }
        return Self.formattedDate(enrollmentDate)
    }
    
    static func formattedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.dateFormat
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter.string(from: date)
    }
    
    var isEnrolled: Bool {
        return enrollmentDateV2 != nil && experimentCohortV2 != nil
    }
    
    var isExperimentCohort: Bool {
        return experimentCohortV2 == "experiment"
    }
    
    func assignUserToCohort() {
        if !isEnrolled {
            var cohort: Cohort = Bool.random() ? .experiment : .control
            
            if isInternalUser {
                cohort = .experiment
            }
            experimentCohortV2 = cohort.rawValue
            enrollmentDateV2 = dateProvider.currentDate
            fireEnrollmentPixel()
        }
    }

    private func fireEnrollmentPixel() {
        guard isEnrolled,
                let experimentCohortV2 = experimentCohortV2,
                let formattedEnrollmentDate else { return }
                
        let params = [Constants.variantKey: experimentCohortV2, Constants.enrollmentKey: formattedEnrollmentDate]
        pixel.fireDuckPlayerExperimentPixel(pixel: .duckplayerExperimentCohortAssign, withAdditionalParameters: params)
    }
    
    func fireSearchPixels() {
        if isEnrolled {
            guard isEnrolled,
                    let experimentCohortV2 = experimentCohortV2,
                    let dates,
                    let formattedEnrollmentDate else {
                return
            }
            
            var params = [
                Constants.variantKey: experimentCohortV2,
                Constants.dayKey: "\(dates.day)",
                Constants.enrollmentKey: formattedEnrollmentDate
            ]
                                    
            // Fire a base search pixel
            pixel.fireDuckPlayerExperimentPixel(pixel: .duckplayerExperimentSearch, withAdditionalParameters: params)
            
            // Fire a daily pixel
            if dates.day != lastDayPixelFiredV2 {
                pixel.fireDuckPlayerExperimentPixel(pixel: .duckplayerExperimentDailySearch, withAdditionalParameters: params)
                lastDayPixelFiredV2 = dates.day
            }
            
            // Fire a weekly pixel
            if dates.week != lastWeekPixelFiredV2 && dates.day > 0 {
                params.removeValue(forKey: Constants.dayKey)
                params[Constants.weekKey] = "\(dates.week)"
                pixel.fireDuckPlayerExperimentPixel(pixel: .duckplayerExperimentWeeklySearch, withAdditionalParameters: params)
                lastWeekPixelFiredV2 = dates.week
            }
        }
    }
    
    func fireYoutubePixel(videoID: String) {
        guard isEnrolled,
              let experimentCohortV2 = experimentCohortV2,
              let dates,
              let formattedEnrollmentDate else {
            return
        }
        
        let params = [
            Constants.variantKey: experimentCohortV2,
            Constants.dayKey: "\(dates.day)",
            Constants.stateKey: duckPlayerMode?.stringValue ?? "",
            Constants.referrerKey: referrer?.stringValue ?? "",
            Constants.enrollmentKey: formattedEnrollmentDate
        ]
        if lastVideoIDReportedV2 != videoID {
            pixel.fireDuckPlayerExperimentPixel(pixel: .duckplayerExperimentYoutubePageView, withAdditionalParameters: params)
            lastVideoIDReportedV2 = videoID
        }
    }
    
    func cleanup() {
        enrollmentDateV2 =  nil
        experimentCohortV2 = nil
        lastDayPixelFiredV2 = nil
        lastWeekPixelFiredV2 = nil
        lastVideoIDReportedV2 = nil
    }
    
    func override() {
        enrollmentDateV2 = Date()
        experimentCohortV2 = "experiment"
        lastDayPixelFiredV2 = nil
        lastWeekPixelFiredV2 = nil
        lastVideoIDReportedV2 = nil
        
    }
        
}
