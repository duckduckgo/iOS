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
import DuckUI
import Core

final class FireButtonExperiment {
    
    static let calendarUTC = {
        var calendarUTC = Calendar(identifier: .gregorian)
        calendarUTC.timeZone = TimeZone(identifier: "UTC")!
        return calendarUTC
    }()
    
    // MARK: - Experiment #1 - adding fire button animation

    public static func playFireButtonAnimationOnTabSwitcher(fireButton: FireButton,
                                                            tabCount: Int) {
        guard isFireButtonAnimationFeatureEnabled,
              tabCount > 1,
              !wasFireButtonEverTapped
        else { return }
        
        fireButton.playAnimation()
    }
    
    public static func playFireButtonForOnboarding(fireButton: FireButton) {
        guard isFireButtonAnimationFeatureEnabled else { return }
        
        fireButton.playAnimation()
    }
    
    private static var isFireButtonAnimationFeatureEnabled: Bool {
        #warning("Define and check feature availability for variant")
        return true
        
//        AppDependencyProvider.shared.variantManager.isSupported(feature: .fireButtonAnimation)
    }
    
    private static var wasFireButtonEverTapped: Bool {
        return false
        #warning("check from user defaults")
    }
    
    public static func restartFireButtonEducationIfNeeded() {
        guard !wasFireButtonEverTapped,
              isAtLeastThreeDaysFromInstallation
        else { return }
              
        DefaultDaxDialogsSettings().fireButtonEducationShownOrExpired = false
        DefaultDaxDialogsSettings().fireButtonPulseDateShown = nil
    }
    
    private static var isAtLeastThreeDaysFromInstallation: Bool {
        guard let installDate = StatisticsUserDefaults().installDate,
              let daysSinceInstall = calendarUTC.numberOfCalendarDaysBetween(installDate, and: Date())
        else { return false }

        return true
        #warning("remove hardcoded condition")
//        return daysSinceInstall >= 3        
    }
    
    //
    // MARK: - Experiment #2 - adding fire button color
    //
    
     public static func decorateFireButton(fireButton: UIBarButtonItem, for theme: Theme) {
         guard isFireButtonColorFeatureEnabled else { return }

         fireButton.tintColor = fireButtonFillColor(for: theme)
     }

     public static func decorateFireButton(fireButton: UIButton, for theme: Theme) {
         guard isFireButtonColorFeatureEnabled else { return }

         fireButton.tintColor = fireButtonFillColor(for: theme)
     }
    
    private static var isFireButtonColorFeatureEnabled: Bool {
         AppDependencyProvider.shared.variantManager.isSupported(feature: .fireButtonColor)
     }

     private static func fireButtonFillColor(for theme: Theme) -> UIColor {
         theme.currentImageSet == .light ? .redBase : .red40
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
