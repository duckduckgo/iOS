//
//  AppTPFAQViewModel.swift
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

import Foundation

#if APP_TRACKING_PROTECTION

struct AppTPFAQViewModel {
    let question: String
    let answer: String
    
    static let faqs: [AppTPFAQViewModel] = [
        AppTPFAQViewModel(
            question: UserText.appTPFAQQuestion1,
            answer: UserText.appTPFAQAnswer1
        ),
        AppTPFAQViewModel(
            question: UserText.appTPFAQQuestion2,
            answer: UserText.appTPFAQAnswer2
        ),
        AppTPFAQViewModel(
            question: UserText.appTPFAQQuestion3,
            answer: UserText.appTPFAQAnswer3
        ),
        AppTPFAQViewModel(
            question: UserText.appTPFAQQuestion4,
            answer: UserText.appTPFAQAnswer4
        ),
        AppTPFAQViewModel(
            question: UserText.appTPFAQQuestion5,
            answer: UserText.appTPFAQAnswer5
        ),
        AppTPFAQViewModel(
            question: UserText.appTPFAQQuestion6,
            answer: UserText.appTPFAQAnswer6
        ),
        AppTPFAQViewModel(
            question: UserText.appTPFAQQuestion7,
            answer: UserText.appTPFAQAnswer7
        )
    ]
}

#endif
