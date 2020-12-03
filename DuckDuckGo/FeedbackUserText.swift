//
//  FeedbackUserText.swift
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

// swiftlint:disable line_length
extension UserText {
    
    public static let siteFeedbackTitle = NSLocalizedString("siteFeedback.title",
                                                            value: "Report a Broken Site",
                                                            comment: "This is a form title")
    public static let siteFeedbackSubtitle = NSLocalizedString("siteFeedback.subtitle",
                                                               value: "Broken site reporting is completely anonymous and helps us to improve the app!",
                                                               comment: "")
    public static let siteFeedbackDomainInfo = NSLocalizedString("siteFeedback.domainInfo",
                                                                 value: "Domain of Broken Site:",
                                                                 comment: "Domain is an URL address")
    public static let siteFeedbackURLPlaceholder = NSLocalizedString("siteFeedback.urlPlaceholder",
                                                                     value: "Which website is broken?",
                                                                     comment: "")
    public static let siteFeedbackMessagePlaceholder = NSLocalizedString("siteFeedback.messagePlaceholder",
                                                                         value: "Which content or functionality is breaking?",
                                                                         comment: "")
    public static let siteFeedbackButtonText = NSLocalizedString("siteFeedback.buttonText",
                                                                 value: "Submit Report",
                                                                 comment: "Report a Broken Site screen confirmation button")
    
    public static let feedbackStartHeader = NSLocalizedString("feedback.start.header",
                                                              value: "Let’s Get Started!",
                                                              comment: "")
    public static let feedbackStartSupplementary = NSLocalizedString("feedback.start.supplementary",
                                                                     value: "How would you categorize your feedback?",
                                                                     comment: "")
    public static let feedbackStartFooter = NSLocalizedString("feedback.start.footer",
                                                              value: "Your anonymous feedback is important to us.",
                                                              comment: "")
    
    public static let feedbackPositiveHeader = NSLocalizedString("feedback.positive.header",
                                                                 value: "Awesome to Hear!",
                                                                 comment: "")
    public static let feedbackPositiveShare = NSLocalizedString("feedback.positive.submit",
                                                                value: "Share Details",
                                                                comment: "Button encouraging uses to share details aboout their feedback")
    public static let feedbackPositiveNoThanks = NSLocalizedString("feedback.positive.noThanks",
                                                                   value: "No Thanks! I’m Done",
                                                                   comment: "")
    
    public static let feedbackFormSubmit = NSLocalizedString("feedback.form.submit",
                                                             value: "Submit",
                                                             comment: "Confirmation button")
    
    public static let feedbackPositiveFormHeader = NSLocalizedString("feedback.positive.form.header",
                                                                     value: "Share Details",
                                                                     comment: "Header above input field")
    public static let feedbackPositiveFormSupplementary = NSLocalizedString("feedback.positive.form.supplementary",
                                                                            value: "Are there any details you’d like to share with the team?",
                                                                            comment: "")
    public static let feedbackPositiveFormPlaceholder = NSLocalizedString("feedback.positive.form.placeholder",
                                                                          value: "What have you been enjoying?",
                                                                          comment: "")
    
    public static let feedbackNegativeHeader = NSLocalizedString("feedback.negative.header",
                                                                 value: "We’re Sorry to Hear That",
                                                                 comment: "")
    public static let feedbackNegativeSupplementary = NSLocalizedString("feedback.negative.supplementary",
                                                                        value: "What is your frustration most related to?",
                                                                        comment: "")
    public static let feedbackNegativeFormPlaceholder = NSLocalizedString("feedback.negative.form.placeholder",
                                                                          value: "Are there any specifics you’d like to include?",
                                                                          comment: "")
    public static let feedbackNegativeFormGenericPlaceholder = NSLocalizedString("feedback.negative.form.genericPlaceholder",
                                                                                 value: "Please be as specific as possible",
                                                                                 comment: "")
    
