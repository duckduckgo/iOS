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

extension UserText {
    
    public static let feedbackStartHeader = NSLocalizedString("feedback.start.header",
                                                              comment: "Let's get started!")
    public static let feedbackStartSupplementary = NSLocalizedString("feedback.start.supplementary",
                                                                     comment: "How would you catagorize your feedback?")
    public static let feedbackStartFooter = NSLocalizedString("feedback.start.footer",
                                                              comment: "Your anonymous feedback is important to us.")
    
    public static let feedbackPositiveHeader = NSLocalizedString("feedback.positive.header",
                                                                 comment: "Awesome to hear!")
    public static let feedbackPositiveSupplementary = NSLocalizedString("feedback.positive.supplementary",
                                                                        comment: "Please share the love by rating the app on the App Store")
    public static let feedbackPositiveRate = NSLocalizedString("feedback.positive.rate",
                                                               comment: "Rate the App")
    public static let feedbackPositiveShare = NSLocalizedString("feedback.positive.submit",
                                                                comment: "Share Details")
    public static let feedbackPositiveNoThanks = NSLocalizedString("feedback.positive.noThanks",
                                                                   comment: "No thanks! I'm done")
    
    public static let feedbackFormSubmit = NSLocalizedString("feedback.form.submit",
                                                             comment: "Submit Feedback")
    
    public static let feedbackPositiveFormHeader = NSLocalizedString("feedback.positive.form.header",
                                                                     comment: "Share Details")
    public static let feedbackPositiveFormSupplementary = NSLocalizedString("feedback.positive.form.supplementary",
                                                                            comment: "Is there anything specific you’d like to share with the team?")
    public static let feedbackPositiveFormPlaceholder = NSLocalizedString("feedback.positive.form.placeholder",
                                                                          comment: "What have you been enjoying?")
    
    public static let feedbackNegativeHeader = NSLocalizedString("feedback.negative.header",
                                                                 comment: "We’re sorry to hear that.")
    public static let feedbackNegativeSupplementary = NSLocalizedString("feedback.negative.supplementary",
                                                                            comment: "What is your frustration most related to?")
    public static let feedbackNegativeFormPlaceholder = NSLocalizedString("feedback.negative.form.placeholder",
                                                                          comment: "Are there any specifics you’d like to include?")
    public static let feedbackNegativeFormGenericPlaceholder = NSLocalizedString("feedback.negative.form.genericPlaceholder",
                                                                        comment: "Please be as specific as possible")
    
    public static let browserFeatureIssuesEntry = NSLocalizedString("feedback.browserFeatures.entry",
                                                                    comment: "Browsing features are missing or frustrating")
    public static let browserFeatureIssuesDescription = NSLocalizedString("feedback.browserFeatures.description",
                                                                          comment: "Browser feature issues")
    public static let browserFeatureIssuesCaption = NSLocalizedString("feedback.browserFeatures.caption",
                                                                      comment: "Which browsing feature can we add or improve?")
    public static let browserFeatureIssuesNavigation = NSLocalizedString("feedback.browserFeatures.navigation",
                                                                         comment: "Navigating forward, backward, and/or refreshing")
    public static let browserFeatureIssuesTabs = NSLocalizedString("feedback.browserFeatures.tabs",
                                                                   comment: "Creating and managing tabs")
    public static let browserFeatureIssuesAds = NSLocalizedString("feedback.browserFeatures.ads",
                                                                  comment: "Ad and pop-up blocking")
    public static let browserFeatureIssuesVideos = NSLocalizedString("feedback.browserFeatures.videos",
                                                                     comment: "Watching videos")
    public static let browserFeatureIssuesImages = NSLocalizedString("feedback.browserFeatures.images",
                                                                     comment: "Interacting with images")
    public static let browserFeatureIssuesBookmarks = NSLocalizedString("feedback.browserFeatures.bookmarks",
                                                                        comment: "Creating and managing bookmarks")
    public static let browserFeatureIssuesOther = NSLocalizedString("feedback.browserFeatures.other",
                                                                    comment: "None of these")
    
    public static let websiteLoadingIssuesEntry = NSLocalizedString("feedback.websiteLoading.entry",
                                                                    comment: "Certain websites don't load correctly")
    public static let websiteLoadingIssuesDescription = NSLocalizedString("feedback.websiteLoading.description",
                                                                          comment: "Website loading issues")
    public static let websiteLoadingIssuesFormSupplementary = NSLocalizedString("feedback.websiteLoading.form.supplementary",
                                                                          comment: "Where are you seeing these issues?")
    public static let websiteLoadingIssuesFormURLPlaceholder = NSLocalizedString("feedback.websiteLoading.form.urlPlaceholder",
                                                                              comment: "Which website has issues?")
    public static let websiteLoadingIssuesFormPlaceholder = NSLocalizedString("feedback.websiteLoading.form.placeholder",
                                                                                comment: "What content seems to be affected?")
    
