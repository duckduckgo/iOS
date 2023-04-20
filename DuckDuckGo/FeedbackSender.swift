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
import BrowserServicesKit
import Common
import Networking

/// Represents single component that is being sent to the server.
/// Feedback as a whole can consist of multiple components. These components are included both in
/// message sent to the server and in pixels.
protocol FeedbackComponent {
    var component: String { get }
}

protocol FeedbackSender {

    func submitPositiveSentiment(message: String)
    func submitNegativeSentiment(message: String, url: String?, model: Feedback.Model)
    
    func firePositiveSentimentPixel()
    func fireNegativeSentimentPixel(with model: Feedback.Model)
}

struct FeedbackSubmitter: FeedbackSender {

    private enum Rating: String {
        case positive
        case negative
    }

    private let statisticsStore: StatisticsStore
    private let versionProvider: AppVersion

    init(statisticsStore: StatisticsStore = StatisticsUserDefaults(), versionProvider: AppVersion = AppVersion.shared) {
        self.statisticsStore = statisticsStore
        self.versionProvider = versionProvider
    }

    public func submitPositiveSentiment(message: String) {
        submitFeedback(rating: .positive, url: nil, comment: message)
    }
    
    public func submitNegativeSentiment(message: String, url: String?, model: Feedback.Model) {
        submitFeedback(rating: .negative, url: url, comment: message, model: model)
    }

    private func submitFeedback(rating: Rating?,
                                url: String?,
                                comment: String,
                                model: Feedback.Model? = nil) {

        let normalizedUrlString: String
        if let urlString = url, let normalizedURL = URL(string: urlString)?.normalized() {
            normalizedUrlString = normalizedURL.absoluteString
        } else {
            normalizedUrlString = url ?? ""
        }

        let parameters = [
            "reason": "general",
            "rating": rating?.rawValue ?? "",
            "url": normalizedUrlString,
            "comment": comment,
            "category": model?.category?.component ?? "",
            "subcategory": model?.subcategory?.component ?? "",
            "platform": "iOS",
            "os": UIDevice.current.systemVersion,
            "manufacturer": "Apple",
            "model": UIDevice.current.model,
            "v": versionProvider.versionAndBuildNumber,
            "atb": statisticsStore.atbWithVariant ?? ""
        ]
        
        let configuration = APIRequest.Configuration(url: URL.feedback, method: .post, queryParameters: parameters)
        let request = APIRequest(configuration: configuration, urlSession: .session())
        
        request.fetch { _, error in
            if let error = error {
                os_log("Feedback request failed, %s", log: .generalLog, type: .debug, error.localizedDescription)
            } else {
                os_log("Feedback response successful", log: .generalLog, type: .debug)
            }
        }
    }
    
    public func firePositiveSentimentPixel() {
        Pixel.fire(pixel: .feedbackPositive)
    }
    
    public func fireNegativeSentimentPixel(with model: Feedback.Model) {
        guard var category = model.category?.component else { return }
                
        if let subcategory = model.subcategory {
            category += "_" + subcategory.component
        } else {
            category += "_submit"
        }
        
        let pixel = Pixel.Event.feedbackNegativePrefix(category: category)
        Pixel.fire(pixel: pixel)
    }
}