    public static let browserFeatureIssuesEntry = NSLocalizedString("feedback.browserFeatures.entry",
                                                                    value: "Browsing features are missing or frustrating",
                                                                    comment: "")
    public static let browserFeatureIssuesDescription = NSLocalizedString("feedback.browserFeatures.description",
                                                                          value: "Browser Feature Issues",
                                                                          comment: "")
    public static let browserFeatureIssuesCaption = NSLocalizedString("feedback.browserFeatures.caption",
                                                                      value: "Which browsing feature can we add or improve?",
                                                                      comment: "")
    public static let browserFeatureIssuesNavigation = NSLocalizedString("feedback.browserFeatures.navigation",
                                                                         value: "Navigating forward, backward, and/or refreshing",
                                                                         comment: "")
    public static let browserFeatureIssuesTabs = NSLocalizedString("feedback.browserFeatures.tabs",
                                                                   value: "Creating and managing tabs",
                                                                   comment: "")
    public static let browserFeatureIssuesAds = NSLocalizedString("feedback.browserFeatures.ads",
                                                                  value: "Ad and pop-up blocking",
                                                                  comment: "")
    public static let browserFeatureIssuesVideos = NSLocalizedString("feedback.browserFeatures.videos",
                                                                     value: "Watching videos",
                                                                     comment: "")
    public static let browserFeatureIssuesImages = NSLocalizedString("feedback.browserFeatures.images",
                                                                     value: "Interacting with images",
                                                                     comment: "")
    public static let browserFeatureIssuesBookmarks = NSLocalizedString("feedback.browserFeatures.bookmarks",
                                                                        value: "Creating and managing bookmarks",
                                                                        comment: "")
    public static let browserFeatureIssuesOther = NSLocalizedString("feedback.browserFeatures.other",
                                                                    value: "None of these",
                                                                    comment: "")
    
    public static let websiteLoadingIssuesEntry = NSLocalizedString("feedback.websiteLoading.entry",
                                                                    value: "Certain websites don’t load correctly",
                                                                    comment: "")
    public static let websiteLoadingIssuesDescription = NSLocalizedString("feedback.websiteLoading.description",
                                                                          value: "Website Loading Issues",
                                                                          comment: "")
    public static let websiteLoadingIssuesFormSupplementary = NSLocalizedString("feedback.websiteLoading.form.supplementary",
                                                                                value: "Where are you seeing these issues?",
                                                                                comment: "")
    public static let websiteLoadingIssuesFormURLPlaceholder = NSLocalizedString("feedback.websiteLoading.form.urlPlaceholder",
                                                                                 value: "Which website has issues?",
                                                                                 comment: "")
    public static let websiteLoadingIssuesFormPlaceholder = NSLocalizedString("feedback.websiteLoading.form.placeholder",
                                                                              value: "What content seems to be affected?",
                                                                              comment: "")
    
    public static let ddgSearchIssuesEntry = NSLocalizedString("feedback.ddgSearch.entry",
                                                               value: "DuckDuckGo search isn’t good enough",
                                                               comment: "")
    public static let ddgSearchIssuesDescription = NSLocalizedString("feedback.ddgSearch.description",
                                                                     value: "DuckDuckGo Search Issues",
                                                                     comment: "")
    public static let ddgSearchIssuesCaption = NSLocalizedString("feedback.ddgSearch.caption",
                                                                 value: "Which search feature can we add or improve?",
                                                                 comment: "")
    public static let ddgSearchIssuesTechnical = NSLocalizedString("feedback.ddgSearch.technical",
                                                                   value: "Programming/technical search",
                                                                   comment: "")
    public static let ddgSearchIssuesLayout = NSLocalizedString("feedback.ddgSearch.layout",
                                                                value: "The layout should be more like Google",
                                                                comment: "")
    public static let ddgSearchIssuesSpeed = NSLocalizedString("feedback.ddgSearch.loadTime",
                                                               value: "Faster load time",
                                                               comment: "")
    public static let ddgSearchIssuesLanguageOrRegion = NSLocalizedString("feedback.ddgSearch.languageOrRegion",
                                                                          value: "Searching in a specific language or region",
                                                                          comment: "")
    public static let ddgSearchIssuesAutocomplete = NSLocalizedString("feedback.ddgSearch.autocomplete",
                                                                      value: "Better autocomplete",
                                                                      comment: "")
    public static let ddgSearchIssuesOther = NSLocalizedString("feedback.ddgSearch.other",
                                                               value: "None of these",
                                                               comment: "")
    
