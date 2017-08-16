//
//  StatisticsLoader.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

public class StatisticsLoader {
    
    public static let shared = StatisticsLoader()
    private var statisticsStore: StatisticsStore
    
    init(statisticsStore: StatisticsStore = StatisticsUserDefaults()) {
        self.statisticsStore = statisticsStore
    }
    
    public func load() {
        if statisticsStore.cohortVersion != nil {
            return
        }

        let request = CohortRequest()
        request.execute { cohort, error in
            guard let cohort = cohort else {
                let errorMessage = error?.localizedDescription ?? "unspecified"
                Logger.log(text: "Cohort atb request failed with error \(errorMessage)")
                return
            }
            self.statisticsStore.cohortVersion = cohort.version
        }
    }
}
