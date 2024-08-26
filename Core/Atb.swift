//
//  Atb.swift
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

public struct Atb: Decodable, Equatable {

    let version: String
    let updateVersion: String?

    /// Equality is about the version dropping any variants.  e.g. v100-1 == v100-1ma
    public static func == (lhs: Atb, rhs: Atb) -> Bool {
        return lhs.droppingVariant == rhs.droppingVariant
    }

}

extension Atb {

    var droppingVariant: String? {
        String(version.prefix("v111-1".count))
    }

}
