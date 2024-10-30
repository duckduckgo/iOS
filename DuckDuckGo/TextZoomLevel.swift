//
//  TextZoomLevel.swift
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

enum TextZoomLevel: Int, CaseIterable, CustomStringConvertible {
    
    var description: String {
        return "\(self.rawValue)%"
    }

    case percent80 = 80
    case percent90 = 90
    case percent100 = 100
    case percent110 = 110
    case percent120 = 120
    case percent130 = 130
    case percent140 = 140
    case percent150 = 150
    case percent160 = 160
    case percent170 = 170

}
