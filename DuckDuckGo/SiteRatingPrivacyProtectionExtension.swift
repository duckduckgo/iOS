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
import BrowserServicesKit

extension SiteRating {
    
    enum State { // See: https://app.asana.com/0/0/1202702259694393/f
        case someTrackersBlockedSomeRequestsAllowed // state 1
        case noTrackersBlockedSomeTrackersAllowed(isProtectionOn: Bool) // state 2 // 6
        case noTrackersBlockedSomeRequestsAllowed(isProtectionOn: Bool) // state 3 // 7
        case nothingDetected // state 4 // 8
        case someTrackersBlockedNoTrackersAllowed // state 5
        
        init(siteRating: SiteRating, config: PrivacyConfiguration) {
            
            if siteRating.trackersBlocked.isEmpty {
                let isProtectionOn = config.isProtected(domain: siteRating.domain)
                if !allowedTrackers(from: Array(siteRating.trackers)).isEmpty {
                    self = .noTrackersBlockedSomeTrackersAllowed(isProtectionOn: isProtectionOn)
                } else if siteRating.isAnyRequestLoaded {
                    self = .noTrackersBlockedSomeRequestsAllowed(isProtectionOn: isProtectionOn)
                } else {
                    self = .nothingDetected
                }
            } else {
                if siteRating.isAnyRequestLoaded {
                    self = .someTrackersBlockedSomeRequestsAllowed
                } else {
                    self = .someTrackersBlockedNoTrackersAllowed
                }
            }
            
            func allowedTrackers(from requests: [DetectedRequest]) -> [DetectedRequest] {
                requests.filter { $0.state != .allowed(reason: .otherThirdPartyRequest) }
            }
    
        }
        
        var trackingRequestsText: String {
            switch self {
            case .noTrackersBlockedSomeTrackersAllowed:
                return UserText.privacyProtectionNoTrackersBlocked
            case .someTrackersBlockedSomeRequestsAllowed, .someTrackersBlockedNoTrackersAllowed:
                return UserText.privacyProtectionTrackersBlockedNew
            case .noTrackersBlockedSomeRequestsAllowed, .nothingDetected:
                return UserText.privacyProtectionTrackersNotFound
            }
        }
        
        var thirdPartyRequestsText: String {
            switch self {
            case .nothingDetected, .someTrackersBlockedNoTrackersAllowed:
                return UserText.privacyProtectionNoOtherThirdPartyDomainsLoaded
            default:
                return UserText.privacyProtectionOtherThirdPartyDomainsLoaded
            }
        }
        
        var trackingRequestsIcon: UIImage {
            if case .noTrackersBlockedSomeTrackersAllowed(let isProtectionOn) = self {
                if isProtectionOn {
                    return #imageLiteral(resourceName: "PP Icon Major Networks Off")
                } else {
                    return #imageLiteral(resourceName: "PP Icon Major Networks Bad")
                }
            } else {
                return #imageLiteral(resourceName: "PP Icon Major Networks On")
            }
        }
        
        var thirdPartyRequestsIcon: UIImage {
            switch self {
            case .someTrackersBlockedSomeRequestsAllowed,
                    .noTrackersBlockedSomeTrackersAllowed,
                    .noTrackersBlockedSomeRequestsAllowed:
                return #imageLiteral(resourceName: "PP Icon Other Domains")
            default:
                return #imageLiteral(resourceName: "PP Icon Other Domains On")
            }
        }
        
        var thirdPartyRequestsHeroIcon: UIImage {
            switch self {
            case .someTrackersBlockedSomeRequestsAllowed,
                    .noTrackersBlockedSomeTrackersAllowed,
                    .noTrackersBlockedSomeRequestsAllowed:
                return #imageLiteral(resourceName: "PP Hero Other Domains")
            default:
                return #imageLiteral(resourceName: "PP Hero Other Domains Good")
            }
        }
        
        var thirdPartyRequestsDescription: String {
            switch self {
            case .nothingDetected, .someTrackersBlockedNoTrackersAllowed:
                return UserText.ppOtherDomainsOtherThirdPartiesEmptyState
            case .noTrackersBlockedSomeTrackersAllowed(let isProtectionOn),
                    .noTrackersBlockedSomeRequestsAllowed(let isProtectionOn):
                if isProtectionOn {
                    return UserText.ppOtherDomainsInfo
                } else {
                    return UserText.ppOtherDomainsInfoDisabledProtection
                }
            default:
                return UserText.ppOtherDomainsInfo
            }
        }
                
    }
    
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
            return UserText.ppEncryptionForcedHeadingNew
            
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
    
    func majorNetworksText(found: Bool) -> String {
        found ? UserText.privacyProtectionMajorTrackersFoundNew : UserText.privacyProtectionMajorTrackersNotFound
    }
    
    func networksText(found: Bool) -> String {
        found ? UserText.privacyProtectionTrackersFoundNew : UserText.privacyProtectionTrackersNotFound
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
