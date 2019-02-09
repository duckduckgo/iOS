//
//  AutoClearSettingsModel.swift
//  DuckDuckGo
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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
import UIKit

/// This struct is a model of Auto Clear Data settings
struct AutoClearSettingsModel: Equatable {
    
    struct Action: OptionSet {
        let rawValue: Int
        
        static let clearTabs = Action(rawValue: 1 << 0)
        static let clearData = Action(rawValue: 1 << 1)
    }
    
    enum Timing: Int {
        case termination
        case delay5min
        case delay15min
        case delay30min
        case delay60min
    }
    
    var action: Action
    var timing: Timing
    
    /// Create settings model based on last user selection that is stored in settings.
    ///
    /// - Returns: Settings model, or nil in case user did not enable this feature.
    init?(settings: AppSettings) {
        action = settings.autoClearAction
        guard action.isEmpty == false else { return nil }
        
        timing = settings.autoClearTiming
    }
    
    /// Create settings model with default values.
    init() {
        action = [.clearTabs, .clearData]
        timing = .termination
    }
}
