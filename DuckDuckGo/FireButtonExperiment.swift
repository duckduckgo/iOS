//
//  FireButtonExperiment.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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

import UIKit
import Core

final class FireButtonExperiment {
    
    static let calendarUTC = {
        var calendarUTC = Calendar(identifier: .gregorian)
        calendarUTC.timeZone = TimeZone(identifier: "UTC")!
        return calendarUTC
    }()
    
    public static var wasFireButtonEverTapped: Bool {
        AppUserDefaults().wasFireButtonEverTapped
    }
    
    public static func storeThatFireButtonWasTapped() {
        AppUserDefaults().wasFireButtonEverTapped = true
    }
    
    public static func restartFireButtonEducationIfNeeded() {
        guard !AppUserDefaults().wasFireButtonEducationRestarted,
              !wasFireButtonEverTapped,
              isAtLeastThreeDaysFromInstallation
        else { return }
              
        DefaultDaxDialogsSettings().fireButtonEducationShownOrExpired = false
        DefaultDaxDialogsSettings().fireButtonPulseDateShown = nil
        
        AppUserDefaults().wasFireButtonEducationRestarted = true
    }
    
    private static var isAtLeastThreeDaysFromInstallation: Bool {
        guard let installDate = StatisticsUserDefaults().installDate,
              let daysSinceInstall = calendarUTC.numberOfCalendarDaysBetween(installDate, and: Date())
        else { return false }

        return daysSinceInstall >= 3
    }
    
}

extension Calendar {
    
    func numberOfCalendarDaysBetween(_ from: Date, and to: Date) -> Int? {
        let fromDate = startOfDay(for: from)
        let toDate = startOfDay(for: to)
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate)
        
        return numberOfDays.day
    }
    
}
