//
//  Views.swift
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

import SwiftUI

public typealias WaitlistViewActionHandler = (WaitlistViewModel.ViewAction) -> Void

extension View {
    /**
     * Ensures that multiline text is properly broken into lines
     * when put in scroll views.
     *
     * As seen on [Stack Overflow](https://stackoverflow.com/a/70512685).
     * Radar: FB6859124.
     */
    func fixMultilineScrollableText() -> some View {
        lineLimit(nil).modifier(MultilineScrollableTextFix())
    }
}

private struct MultilineScrollableTextFix: ViewModifier {

    func body(content: Content) -> some View {
        return AnyView(content.fixedSize(horizontal: false, vertical: true))
    }
}
