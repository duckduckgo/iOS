//
//  DuckPlayerExperimentTests.swift
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

import XCTest
@testable import DuckDuckGo
import Core

public class MockDuckPlayerExperimentDateProvider: DuckPlayerExperimentDateProvider {
    private var customDate: Date?
    
    public var currentDate: Date {
        return customDate ?? Date()
    }
    
    public init(customDate: Date? = nil) {
        self.customDate = customDate
    }
    
    public func setCurrentDate(_ date: Date) {
        self.customDate = date
    }
    
    public func resetToCurrentDate() {
        self.customDate = nil
    }
}


final class DuckPlayerExperimentPixelFireMock: DuckPlayerExperimentPixelFiring {

    static private(set) var capturedPixelEventHistory: [(pixel: Pixel.Event, params: [String: String])] = []

    static func fireDuckPlayerExperimentPixel(pixel: Pixel.Event, withAdditionalParameters params: [String: String]) {
        capturedPixelEventHistory.append((pixel: pixel, params: params))
    }

    static func tearDown() {
        capturedPixelEventHistory = []
    }
}


final class DuckPlayerExperimentDailyPixelFireMock: DuckPlayerExperimentPixelFiring {

    static private(set) var capturedPixelEventHistory: [(pixel: Pixel.Event, params: [String: String])] = []

    static func fireDuckPlayerExperimentPixel(pixel: Pixel.Event, withAdditionalParameters params: [String: String]) {
        capturedPixelEventHistory.append((pixel: pixel, params: params))
    }

    static func tearDown() {
        capturedPixelEventHistory = []
    }
}


final class DuckPlayerLaunchExperimentTests: XCTestCase {

    private var sut: DuckPlayerLaunchExperiment!
    private var userDefaults: UserDefaults!
    private var dateProvider = MockDuckPlayerExperimentDateProvider()

    override func setUp() {
        super.setUp()
        // Setting up a temporary UserDefaults to isolate tests
        userDefaults = UserDefaults(suiteName: "DuckPlayerLaunchExperimentTests")
        userDefaults.removePersistentDomain(forName: "DuckPlayerLaunchExperimentTests")
    }

    override func tearDown() {
        sut = nil
        userDefaults = nil
        DuckPlayerExperimentPixelFireMock.tearDown()
        DuckPlayerExperimentDailyPixelFireMock.tearDown()
        super.tearDown()
    }

    func testAssignUserToCohort_AssignsCohotsAndFiresPixels() {

        // Set a fixed date to 2024.09.10
        dateProvider.setCurrentDate(Date(timeIntervalSince1970: 1725926400))

        let sut = DuckPlayerLaunchExperiment(userDefaults: userDefaults,
                                             pixel: DuckPlayerExperimentPixelFireMock.self,
                                             dateProvider: dateProvider)

        sut.cleanup()
        XCTAssertFalse(sut.isEnrolled, "User should not be enrolled initially.")

        sut.assignUserToCohort()

        XCTAssertTrue(sut.isEnrolled, "User should be enrolled after assigning to cohort.")
        XCTAssertNotNil(sut.experimentCohortV2, "Experiment cohort should be assigned.")
        XCTAssertNotNil(sut.enrollmentDateV2, "Enrollment date should be set.")
        XCTAssertEqual(DuckPlayerLaunchExperiment.formattedDate(sut.enrollmentDateV2 ?? Date()), "20240910", "The assigned date should match.")

        // Check the pixel event history
        let history = DuckPlayerExperimentPixelFireMock.capturedPixelEventHistory
        XCTAssertEqual(history.count, 1, "One pixel event should be fired.")
        if let firstEvent = history.first {
            XCTAssertEqual(firstEvent.pixel, .duckplayerExperimentCohortAssign, "Enrollment pixel should be duckplayerExperimentCohortAssign")
            XCTAssert(["control", "experiment"].contains(firstEvent.params["variant"]), "The variant is incorrect")
            XCTAssertEqual(firstEvent.params["enrollment"], "20240910", "The assigned date should be valid.")
        }
    }

