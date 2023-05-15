//
//  RoundedButtonStyle.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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

public struct RoundedButtonStyle: ButtonStyle {

    public let enabled: Bool

    public init(enabled: Bool) {
        self.enabled = enabled
    }

    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .daxHeadline()
            .frame(maxWidth: .infinity)
            .padding([.top, .bottom], 16)
            .background(enabled ? Color.waitlistBlue : Color.waitlistBlue.opacity(0.2))
            .foregroundColor(.waitlistButtonText)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }

}
