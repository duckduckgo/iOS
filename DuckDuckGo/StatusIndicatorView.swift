//
//  StatusIndicatorView.swift
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

struct StatusIndicatorView: View {
    var status: StatusIndicator
    var isDotHidden = false

    var body: some View {
        HStack(spacing: 6) {
            if !isDotHidden {
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundColor(colorForStatus(status))
                    .animation(.easeInOut(duration: 0.3), value: status)
            }

            Text(status.text)
                .daxBodyRegular()
                .lineLimit(1)
                .foregroundColor(Color(designSystemColor: .textSecondary))
                .animation(.easeInOut(duration: 0.3), value: status)
        }
    }

    private func colorForStatus(_ status: StatusIndicator) -> Color {
        switch status {
        case .on, .alwaysOn:
            return Color(designSystemColor: .alertGreen)
        case .off:
            return Color(designSystemColor: .textSecondary).opacity(0.33)
        }
    }
}

#Preview {
    VStack {
        StatusIndicatorView(status: .on, isDotHidden: false)
        StatusIndicatorView(status: .off, isDotHidden: false)
        StatusIndicatorView(status: .alwaysOn, isDotHidden: false)
        StatusIndicatorView(status: .on, isDotHidden: true)
        StatusIndicatorView(status: .off, isDotHidden: true)
        StatusIndicatorView(status: .alwaysOn, isDotHidden: true)
    }
}
