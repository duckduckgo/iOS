//
//  MaliciousSiteProtectionEventMapper.swift
//  DuckDuckGo
//
//  Copyright © 2025 DuckDuckGo. All rights reserved.
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
import Common
import Core
import MaliciousSiteProtection

enum MaliciousSiteProtectionEventMapper {

    static let debugEvents = EventMapping<MaliciousSiteProtection.Event> { event, _, _, _ in
        switch event {
        case .errorPageShown,
             .visitSite,
             .iframeLoaded,
             .settingToggled,
             .matchesApiTimeout:
            Pixel.fire(event)
        case .failedToDownloadInitialDataSets:
            Pixel.fireDailyAndCount(event)
        case .matchesApiFailure(let error):
            Logger.MaliciousSiteProtection.manager.error("Error fetching matches from API: \(error)")
        }
    }
    
}
