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
    
    static let practicesText: [PrivacyPractices.Summary: String] = [
        .unknown: UserText.privacyProtectionTOSUnknown,
        .good: UserText.privacyProtectionTOSGood,
        .mixed: UserText.privacyProtectionTOSMixed,
        .poor: UserText.privacyProtectionTOSPoor
    ]
    
    func encryptedConnectionText() -> String {
        
        switch encryptionType {
        case .encrypted:
            return UserText.ppEncryptionEncryptedHeading
            
        case .mixed:
            return UserText.ppEncryptionMixedHeading
            
        case .forced:
            return UserText.ppEncryptionForcedHeading
            
        case .unencrypted:
            return UserText.ppEncryptionUnencryptedHeading
        }
        
    }
    
    func encryptedConnectionSuccess() -> Bool {
        return https && hasOnlySecureContent
    }
    
    func privacyPracticesText() -> String? {
        return SiteRating.practicesText[privacyPracticesSummary()]
    }
    
    func privacyPracticesSummary() -> PrivacyPractices.Summary {
        return privacyPractice.summary
    }
    
    func majorNetworksText(config: PrivacyConfiguration) -> String {
        return protecting(config) ? majorNetworksBlockedText() : majorNetworksDetectedText()
    }
    
    func majorNetworksSuccess(config: PrivacyConfiguration) -> Bool {
        return (protecting(config) ? majorTrackerNetworksBlocked : majorTrackerNetworksDetected) <= 0
    }
    
    func majorNetworksBlockedText() -> String {
        return String(format: UserText.privacyProtectionMajorTrackersBlocked, majorTrackerNetworksBlocked)
    }
    
    func majorNetworksDetectedText() -> String {
        return String(format: UserText.privacyProtectionMajorTrackersFound, majorTrackerNetworksDetected)
    }
    
    func networksText(config: PrivacyConfiguration) -> String {
        var isProtecting = protecting(config)
        if config.isTempUnprotected(domain: domain) {
            isProtecting = false
        }
        
        return isProtecting ? networksBlockedText() : networksDetectedText()
    }
    
    func networksSuccess(config: PrivacyConfiguration) -> Bool {
        return (protecting(config) ? trackersBlocked.count : trackersDetected.count) <= 0
    }
    
    func networksBlockedText() -> String {
        return String(format: UserText.privacyProtectionTrackersBlocked, trackersBlocked.count)
    }
    
    func networksDetectedText() -> String {
        return String(format: UserText.privacyProtectionTrackersFound, trackersDetected.count)
    }
    
    func protecting(_ config: PrivacyConfiguration) -> Bool {
        return config.isProtected(domain: domain)
    }
    
    static let gradeImages: [Grade.Grading: UIImage] = [
        .a: #imageLiteral(resourceName: "PP Inline A"),
        .bPlus: #imageLiteral(resourceName: "PP Inline B Plus"),
        .b: #imageLiteral(resourceName: "PP Inline B"),
        .cPlus: #imageLiteral(resourceName: "PP Inline C Plus"),
        .c: #imageLiteral(resourceName: "PP Inline C"),
        .d: #imageLiteral(resourceName: "PP Inline D"),
        .dMinus: #imageLiteral(resourceName: "PP Inline D")
    ]
    
    func siteGradeImages() -> (from: UIImage, to: UIImage) {
        let fromGrade = scores.site.grade
        let toGrade = scores.enhanced.grade
        
        return (SiteRating.gradeImages[fromGrade]!, SiteRating.gradeImages[toGrade]!)
    }
    
}
