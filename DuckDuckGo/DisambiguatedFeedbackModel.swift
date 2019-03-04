//
//  DisambiguatedFeedbackModel.swift
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

struct DisambiguatedFeedbackModel {
    var category: DisambiguatedFeedbackCategory?
    var subcategory: String?
}

enum DisambiguatedFeedbackCategory: String, CaseIterable {
    
    case browserFeatureIssues = "Browsing features are missing or frustrating"
    case websiteLoadingIssues = "Certain websites don't load correctly"
    case ddgSearchIssues = "DuckDuckGo search isn't good enough"
    case customizationIssues = "There aren't enough ways to customize the app"
    case performanceIssues = "The app is slow, buggy, or crashes"
    case otherIssues = "None of these"
    
    var subcategories: [String] {
        switch self {
        case .browserFeatureIssues:
            return ["Navigating forward, backward, and/or refreshing",
                    "Creating and managing tabs",
                    "Ad and pop-up blocking",
                    "Watching videos",
                    "Interacting with images",
                    "Creating and managing bookmarks",
                    "None of these"
            ]
        case .websiteLoadingIssues:
            return []
        case .ddgSearchIssues:
            return ["Programming/technical search",
                    "The layout should be more like Google",
                    "Faster load time",
                    "Searching in a specific language or reason",
                    "Better autocomplete",
                    "None of these"
            ]
        case .customizationIssues:
            return ["The home screen configuration",
                    "How tabs are displayed",
                    "How the app looks",
                    "Which data is cleared",
                    "When data is cleared",
                    "How bookmarks are displayed",
                    "None of these"
            ]
        case .performanceIssues:
            return ["Web pages or search results load slowly",
                    "The app crashes or freezes",
                    "Video or media playback bugs",
                    "None of these"
            ]
        case .otherIssues:
            return []
        }
    }
    
    var caption: String {
        switch self {
        case .browserFeatureIssues:
            return "Browser feature issues"
        case .websiteLoadingIssues:
            return "Website loading issues"
        case .ddgSearchIssues:
            return "Search issues"
        case .customizationIssues:
            return "Customization issues"
        case .performanceIssues:
            return "Performance issues"
        case .otherIssues:
            return "Other issues"
        }
    }
    
    var subcategoriesCaption: String {
        switch self {
        case .browserFeatureIssues:
            return "Which browsing features should be added or improved to make you more likely to continue using DuckDuckGo?"
        case .websiteLoadingIssues:
            return ""
        case .ddgSearchIssues:
            return "Which DuckDuckGo search improvements would make you more likely to continue using the app?"
        case .customizationIssues:
            return "Which additional customization options would make you more likely to continue using the app?"
        case .performanceIssues:
            return "Which issues should be fixed to make you more likely to continue using DuckDuckGo?"
        case .otherIssues:
            return ""
        }
    }
}
