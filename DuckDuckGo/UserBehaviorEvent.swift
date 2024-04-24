//
//  UserBehaviorEvent.swift
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

public enum UserBehaviorEvent: String {

    case reloadTwiceWithin12Seconds = "reload-twice-within-12-seconds"
    case reloadTwiceWithin24Seconds = "reload-twice-within-24-seconds"

    case reloadAndRestartWithin30Seconds = "reload-and-restart-within-30-seconds"
    case reloadAndRestartWithin50Seconds = "reload-and-restart-within-50-seconds"

    case reloadThreeTimesWithin20Seconds = "reload-three-times-within-20-seconds"
    case reloadThreeTimesWithin40Seconds = "reload-three-times-within-40-seconds"

}
