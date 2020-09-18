//
//  HomeMessageStorage.swift
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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

import Core

public class HomeMessageStorage {
    
    struct Constants {

        static let homeRowReminderTimeInDays = 3.0

    }
    
    @UserDefaultsWrapper(key: .homeDefaultBrowserMessageDateDismissed, defaultValue: nil)
    var homeDefaultBrowserMessageDateDismissed: Date?
    
    func homeMessagesThatShouldBeShown() -> [HomeMessageModel] {
        var messages = [HomeMessageModel]()
        if shouldShowDefaultBrowserMessage() {
            messages.append(HomeMessageModel.homeMessageModel(forHomeMessage: .defaultBrowserPrompt))
        }
        
        return messages
    }
    
    func hasExpiredForHomeRow() -> Bool {
        guard let date = homeDefaultBrowserMessageDateDismissed else {
            return false
        }
        let days = abs(date.timeIntervalSinceNow / 24 / 60 / 60)
        return days > Constants.homeRowReminderTimeInDays
    }
    
    private func shouldShowDefaultBrowserMessage() -> Bool {
        if #available(iOS 14, *), homeDefaultBrowserMessageDateDismissed == nil {
            return true
        }
        return false
    }

}
