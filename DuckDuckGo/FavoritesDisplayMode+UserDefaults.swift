//
//  FavoritesDisplayMode+UserDefaults.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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

import Bookmarks
import Foundation

extension FavoritesDisplayMode: LosslessStringConvertible {
    static let `default` = FavoritesDisplayMode.displayNative(.mobile)

    public init?(_ description: String) {
        switch description {
        case FavoritesDisplayMode.displayNative(.mobile).description:
            self = .displayNative(.mobile)
        case FavoritesDisplayMode.displayUnified(native: .mobile).description:
            self = .displayUnified(native: .mobile)
        default:
            return nil
        }
    }
}
