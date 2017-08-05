//
//  ContentBlocker.swift
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
import Alamofire
import SafariServices


public typealias TrackerLoaderCompletion = ([Tracker]?, Error?) -> Swift.Void

public class TrackerLoader {
 
    public static let shared = TrackerLoader()
    private var trackerStore: TrackerStore
    
    init(trackerStore: TrackerStore = ContentBlockerConfigurationUserDefaults()) {
        self.trackerStore = trackerStore
    }
    
    public var storedTrackers: [Tracker]? {
        return trackerStore.trackers
    }
    
    public func updateTrackers(completion: TrackerLoaderCompletion? = nil) {
        let request = DisconnectMeRequest()
        request.execute { trackers, error in
            guard let trackers = trackers else {
                let errorMessage = error?.localizedDescription ?? "no error"
                Logger.log(text: "Trackers request failed update with error \(errorMessage)")
                self.complete(completion, withTrackers: nil, error: error)
                return
            }
            self.trackerStore.trackers = trackers
            self.complete(completion, withTrackers: trackers, error: nil)
        }
    }
    
    private func complete(_ completion: TrackerLoaderCompletion?, withTrackers trackers: [Tracker]?, error: Error?) {
        if let completion = completion {
            completion(trackers, error)
        }
    }
}

