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
    
    func start(completion: AppConfigurationCompletion?) {

        DispatchQueue.global(qos: .background).async {

            var newData = false
            let semaphore = DispatchSemaphore(value: 0)

            AppDependencyProvider.shared.storageCache.update { newCache in
                newData = newData || (newCache != nil)
                semaphore.signal()
            }

            semaphore.wait()
            completion?(newData)
        }
    }
}