    func testAssignUserToCohortMultipleTimes_DoesNotReassignNorFiresMultiplePixels() {

        // Set a fixed date to 2024.09.10
        dateProvider.setCurrentDate(Date(timeIntervalSince1970: 1725926400))

        let sut = DuckPlayerLaunchExperiment(userDefaults: userDefaults,
                                             pixel: DuckPlayerExperimentPixelFireMock.self,
                                             dateProvider: dateProvider)

        sut.cleanup()
        XCTAssertFalse(sut.isEnrolled, "User should not be enrolled initially.")

        sut.assignUserToCohort()
        XCTAssertEqual(DuckPlayerExperimentPixelFireMock.capturedPixelEventHistory.count, 1, "Enrollment pixel should have fired")

        DuckPlayerExperimentPixelFireMock.tearDown()

        // Change the date to something in the future
        dateProvider.setCurrentDate(Date(timeIntervalSince1970: 1726185600))
        sut.assignUserToCohort()
        XCTAssertEqual(DuckPlayerExperimentPixelFireMock.capturedPixelEventHistory.count, 0, "Enrollment pixel should not have fired again")
        XCTAssertEqual(sut.isEnrolled, true, "The assigned date should not change.")
        XCTAssertEqual(DuckPlayerLaunchExperiment.formattedDate(sut.enrollmentDateV2 ?? Date()), "20240910", "The assigned date should not change.")
    }
    
    func testIfUserIsEnrolled_SearchDailyPixelsFire() {
        
        // Set a fixed date to 2024.09.10
        let startDate: Double = 1725926400
        
        dateProvider.setCurrentDate(Date(timeIntervalSince1970: startDate))
        
        let sut = DuckPlayerLaunchExperiment(userDefaults: userDefaults,
                                             pixel: DuckPlayerExperimentPixelFireMock.self,
                                             dateProvider: dateProvider)
        sut.cleanup()
                
        sut.assignUserToCohort()
        
        for day in 0...14 {
            dateProvider.setCurrentDate(Date(timeIntervalSince1970: startDate + (Double(day) * 86400)))
            
            // Fire a random number of search pixels per day, but only one should be registered
            for _ in 1...Int.random(in: 1..<10) {
                sut.fireSearchPixels()
            }
        }
        
        let history = DuckPlayerExperimentPixelFireMock.capturedPixelEventHistory
        let dailyPixel = history.filter { $0.pixel == .duckplayerExperimentDailySearch }
        
        // Assign cohort
        XCTAssertEqual(dailyPixel.count, 15, "There must be 15 daily pixels")
        
        for (index, value) in dailyPixel.enumerated() {
            XCTAssertEqual(value.params["day"], "\(index)")
            XCTAssert(["control", "experiment"].contains(value.params["variant"]), "The variant is incorrect")
            XCTAssertEqual(value.params["enrollment"], "20240910", "The assigned date is incorrect.")
        }
        
    }
    
    func testIfUserIsEnrolled_SearchDailyPixelsFireWhenNotUsedDaily() {
        
        // Set a fixed date to 2024.09.10
        let startDate: Double = 1725926400
        
        dateProvider.setCurrentDate(Date(timeIntervalSince1970: startDate))
        
        let sut = DuckPlayerLaunchExperiment(userDefaults: userDefaults,
                                             pixel: DuckPlayerExperimentPixelFireMock.self,
                                             dateProvider: dateProvider)
        sut.cleanup()
        
        // Assign cohort
        sut.assignUserToCohort()
        
        let fireDays = [0, 4, 11, 12]
        for day in fireDays {
            dateProvider.setCurrentDate(Date(timeIntervalSince1970: startDate + (Double(day) * 86400)))
            
            // Fire a random number of search pixels per day, but only one should be registered
            for _ in 1...Int.random(in: 1..<10) {
                sut.fireSearchPixels()
            }
        }
        
        let history = DuckPlayerExperimentPixelFireMock.capturedPixelEventHistory
        let dailyPixel = history.filter { $0.pixel == .duckplayerExperimentDailySearch }
                
        XCTAssertEqual(dailyPixel.count, 4, "There must be 4 daily pixels")
        
        if dailyPixel.count == 4 {
            XCTAssertEqual(dailyPixel[0].params["day"], "0")
            XCTAssertEqual(dailyPixel[1].params["day"], "4")
            XCTAssertEqual(dailyPixel[2].params["day"], "11")
            XCTAssertEqual(dailyPixel[3].params["day"], "12")
        }
    }
    
