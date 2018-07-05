//
//  FeedbackSender.swift
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

protocol FeedbackSender {
    func submitBrokenSite(url: String, message: String)
    func submitMessage(message: String)
}

struct FeedbackSubmitter: FeedbackSender {
    
    private enum Reason: String {
        case general = "general"
        case brokenSite = "broken_site"
    }
    
    private let statisticsStore: StatisticsStore
    private let versionProvider: AppVersion
    
    init(statisticsStore: StatisticsStore = StatisticsUserDefaults(), versionProvider: AppVersion = AppVersion()) {
        self.statisticsStore = statisticsStore
        self.versionProvider = versionProvider
    }
    
    public func submitBrokenSite(url: String, message: String) {
        submitFeedback(reason: .brokenSite, url: url, comment: message)
    }
    
    public func submitMessage(message: String) {
        submitFeedback(reason: .general, url: nil, comment: message)
    }
    
    private func submitFeedback(reason: Reason, url: String?, comment: String) {
        
        let parameters = [
            "reason": reason.rawValue,
            "url": url ?? "",
            "comment": comment,
            "platform": "iOS",
            "os": UIDevice.current.systemVersion,
            "manufacturer": "Apple",
            "model" : UIDevice.current.deviceType.displayName,
            "v": versionProvider.versionNumberAndBuild,
            "atb": statisticsStore.atbWithVariant ?? ""
        ]
        
        APIRequest.request(url: AppUrls().feedback, method: .post, parameters:  parameters) { response, error in
            if let error = error {
                Logger.log(text: "Feedback request failed, \(error.localizedDescription)")
            } else {
                Logger.log(text: "Feedback response successful")
            }
        }
    }
}
