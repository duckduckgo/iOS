//
//  DaxDialogsSettings.swift
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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

import Core

protocol DaxDialogsSettings: AnyObject {

    var isDismissed: Bool { get set }

    // Used to understand if users completed the old onboarding flow and should not be prompted in-context dax dialogs.
    var homeScreenMessagesSeen: Int { get }

    var browsingAfterSearchShown: Bool { get set }
    
    var browsingWithTrackersShown: Bool { get set }
    
    var browsingWithoutTrackersShown: Bool { get set }
    
    var browsingMajorTrackingSiteShown: Bool { get set }
    
    var fireButtonEducationShownOrExpired: Bool { get set }

    var fireMessageExperimentShown: Bool { get set }

    var fireButtonPulseDateShown: Date? { get set }

    var privacyButtonPulseShown: Bool { get set }

    var browsingFinalDialogShown: Bool { get set }

    var lastVisitedOnboardingWebsiteURLPath: String? { get set }

    var lastShownContextualOnboardingDialogType: String? { get set }

}

class DefaultDaxDialogsSettings: DaxDialogsSettings {
    
    @UserDefaultsWrapper(key: .daxIsDismissed, defaultValue: true)
    var isDismissed: Bool
    
    @UserDefaultsWrapper(key: .daxHomeScreenMessagesSeen, defaultValue: 0)
    var homeScreenMessagesSeen: Int
    
    @UserDefaultsWrapper(key: .daxBrowsingAfterSearchShown, defaultValue: false)
    var browsingAfterSearchShown: Bool
    
    @UserDefaultsWrapper(key: .daxBrowsingWithTrackersShown, defaultValue: false)
    var browsingWithTrackersShown: Bool
    
    @UserDefaultsWrapper(key: .daxBrowsingWithoutTrackersShown, defaultValue: false)
    var browsingWithoutTrackersShown: Bool
    
    @UserDefaultsWrapper(key: .daxBrowsingMajorTrackingSiteShown, defaultValue: false)
    var browsingMajorTrackingSiteShown: Bool
    
    @UserDefaultsWrapper(key: .daxFireButtonEducationShownOrExpired, defaultValue: false)
    var fireButtonEducationShownOrExpired: Bool

    @UserDefaultsWrapper(key: .daxFireMessageExperimentShown, defaultValue: false)
    var fireMessageExperimentShown: Bool

    @UserDefaultsWrapper(key: .fireButtonPulseDateShown, defaultValue: nil)
    var fireButtonPulseDateShown: Date?

    @UserDefaultsWrapper(key: .privacyButtonPulseShown, defaultValue: false)
    var privacyButtonPulseShown: Bool

    @UserDefaultsWrapper(key: .daxBrowsingFinalDialogShown, defaultValue: false)
    var browsingFinalDialogShown: Bool

    @UserDefaultsWrapper(key: .daxLastVisitedOnboardingWebsite, defaultValue: nil)
    var lastVisitedOnboardingWebsiteURLPath: String?

    @UserDefaultsWrapper(key: .daxLastShownContextualOnboardingDialogType, defaultValue: nil)
    var lastShownContextualOnboardingDialogType: String?

}
