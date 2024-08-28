//
//  DuckPlayerStorage.swift
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

import Core
import Foundation
import Common
import os.log

protocol DuckPlayerStorage {
    /// Description: Checks whether the user has seen and interacted with (i.e. clicked any button) the Duck Player overlay on a YouTube video.
    /// https://app.asana.com/0/1207619243206445/1207785962765265/f
    var userInteractedWithDuckPlayer: Bool { get set }
}

struct DefaultDuckPlayerStorage: DuckPlayerStorage {
    @UserDefaultsWrapper(key: .userInteractedWithDuckPlayer, defaultValue: false)
    var userInteractedWithDuckPlayer: Bool {
        didSet(newValue) {
            Logger.duckPlayer.debug("Flagging userInteractedWithDuckPlayer [\(newValue ? "true" : "false")]")
        }
    }
}
