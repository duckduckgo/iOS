//
//  Feedback.swift
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

protocol FeedbackEntry {
    var nextStep: Feedback.NextStep { get }
    var userText: String { get }
}

class Feedback {
    
    struct Model {
        var category: Feedback.Category?
        var subcategory: FeedbackEntry?
    }
    
    enum SubmitFormType {
        case regular
        case brokenWebsite
    }
    
    enum NextStep {
        case presentEntries([FeedbackEntry])
        case presentForm(SubmitFormType)
    }
    
    struct Subcategory: FeedbackEntry {
        var nextStep: NextStep
        var userText: String
        
        init(userText: String) {
            nextStep = .presentForm(.regular)
            self.userText = userText
        }
    }

    enum Category: FeedbackEntry, CaseIterable {
        
        case browserFeatureIssues
        case websiteLoadingIssues
        case ddgSearchIssues
        case customizationIssues
        case performanceIssues
        case otherIssues
        
        var nextStep: NextStep {
            switch self {
            case .browserFeatureIssues:
                let entries = [Subcategory(userText: UserText.browserFeatureIssuesNavigation),
                               Subcategory(userText: UserText.browserFeatureIssuesTabs),
                               Subcategory(userText: UserText.browserFeatureIssuesAds),
                               Subcategory(userText: UserText.browserFeatureIssuesVideos),
                               Subcategory(userText: UserText.browserFeatureIssuesImages),
                               Subcategory(userText: UserText.browserFeatureIssuesBookmarks),
                               Subcategory(userText: UserText.browserFeatureIssuesOther)]
                return .presentEntries(entries)
            case .websiteLoadingIssues:
                return .presentForm(.brokenWebsite)
            case .ddgSearchIssues:
                let entries = [Subcategory(userText: UserText.ddgSearchIssuesTechnical),
                               Subcategory(userText: UserText.ddgSearchIssuesLayout),
                               Subcategory(userText: UserText.ddgSearchIssuesLoadTime),
                               Subcategory(userText: UserText.ddgSearchIssuesLanguageOrReason),
                               Subcategory(userText: UserText.ddgSearchIssuesAutocomplete),
                               Subcategory(userText: UserText.ddgSearchIssuesOther)]
                return .presentEntries(entries)
            case .customizationIssues:
                let entries = [Subcategory(userText: UserText.customizationIssuesHomeScreen),
                               Subcategory(userText: UserText.customizationIssuesTabs),
                               Subcategory(userText: UserText.customizationIssuesUI),
                               Subcategory(userText: UserText.customizationIssuesWhatIsCleared),
                               Subcategory(userText: UserText.customizationIssuesWhenIsCleared),
                               Subcategory(userText: UserText.customizationIssuesBookmarks),
                               Subcategory(userText: UserText.customizationIssuesOther)]
                return .presentEntries(entries)
            case .performanceIssues:
                let entries = [Subcategory(userText: UserText.performanceIssuesSlowLoading),
                               Subcategory(userText: UserText.performanceIssuesCrashes),
                               Subcategory(userText: UserText.performanceIssuesPlayback),
                               Subcategory(userText: UserText.performanceIssuesOther)]
                return .presentEntries(entries)
            case .otherIssues:
                return .presentForm(.regular)
            }
        }
        
        var userText: String {
            switch self {
            case .browserFeatureIssues:
                return UserText.browserFeatureIssuesEntry
            case .websiteLoadingIssues:
                return UserText.websiteLoadingIssuesEntry
            case .ddgSearchIssues:
                return UserText.ddgSearchIssuesEntry
            case .customizationIssues:
                return UserText.customizationIssuesEntry
            case .performanceIssues:
                return UserText.performanceIssuesEntry
            case .otherIssues:
                return UserText.otherIssuesEntry
            }
        }
    }
}