    public static let ddgSearchIssuesEntry = NSLocalizedString("feedback.ddgSearch.entry",
                                                               comment: "DuckDuckGo search isn't good enough")
    public static let ddgSearchIssuesDescription = NSLocalizedString("feedback.ddgSearch.description",
                                                                     comment: "DuckDuckGo search issues")
    public static let ddgSearchIssuesCaption = NSLocalizedString("feedback.ddgSearch.caption",
                                                                 comment: "Which search feature can we add or improve?")
    public static let ddgSearchIssuesTechnical = NSLocalizedString("feedback.ddgSearch.technical",
                                                                   comment: "Programming/technical search")
    public static let ddgSearchIssuesLayout = NSLocalizedString("feedback.ddgSearch.layout",
                                                                comment: "The layout should be more like Google")
    public static let ddgSearchIssuesLoadTime = NSLocalizedString("feedback.ddgSearch.loadTime",
                                                                  comment: "Faster load time")
    public static let ddgSearchIssuesLanguageOrReason = NSLocalizedString("feedback.ddgSearch.languageOrReason",
                                                                          comment: "Searching in a specific language or reason")
    public static let ddgSearchIssuesAutocomplete = NSLocalizedString("feedback.ddgSearch.autocomplete",
                                                                      comment: "Better autocomplete")
    public static let ddgSearchIssuesOther = NSLocalizedString("feedback.ddgSearch.other",
                                                               comment: "None of these")
    
    public static let customizationIssuesEntry = NSLocalizedString("feedback.customization.entry",
                                                                   comment: "There aren't enough ways to customize the app")
    public static let customizationIssuesDescription = NSLocalizedString("feedback.customization.description",
                                                                         comment: "Customization issues")
    public static let customizationIssuesCaption = NSLocalizedString("feedback.customization.caption",
                                                                     comment: "Which customization option can we add or improve?")
    public static let customizationIssuesHomeScreen = NSLocalizedString("feedback.customization.homeScreen",
                                                                        comment: "The home screen configuration")
    public static let customizationIssuesTabs = NSLocalizedString("feedback.customization.tabs",
                                                                  comment: "How tabs are displayed")
    public static let customizationIssuesUI = NSLocalizedString("feedback.customization.ui",
                                                                comment: "How the app looks")
    public static let customizationIssuesWhatIsCleared = NSLocalizedString("feedback.customization.whatIsCleared",
                                                                           comment: "Which data is cleared")
    public static let customizationIssuesWhenIsCleared = NSLocalizedString("feedback.customization.whenIsCleared",
                                                                           comment: "When data is cleared")
    public static let customizationIssuesBookmarks = NSLocalizedString("feedback.customization.bookmarks",
                                                                       comment: "How bookmarks are displayed")
    public static let customizationIssuesOther = NSLocalizedString("feedback.customization.other",
                                                                   comment: "None of these")
    
    public static let performanceIssuesEntry = NSLocalizedString("feedback.performance.entry",
                                                                 comment: "The app is slow, buggy, or crashes")
    public static let performanceIssuesDescription = NSLocalizedString("feedback.performance.description",
                                                                       comment: "Performance issues")
    public static let performanceIssuesCaption = NSLocalizedString("feedback.performance.caption",
                                                                   comment: "Which issue are you experiencing?")
    public static let performanceIssuesSlowLoading = NSLocalizedString("feedback.performance.slowLoading",
                                                                       comment: "Web pages or search results load slowly")
    public static let performanceIssuesCrashes = NSLocalizedString("feedback.performance.crashes",
                                                                   comment: "The app crashes or freezes")
    public static let performanceIssuesPlayback = NSLocalizedString("feedback.performance.playback",
                                                                    comment: "Video or media playback bugs")
    public static let performanceIssuesOther = NSLocalizedString("feedback.performance.other",
                                                                 comment: "None of these")
    
    public static let otherIssuesEntry = NSLocalizedString("feedback.other.entry",
                                                           comment: "None of these")
    public static let otherIssuesDescription = NSLocalizedString("feedback.other.description",
                                                                 comment: "Other issues")
    
    public static let feedbackFormCaption = NSLocalizedString("feedback.form.caption",
                                                              comment: "Please tell us what we can improve")
    
}
