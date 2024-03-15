//
//  SettingsStatus.swift
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
import Combine

enum StatusIndicator: Equatable {
    case alwaysOn
    case on
    case off
    case custom(String)

    var text: String {
        switch self {
        case .alwaysOn:
            return "Always On"
        case .on:
            return "On"
        case .off:
            return "Off"
        case .custom(let customText):
            return customText
        }
    }
}

struct StatusIndicatorView: View {
    var status: StatusIndicator

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .frame(width: 8, height: 8)
                .foregroundColor(colorForStatus(status))

            Text(status.text)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
        }
    }

    private func colorForStatus(_ status: StatusIndicator) -> Color {
        switch status {
        case .on, .alwaysOn:
            return Color("AlertGreen")
        case .off:
            return Color.secondary.opacity(0.33)
        case .custom:
            return .orange
        }
    }
}