    func testIfUserIsEnrolled_WeeklyPixelsFire() {
        
        // Set a fixed date to 2024.09.10
        let startDate: Double = 1725926400
        
        dateProvider.setCurrentDate(Date(timeIntervalSince1970: startDate))
        
        let sut = DuckPlayerLaunchExperiment(userDefaults: userDefaults,
                                             pixel: DuckPlayerExperimentPixelFireMock.self,
                                             dateProvider: dateProvider)
        sut.cleanup()
        
        // Assign cohort
        sut.assignUserToCohort()
        
        for day in 0...13 {
            dateProvider.setCurrentDate(Date(timeIntervalSince1970: startDate + (Double(day) * 86400)))
            
            // Fire a random number of search pixels per day, but only one should be registered
            for _ in 1...Int.random(in: 1..<10) {
                sut.fireSearchPixels()
            }
        }
        
        let history = DuckPlayerExperimentPixelFireMock.capturedPixelEventHistory
        let weeklyPixel = history.filter { $0.pixel == .duckplayerExperimentWeeklySearch }
                
        XCTAssertEqual(weeklyPixel.count, 2, "There must be 2 weekly pixels")
        
        for (index, value) in weeklyPixel.enumerated() {
            XCTAssertEqual(value.params["week"], "\(index+1)")
            XCTAssert(["control", "experiment"].contains(value.params["variant"]), "The variant is incorrect")
            XCTAssertEqual(value.params["enrollment"], "20240910", "The assigned date is incorrect.")

        }
        
    }
    
    func testIfUserIsEnrolled_WeeklyPixelsFireWhenNotUsedDaily() {
        
        // Set a fixed date to 2024.09.10
        let startDate: Double = 1725926400
        
        dateProvider.setCurrentDate(Date(timeIntervalSince1970: startDate))
        
        let sut = DuckPlayerLaunchExperiment(userDefaults: userDefaults,
                                             pixel: DuckPlayerExperimentPixelFireMock.self,
                                             dateProvider: dateProvider)
        sut.cleanup()
        
        // Assign cohort
        sut.assignUserToCohort()
        
        let fireDays = [0, 6, 11, 12]
        for day in fireDays {
            dateProvider.setCurrentDate(Date(timeIntervalSince1970: startDate + (Double(day) * 86400)))
            
            // Fire a random number of search pixels per day
            for _ in 1...Int.random(in: 1..<10) {
                sut.fireSearchPixels()
            }
        }
        
        let history = DuckPlayerExperimentPixelFireMock.capturedPixelEventHistory
        let weeklyPixel = history.filter { $0.pixel == .duckplayerExperimentWeeklySearch }
        
        XCTAssertEqual(weeklyPixel.count, 2, "There must be 2 weekly pixels")
        
        if weeklyPixel.count == 2 {
            XCTAssertEqual(weeklyPixel[0].params["week"], "1")
            XCTAssertEqual(weeklyPixel[1].params["week"], "2")
        }
        
    }
    
    func testIfUserIsEnrolled_WeeklyPixelsFireWhenNotUsedWeek2() {
        
        // Set a fixed date to 2024.09.10
        let startDate: Double = 1725926400
        
        dateProvider.setCurrentDate(Date(timeIntervalSince1970: startDate))
        
        let sut = DuckPlayerLaunchExperiment(userDefaults: userDefaults,
                                             pixel: DuckPlayerExperimentPixelFireMock.self,
                                             dateProvider: dateProvider)
        sut.cleanup()
                
        sut.assignUserToCohort()
        
        let fireDays = [0, 2, 3, 6]
        for day in fireDays {
            dateProvider.setCurrentDate(Date(timeIntervalSince1970: startDate + (Double(day) * 86400)))
            
            // Fire a random number of search pixels per day
            for _ in 1...Int.random(in: 1..<10) {
                sut.fireSearchPixels()
            }
        }
        
        let history = DuckPlayerExperimentPixelFireMock.capturedPixelEventHistory
        let weeklyPixel = history.filter { $0.pixel == .duckplayerExperimentWeeklySearch }
        
        // Assign cohort
        XCTAssertEqual(weeklyPixel.count, 1, "There must be 2 weekly pixels")
        
        if weeklyPixel.count == 2 {
            XCTAssertEqual(weeklyPixel[0].params["week"], "1")
        }
        
    }
    
