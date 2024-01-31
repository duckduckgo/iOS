//
//  NavigationViewStyle.swift
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
import DesignResourcesKit

@available(iOS 16.0, *)
struct NavigationBarModifier: ViewModifier {

    func body(content: Content) -> some View {
        content
            .toolbarBackground(Color(designSystemColor: .surface), for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .tint(Color(designSystemColor: .textPrimary))
    }
}

// Extension to easily apply the custom modifier
@available(iOS 16.0, *)
extension View {
    func applyNavigationStyle() -> some View {
        self.modifier(NavigationBarModifier())
    }
}
