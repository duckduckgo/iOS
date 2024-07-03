//
//  HomePageDisplayDailyPixelBucket.swift
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

struct HomePageDisplayDailyPixelBucket {

    let value: String

    init(favoritesCount: Int) {

        switch favoritesCount {
        case 0:
            value = "0"
        case 1:
            value = "1"
        case 2...3:
            value = "2-3"
        case 4...5:
            value = "4-5"
        case 6...10:
            value = "6-10"
        case 11...15:
            value = "11-15"
        case 16...25:
            value = "16-25"
        default:
            value = ">25"
        }
    }
}