    func testIfUserIsEnrolled_WeeklyPixelsFireWhenNotUsedWeek1() {
        
        // Set a fixed date to 2024.09.10
        let startDate: Double = 1725926400
        
        dateProvider.setCurrentDate(Date(timeIntervalSince1970: startDate))
        
        let sut = DuckPlayerLaunchExperiment(userDefaults: userDefaults,
                                             pixel: DuckPlayerExperimentPixelFireMock.self,
                                             dateProvider: dateProvider)
        sut.cleanup()
        
        // Assign cohort
        sut.assignUserToCohort()
        
        let fireDays = [0, 8, 9, 12]
        for day in fireDays {
            dateProvider.setCurrentDate(Date(timeIntervalSince1970: startDate + (Double(day) * 86400)))
            
            // Fire a random number of search pixels per day
            for _ in 1...Int.random(in: 1..<10) {
                sut.fireSearchPixels()
            }
        }
        
        let history = DuckPlayerExperimentPixelFireMock.capturedPixelEventHistory
        let weeklyPixel = history.filter { $0.pixel == .duckplayerExperimentWeeklySearch }
        
        XCTAssertEqual(weeklyPixel.count, 1, "There must be 2 weekly pixels")
        
        if weeklyPixel.count == 2 {
            XCTAssertEqual(weeklyPixel[0].params["week"], "2")
        }
        
    }
    
    func testIfUserIsEnrolled_SearchPixelFires() {
        
        // Set a fixed date to 2024.09.10
        let startDate: Double = 1725926400
        
        dateProvider.setCurrentDate(Date(timeIntervalSince1970: startDate))
        
        let sut = DuckPlayerLaunchExperiment(userDefaults: userDefaults,
                                             pixel: DuckPlayerExperimentPixelFireMock.self,
                                             dateProvider: dateProvider)
        sut.cleanup()
        
        // Assign cohort
        sut.assignUserToCohort()
        
        dateProvider.setCurrentDate(Date(timeIntervalSince1970: startDate))
        sut.fireSearchPixels()
        
        let history = DuckPlayerExperimentPixelFireMock.capturedPixelEventHistory
        
        let searchPixel = history.filter { $0.pixel == .duckplayerExperimentSearch }
        
        if history.count == 1 {
            XCTAssert(["control", "experiment"].contains(searchPixel.first?.params["variant"]), "The variant is incorrect")
            XCTAssertEqual(searchPixel.first?.params["enrollment"], "20240910", "The assigned date should be valid.")
        }
        
    }
    
    func testIfUserIsEnrolled_YoutubePixelFires() {
        
        // Set a fixed date to 2024.09.10
        let startDate: Double = 1725926400
        
        dateProvider.setCurrentDate(Date(timeIntervalSince1970: startDate))
                
        let sut = DuckPlayerLaunchExperiment(duckPlayerMode: .alwaysAsk,
                                             referrer: .serp,
                                             pixel: DuckPlayerExperimentPixelFireMock.self,
                                             dateProvider: dateProvider)
        sut.cleanup()
        
        sut.assignUserToCohort()
        
        XCTAssertTrue(sut.isEnrolled, "User should be enrolled after assigning to cohort.")
        
        dateProvider.setCurrentDate(Date(timeIntervalSince1970: startDate + (3 * 86400))) // Day 3
        sut.fireYoutubePixel(videoID: "testVideoID")
        
        let history = DuckPlayerExperimentPixelFireMock.capturedPixelEventHistory
        let youtubePixel = history.filter { $0.pixel == .duckplayerExperimentYoutubePageView }
        
        // Validate that one YouTube pixel was fired
        XCTAssertEqual(youtubePixel.count, 1, "There should be exactly one YouTube pixel fired.")
        
        if let firedPixel = youtubePixel.first {
            XCTAssertEqual(firedPixel.params["day"], "3", "The day parameter is incorrect.")
            XCTAssert(["control", "experiment"].contains(firedPixel.params["variant"]), "The variant is incorrect.")
            XCTAssertEqual(firedPixel.params["enrollment"], "20240910", "The enrollment date should be valid.")
            XCTAssertEqual(firedPixel.params["state"], "alwaysAsk", "The state parameter is incorrect.")
            XCTAssertEqual(firedPixel.params["referrer"], "serp", "The referrer parameter is incorrect.")
        }
        
    }
    
}