    public static let customizationIssuesEntry = NSLocalizedString("feedback.customization.entry",
                                                                   value: "There aren’t enough ways to customize the app",
                                                                   comment: "")
    public static let customizationIssuesDescription = NSLocalizedString("feedback.customization.description",
                                                                         value: "Customization Issues",
                                                                         comment: "")
    public static let customizationIssuesCaption = NSLocalizedString("feedback.customization.caption",
                                                                     value: "Which customization option can we add or improve?",
                                                                     comment: "")
    public static let customizationIssuesHomeScreen = NSLocalizedString("feedback.customization.homeScreen",
                                                                        value: "The home screen configuration",
                                                                        comment: "")
    public static let customizationIssuesTabs = NSLocalizedString("feedback.customization.tabs",
                                                                  value: "How tabs are displayed",
                                                                  comment: "")
    public static let customizationIssuesUI = NSLocalizedString("feedback.customization.ui",
                                                                value: "How the app looks",
                                                                comment: "")
    public static let customizationIssuesWhatIsCleared = NSLocalizedString("feedback.customization.whatIsCleared",
                                                                           value: "Which data is cleared",
                                                                           comment: "")
    public static let customizationIssuesWhenIsCleared = NSLocalizedString("feedback.customization.whenIsCleared", value: "When data is cleared",
                                                                           comment: "")
    public static let customizationIssuesBookmarks = NSLocalizedString("feedback.customization.bookmarks",
                                                                       value: "How bookmarks are displayed",
                                                                       comment: "")
    public static let customizationIssuesOther = NSLocalizedString("feedback.customization.other",
                                                                   value: "None of these",
                                                                   comment: "")
    
    public static let performanceIssuesEntry = NSLocalizedString("feedback.performance.entry",
                                                                 value: "The app is slow, buggy, or crashes",
                                                                 comment: "")
    public static let performanceIssuesDescription = NSLocalizedString("feedback.performance.description",
                                                                       value: "Performance Issues",
                                                                       comment: "")
    public static let performanceIssuesCaption = NSLocalizedString("feedback.performance.caption",
                                                                   value: "Which issue are you experiencing?",
                                                                   comment: "")
    public static let performanceIssuesSlowLoading = NSLocalizedString("feedback.performance.slowLoading",
                                                                       value: "Web pages or search results load slowly",
                                                                       comment: "")
    public static let performanceIssuesCrashes = NSLocalizedString("feedback.performance.crashes",
                                                                   value: "The app crashes or freezes",
                                                                   comment: "")
    public static let performanceIssuesPlayback = NSLocalizedString("feedback.performance.playback",
                                                                    value: "Video or media playback bugs",
                                                                    comment: "")
    public static let performanceIssuesOther = NSLocalizedString("feedback.performance.other",
                                                                 value: "None of these",
                                                                 comment: "")
    
    public static let otherIssuesEntry = NSLocalizedString("feedback.other.entry",
                                                           value: "None of these",
                                                           comment: "")
    public static let otherIssuesDescription = NSLocalizedString("feedback.other.description",
                                                                 value: "Other Issues",
                                                                 comment: "")
    
    public static let feedbackFormCaption = NSLocalizedString("feedback.form.caption",
                                                              value: "Please tell us what we can improve",
                                                              comment: "")
    
}
// swiftlint:enable line_length
