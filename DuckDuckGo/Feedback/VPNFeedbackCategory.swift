//
//  VPNFeedbackCategory.swift
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

enum VPNFeedbackCategory: String, CaseIterable {
    case unableToInstall
    case failsToConnect
    case tooSlow
    case issueWithAppOrWebsite
    case cantConnectToLocalDevice
    case appCrashesOrFreezes
    case featureRequest
    case somethingElse

    var displayName: String {
        switch self {
        case .unableToInstall: return UserText.vpnFeedbackFormCategoryUnableToInstall
        case .failsToConnect: return UserText.vpnFeedbackFormCategoryFailsToConnect
        case .tooSlow: return UserText.vpnFeedbackFormCategoryTooSlow
        case .issueWithAppOrWebsite: return UserText.vpnFeedbackFormCategoryIssuesWithApps
        case .cantConnectToLocalDevice: return UserText.vpnFeedbackFormCategoryLocalDeviceConnectivity
        case .appCrashesOrFreezes: return UserText.vpnFeedbackFormCategoryBrowserCrashOrFreeze
        case .featureRequest: return UserText.vpnFeedbackFormCategoryFeatureRequest
        case .somethingElse: return UserText.vpnFeedbackFormCategoryOther
        }
    }
}
