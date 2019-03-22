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

/// Represents single component that is being sent to the server.
/// Feedback as a whole can consist of multiple components. These components are included both in
/// message sent to the server and in pixels.
protocol FeedbackComponent {
    var component: String { get }
}

protocol FeedbackSender {
    func submitBrokenSite(url: String, message: String)
    func submitMessage(_ message: String)
    
    func submitPositiveSentiment(message: String)
    func submitNegativeSentiment(message: String, url: String?, model: Feedback.Model)
    
    func firePositiveSentimentPixel()
    func fireNegativeSentimentPixel(with model: Feedback.Model)
}

struct FeedbackSubmitter: FeedbackSender {

    private enum Reason: String {
        case general = "general"
        case brokenSite = "broken_site"
    }
    
    private enum Rating: String {
        case positive
        case negative
    }

    private let statisticsStore: StatisticsStore
    private let versionProvider: AppVersion

    init(statisticsStore: StatisticsStore = StatisticsUserDefaults(), versionProvider: AppVersion = AppVersion()) {
        self.statisticsStore = statisticsStore
        self.versionProvider = versionProvider
    }

    public func submitBrokenSite(url: String, message: String) {
        submitFeedback(reason: .brokenSite, rating: nil, url: url, comment: message)
    }

    public func submitMessage(_ message: String) {
        submitFeedback(reason: .general, rating: nil, url: nil, comment: message)
    }

    public func submitPositiveSentiment(message: String) {
        submitFeedback(reason: .general, rating: .positive, url: nil, comment: message)
    }
    
    public func submitNegativeSentiment(message: String, url: String?, model: Feedback.Model) {
        submitFeedback(reason: .general, rating: .negative, url: url, comment: message, model: model)
    }

    private func submitFeedback(reason: Reason,
                                rating: Rating?,
                                url: String?,
                                comment: String,
                                model: Feedback.Model? = nil) {

        let parameters = [
            "reason": reason.rawValue,
            "rating": rating?.rawValue ?? "",
            "url": url ?? "",
            "comment": comment,
            "category": model?.category?.component ?? "",
            "subcategory": model?.subcategory?.component ?? "",
            "platform": "iOS",
            "os": UIDevice.current.systemVersion,
            "manufacturer": "Apple",
            "model": UIDevice.current.deviceType.displayName,
            "v": versionProvider.versionAndBuildNumber,
            "atb": statisticsStore.atbWithVariant ?? ""
        ]

        APIRequest.request(url: AppUrls().feedback, method: .post, parameters: parameters) { _, error in
            if let error = error {
                Logger.log(text: "Feedback request failed, \(error.localizedDescription)")
            } else {
                Logger.log(text: "Feedback response successful")
            }
        }
    }
    
    public func firePositiveSentimentPixel() {
        Pixel.fire(pixel: .feedbackPositive)
    }
    
    public func fireNegativeSentimentPixel(with model: Feedback.Model) {
        guard let category = model.category else { return }
        
        var rawPixel = PixelName.feedbackNegativePrefix.rawValue + "_" + category.component
        
        if let subcategory = model.subcategory {
            rawPixel += "_" + subcategory.component
        } else {
            rawPixel += "_submit"
        }
        
        Pixel.fire(rawPixel: rawPixel)
    }
}
