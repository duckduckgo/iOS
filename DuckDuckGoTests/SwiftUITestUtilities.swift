//
//  SwiftUITestUtilities.swift
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

import SwiftUI

/// Recursively searches for a SwiftUI view of type `T` within the given root object.
///
/// - Parameters:
///   - type: The type of view to search for.
///   - root: The root object to start searching from.
/// - Returns: An optional view of type `T`, or `nil` if no such view is found.
func find<T: View>(_ type: T.Type, in root: Any) -> T? {
    let mirror = Mirror(reflecting: root)
    for child in mirror.children {
        if let view = child.value as? T {
            return view
        }
        if let found = find(type, in: child.value) {
            return found
        }
    }
    return nil
}
