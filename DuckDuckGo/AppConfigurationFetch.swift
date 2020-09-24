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
import BackgroundTasks
import Core

public typealias AppConfigurationCompletion = (Bool) -> Void

protocol AppConfigurationFetchStatistics {
    
    var foregroundStartCount: Int { get set }
    var foregroundNoDataCount: Int { get set }
    var foregroundNewDataCount: Int { get set }
    
    var backgroundStartCount: Int { get set }
    var backgroundNoDataCount: Int { get set }
    var backgroundNewDataCount: Int { get set }
}

class AppConfigurationFetch {
    
    private struct Constants {
        static let backgroundTaskName = "Fetch Configuration Task"
        static let backgroundProcessingTaskIdentifier = "com.duckduckgo.app.configurationRefresh"
    }
    
    private struct Keys {
        static let bgFetchStart = "bgfs"
        static let bgFetchNoData = "bgnd"
        static let bgFetchWithData = "bgwd"
        static let fgFetchStart = "fgfs"
        static let fgFetchNoData = "fgnd"
        static let fgFetchWithData = "fgwd"
    }
    
    private static let fetchQueue = DispatchQueue(label: "Config Fetch queue", qos: .utility)
    
    func start(isBackgroundFetch: Bool = false,
               completion: AppConfigurationCompletion?) {

        type(of: self).fetchQueue.async {
            let taskID = UIApplication.shared.beginBackgroundTask(withName: Constants.backgroundTaskName)
            self.markFetchStarted(isBackground: isBackgroundFetch)

            var newData = false
            let semaphore = DispatchSemaphore(value: 0)

            AppDependencyProvider.shared.storageCache.update { newCache in
                newData = newData || (newCache != nil)
                semaphore.signal()
            }

            semaphore.wait()
            
            self.markFetchCompleted(isBackground: isBackgroundFetch, hasNewData: newData)
            
            if !isBackgroundFetch {
                type(of: self).fetchQueue.async {
                    self.sendStatistics {
                        UIApplication.shared.endBackgroundTask(taskID)
                    }
                }
            } else {
                UIApplication.shared.endBackgroundTask(taskID)
            }
            completion?(newData)
        }
    }

    @available(iOS 13.0, *)
    static func registerBackgroundRefreshTaskHandler() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: AppConfigurationFetch.Constants.backgroundProcessingTaskIdentifier,
            using: fetchQueue) { (task) in

            AppConfigurationFetch().start(isBackgroundFetch: true) { newData in
                task.setTaskCompleted(success: newData)
                scheduleBackgroundRefreshTask()
            }
        }
    }

    @available(iOS 13.0, *)
    static func scheduleBackgroundRefreshTask() {
        let task = BGProcessingTaskRequest(identifier: AppConfigurationFetch.Constants.backgroundProcessingTaskIdentifier)
        task.requiresNetworkConnectivity = true
        task.earliestBeginDate = Date(timeIntervalSinceNow: 60)

        // Background tasks can be debugged by breaking on the `submit` call, stepping over, then running the following LLDB command, before resuming:
        //
        // e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.duckduckgo.app.configurationRefresh"]

        try? BGTaskScheduler.shared.submit(task)
    }
    
    private func markFetchStarted(isBackground: Bool) {
        var store: AppConfigurationFetchStatistics = AppUserDefaults()
        
        if isBackground {
            store.backgroundStartCount += 1
        } else {
            store.foregroundStartCount += 1
        }
    }
    
    private func markFetchCompleted(isBackground: Bool, hasNewData: Bool) {
        var store: AppConfigurationFetchStatistics = AppUserDefaults()
        
        if isBackground {
            if hasNewData {
                store.backgroundNewDataCount += 1
            } else {
                store.backgroundNoDataCount += 1
            }
        } else {
            if hasNewData {
                store.foregroundNewDataCount += 1
            } else {
                store.foregroundNoDataCount += 1
            }
        }
    }
    
    private func sendStatistics(completion: () -> Void ) {
        let store: AppConfigurationFetchStatistics = AppUserDefaults()
        guard store.foregroundStartCount > 0 || store.backgroundStartCount > 0 else {
            completion()
            return
        }
        
        let parameters = [Keys.bgFetchStart: String(store.backgroundStartCount),
                          Keys.bgFetchNoData: String(store.backgroundNoDataCount),
                          Keys.bgFetchWithData: String(store.backgroundNewDataCount),
                          Keys.fgFetchStart: String(store.foregroundStartCount),
                          Keys.fgFetchNoData: String(store.foregroundNoDataCount),
                          Keys.fgFetchWithData: String(store.foregroundNewDataCount)]
        
        let semaphore = DispatchSemaphore(value: 0)
        
        Pixel.fire(pixel: .configurationFetchInfo, withAdditionalParameters: parameters) { error in
            guard error == nil else {
                semaphore.signal()
                return
            }
                
            self.resetStatistics()
            semaphore.signal()
        }
        
        semaphore.wait()
        completion()
    }
    
    private func resetStatistics() {
        var store: AppConfigurationFetchStatistics = AppUserDefaults()
        
        store.backgroundStartCount = 0
        store.backgroundNoDataCount = 0
        store.backgroundNewDataCount = 0
        store.foregroundStartCount = 0
        store.foregroundNoDataCount = 0
        store.foregroundNewDataCount = 0
    }
}
