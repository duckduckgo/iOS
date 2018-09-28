//
//  AppConfigurationFetch.swift
//  DuckDuckGo
//
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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

public typealias AppConfigurationCompletion = (Bool) -> Void

class AppConfigurationFetch {
    
    private lazy var statisticsStore: StatisticsStore = StatisticsUserDefaults()

    func start(completion: AppConfigurationCompletion?) {

        DispatchQueue.global(qos: .background).async {

            var newData = false
            let semaphore = DispatchSemaphore(value: 0)
            
            self.sendHttpsSummaryPixel { newHttpsData in
                newData = newData || newHttpsData
                semaphore.signal()
            }

            ContentBlockerLoader().start { newContentBlockingData in
                newData = newData || newContentBlockingData
                semaphore.signal()
            }
            
            semaphore.wait()
            semaphore.wait()
            completion?(newData)
        }
    }
    
    private func sendHttpsSummaryPixel(completion: @escaping (Bool) -> Void) {
            
        if statisticsStore.httpsUpgradesTotal == 0 {
            completion(false)
            return
        }
        
        let params = [
            Pixel.EhsParameters.totalCount: "\(statisticsStore.httpsUpgradesTotal)",
            Pixel.EhsParameters.failureCount: "\(statisticsStore.httpsUpgradesFailures)"
        ]
        
        Pixel.fire(pixel: .httpsUpgradeSiteSummary, withAdditionalParameters: params) { error in
            if error == nil {
                self.statisticsStore.httpsUpgradesTotal = 0
                self.statisticsStore.httpsUpgradesFailures = 0
            }
            completion(true)
        }
    }
}
