//
//  SiteRatingPrivacyProtectionExtension.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

extension SiteRating {

    enum PrivacyPractices {

        case unknown
        case poor
        case good
        case mixed

    }

    static let practicesText: [PrivacyPractices: String] = [
        .unknown: UserText.privacyProtectionTOSUnknown,
        .good: UserText.privacyProtectionTOSGood,
        .mixed: UserText.privacyProtectionTOSMixed,
        .poor: UserText.privacyProtectionTOSPoor
    ]

    func isMajorNetworkText() -> String {
        return isMajorTrackerNetwork ?
            UserText.privacyProtectionIsMajorTrackerNetwork :
            UserText.privacyProtectionIsNotMajorTrackerNetwork
    }

    func encryptedConnectionText() -> String {
        if !https {
            return UserText.privacyProtectionEncryptionBadConnection
        } else if !hasOnlySecureContent {
            return UserText.privacyProtectionEncryptionMixedConnection
        } else {
            return UserText.privacyProtectionEncryptionGoodConnection
        }
    }

    func encryptedConnectionSuccess() -> Bool {
        return https && hasOnlySecureContent
    }

    func privacyPracticesText() -> String? {
        return SiteRating.practicesText[privacyPractices()]
    }

    func privacyPractices() -> PrivacyPractices {
        guard let termsOfService = termsOfService else { return .unknown }
        let score = termsOfServiceScore
        switch (score) {
        case _ where(score < 0):
            return termsOfService.badReasons.isEmpty ? .good : .mixed

        case 0:
            return termsOfService.badReasons.isEmpty && termsOfService.goodReasons.isEmpty ? .unknown : .mixed

        default:
            return .poor
        }
    }

    func majorNetworksText(contentBlocker: ContentBlockerConfigurationStore) -> String {
        return protecting(contentBlocker) ? majorNetworksBlockedText() : majorNetworksDetectedText()
    }

    func majorNetworksSuccess(contentBlocker: ContentBlockerConfigurationStore) -> Bool {
        return (protecting(contentBlocker) ? uniqueMajorTrackerNetworksBlocked : uniqueMajorTrackerNetworksDetected) <= 0
    }

    func majorNetworksBlockedText() -> String {
        return String(format: UserText.privacyProtectionMajorTrackersBlocked, uniqueMajorTrackerNetworksBlocked)
    }

    func majorNetworksDetectedText() -> String {
        return String(format: UserText.privacyProtectionMajorTrackersFound, uniqueMajorTrackerNetworksDetected)
    }

    func networksText(contentBlocker: ContentBlockerConfigurationStore) -> String {
        return protecting(contentBlocker) ? networksBlockedText() : networksDetectedText()
    }

    func networksSuccess(contentBlocker: ContentBlockerConfigurationStore) -> Bool {
        return (protecting(contentBlocker) ? uniqueTrackerNetworksBlocked : uniqueTrackerNetworksDetected) <= 0
    }

    func networksBlockedText() -> String {
        return String(format: UserText.privacyProtectionTrackersBlocked, uniqueTrackerNetworksBlocked)
    }

    func networksDetectedText() -> String {
        return String(format: UserText.privacyProtectionTrackersFound, uniqueTrackerNetworksDetected)
    }

    func protecting(_ contentBlocker: ContentBlockerConfigurationStore) -> Bool {
        guard let domain = domain else { return contentBlocker.enabled }
        return contentBlocker.enabled && !contentBlocker.domainWhitelist.contains(domain)
    }

    static let gradeImages: [SiteGrade: UIImage] = [
        .a: #imageLiteral(resourceName: "PP Inline A"),
        .b: #imageLiteral(resourceName: "PP Inline B"),
        .c: #imageLiteral(resourceName: "PP Inline C"),
        .d: #imageLiteral(resourceName: "PP Inline D")
    ]

    func siteGradeImages() -> (from: UIImage, to: UIImage) {
        let grades = siteGrade()

        let fromGrade = grades.before
        let toGrade = grades.after

        return (SiteRating.gradeImages[fromGrade]!, SiteRating.gradeImages[toGrade]!)
    }

}
