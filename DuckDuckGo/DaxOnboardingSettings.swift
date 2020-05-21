//
//  DaxOnboardingSettings.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 21/05/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import Core

protocol DaxOnboardingSettings {
    
    var isDismissed: Bool { get set }
    
    var homeScreenMessagesSeen: Int { get set }
    
    var browsingAfterSearchShown: Bool { get set }
    
    var browsingWithTrackersShown: Bool { get set }
    
    var browsingWithoutTrackersShown: Bool { get set }
    
    var browsingMajorTrackingSiteShown: Bool { get set }
    
    var browsingOwnedByMajorTrackingSiteShown: Bool { get set }

}

class DefaultDaxOnboardingSettings: DaxOnboardingSettings {
    
    @UserDefaultsWrapper(key: .daxIsDismissed, defaultValue: false)
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
    
    @UserDefaultsWrapper(key: .daxBrowsingOwnedByMajorTrackingSiteShown, defaultValue: false)
    var browsingOwnedByMajorTrackingSiteShown: Bool
    
}

class InMemoryDaxOnboardingSettings: DaxOnboardingSettings {
    
    var isDismissed: Bool = false
    
    var homeScreenMessagesSeen: Int = 0
    
    var browsingAfterSearchShown: Bool = false
    
    var browsingWithTrackersShown: Bool = false
    
    var browsingWithoutTrackersShown: Bool = false
    
    var browsingMajorTrackingSiteShown: Bool = false
    
    var browsingOwnedByMajorTrackingSiteShown: Bool = false
    
}
