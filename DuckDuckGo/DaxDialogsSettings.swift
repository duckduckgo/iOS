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

protocol DaxDialogsSettings {
    
    var isDismissed: Bool { get set }
    
    var homeScreenMessagesSeen: Int { get set }
    
    var browsingAfterSearchShown: Bool { get set }
    
    var browsingWithTrackersShown: Bool { get set }
    
    var browsingWithoutTrackersShown: Bool { get set }
    
    var browsingMajorTrackingSiteShown: Bool { get set }

}

class DefaultDaxDialogsSettings: DaxDialogsSettings {
    
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
    
}

class InMemoryDaxDialogsSettings: DaxDialogsSettings {
    
    var isDismissed: Bool = false
    
    var homeScreenMessagesSeen: Int = 0
    
    var browsingAfterSearchShown: Bool = false
    
    var browsingWithTrackersShown: Bool = false
    
    var browsingWithoutTrackersShown: Bool = false
    
    var browsingMajorTrackingSiteShown: Bool = false
    
}
