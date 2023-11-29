//
//  UserText.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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

public struct SubscriptionUserText {
    
    public static let navigationTitle = NSLocalizedString("nagivation.title", value: "Privacy Pro", comment: "Navigation Bar Title for Feature")
    
    // Settings Strings
    public static let settingsSectionTitle = NSLocalizedString("settings.sectionTitle",
                                                               value: "Privacy Pro",
                                                               comment: "Settings section title")
    public static let subscribeTitle = NSLocalizedString("settings.subscribeTitle",
                                                         value: "Subscribe to Privacy Pro",
                                                         comment: "Settings title for unsubscribed users")
    public static let subscribeSubtitle = NSLocalizedString("settings.subscribeSubTitle",
                                                            value: "More seamlessless privacy with three new protections, incluiding:",
                                                            comment: "Settings title for unsubscribed users")
    public static let featureOneName = NSLocalizedString("settings.feature1",
                                                            value: "VPN (Virtual Private Network)",
                                                            comment: "Feature one title for unsubscribed users")
    public static let featureTwoName = NSLocalizedString("settings.feature2",
                                                            value: "Personal Information Removal",
                                                            comment: "Feature two title for unsubscribed users")
    public static let featureThreeName = NSLocalizedString("settings.feature3",
                                                            value: "Identity Theft Restoration",
                                                            comment: "Feature three title for unsubscribed users")
    public static let learnMore = NSLocalizedString("settings.learnMore",
                                                            value: "Learn More",
                                                            comment: "Button title for Learn more")

}
