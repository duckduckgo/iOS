//
//  FeedbackCategoryProviding.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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

protocol FeedbackCategoryProviding: Hashable, CaseIterable, Identifiable, RawRepresentable {
    var displayName: String { get }
}

extension FeedbackCategoryProviding where RawValue == String {
    var id: String {
        rawValue
    }
}

enum UnifiedFeedbackReportType: String, FeedbackCategoryProviding {
    case reportIssue
    case requestFeature
    case general

    var displayName: String {
        switch self {
        case .reportIssue: return UserText.browserFeedbackReportProblem
        case .requestFeature: return UserText.browserFeedbackRequestFeature
        case .general: return UserText.browserFeedbackGeneralFeedback
        }
    }
}

enum UnifiedFeedbackCategory: String, FeedbackCategoryProviding {
    case subscription
    case vpn
    case pir
    case itr

    var displayName: String {
        switch self {
        case .subscription: return UserText.generalFeedbackFormCategoryPPro
        case .vpn: return UserText.generalFeedbackFormCategoryVPN
        case .pir: return UserText.generalFeedbackFormCategoryPIR
        case .itr: return UserText.generalFeedbackFormCategoryITR
        }
    }
}

enum PrivacyProFeedbackSubcategory: String, FeedbackCategoryProviding {
    case otp
    case somethingElse

    var displayName: String {
        switch self {
        case .otp: return UserText.pproFeedbackFormCategoryOTP
        case .somethingElse: return UserText.pproFeedbackFormCategoryOther
        }
    }
}

enum VPNFeedbackSubcategory: String, FeedbackCategoryProviding {
    case unableToInstall
    case failsToConnect
    case tooSlow
    case issueWithAppOrWebsite
    case appCrashesOrFreezes
    case cantConnectToLocalDevice
    case somethingElse

    var displayName: String {
        switch self {
        case .unableToInstall: return UserText.vpnFeedbackFormCategoryUnableToInstall
        case .failsToConnect: return UserText.vpnFeedbackFormCategoryFailsToConnect
        case .tooSlow: return UserText.vpnFeedbackFormCategoryTooSlow
        case .issueWithAppOrWebsite: return UserText.vpnFeedbackFormCategoryIssuesWithApps
        case .appCrashesOrFreezes: return UserText.vpnFeedbackFormCategoryBrowserCrashOrFreeze
        case .cantConnectToLocalDevice: return UserText.vpnFeedbackFormCategoryLocalDeviceConnectivity
        case .somethingElse: return UserText.vpnFeedbackFormCategoryOther
        }
    }
}

enum PIRFeedbackSubcategory: String, FeedbackCategoryProviding {
    case nothingOnSpecificSite
    case notMe
    case scanStuck
    case removalStuck
    case somethingElse

    var displayName: String {
        switch self {
        case .nothingOnSpecificSite: return UserText.pirFeedbackFormCategoryNothingOnSpecificSite
        case .notMe: return UserText.pirFeedbackFormCategoryNotMe
        case .scanStuck: return UserText.pirFeedbackFormCategoryScanStuck
        case .removalStuck: return UserText.pirFeedbackFormCategoryRemovalStuck
        case .somethingElse: return UserText.pirFeedbackFormCategoryOther
        }
    }
}

enum ITRFeedbackSubcategory: String, FeedbackCategoryProviding {
    case accessCode
    case cantContactAdvisor
    case advisorUnhelpful
    case somethingElse

    var displayName: String {
        switch self {
        case .accessCode: return UserText.itrFeedbackFormCategoryAccessCode
        case .cantContactAdvisor: return UserText.itrFeedbackFormCategoryCantContactAdvisor
        case .advisorUnhelpful: return UserText.itrFeedbackFormCategoryUnhelpful
        case .somethingElse: return UserText.itrFeedbackFormCategorySomethingElse
        }
    }
}
