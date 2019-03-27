//
//  FeedbackPresenter.swift
//  DuckDuckGo
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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

struct FeedbackPresenter {
    
    public static func title(for category: Feedback.Category) -> String {
        switch category {
        case .browserFeatureIssues:
            return UserText.browserFeatureIssuesDescription
        case .websiteLoadingIssues:
            return UserText.websiteLoadingIssuesDescription
        case .ddgSearchIssues:
            return UserText.ddgSearchIssuesDescription
        case .customizationIssues:
            return UserText.customizationIssuesDescription
        case .performanceIssues:
            return UserText.performanceIssuesDescription
        case .otherIssues:
            return UserText.otherIssuesDescription
        }
    }
    
    public static func subtitle(for category: Feedback.Category) -> String {
        switch category {
        case .browserFeatureIssues:
            return UserText.browserFeatureIssuesCaption
        case .websiteLoadingIssues:
            return UserText.feedbackFormCaption
        case .ddgSearchIssues:
            return UserText.ddgSearchIssuesCaption
        case .customizationIssues:
            return UserText.customizationIssuesCaption
        case .performanceIssues:
            return UserText.performanceIssuesCaption
        case .otherIssues:
            return UserText.feedbackFormCaption
        }
    }
    
    public static func subtitle(for subcategory: FeedbackEntry) -> String {
        if subcategory.isGeneric {
            return UserText.feedbackFormCaption
        }
        return subcategory.userText
    }
    
    public static func messagePlaceholder(for subcategory: FeedbackEntry?) -> String {
        if subcategory?.isGeneric == false {
            return UserText.feedbackNegativeFormPlaceholder
        }
        return UserText.feedbackNegativeFormGenericPlaceholder
    }
}
