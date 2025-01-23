//
//  AIChatControlWidget.swift
//  DuckDuckGo
//
//  Copyright © 2025 DuckDuckGo. All rights reserved.
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

import WidgetKit
import SwiftUI
import AppIntents

@available(iOS 18, *)
struct AIChatControlWidget: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: ControlWidgetKind.aiChat.rawValue) {
            ControlWidgetButton(action: OpenAIChatIntent()) {
                Label("Duck.ai", image: "AI-Chat-Symbol")
            }
        }
        .displayName("Duck.ai")
    }
}

@available(iOS 18, *)
struct OpenAIChatIntent: AppIntent {
    static var title: LocalizedStringResource = "Duck.ai"
    static var description: LocalizedStringResource = "Launches Duck.ai from the Control Center."
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult & OpensIntent {
        await EnvironmentValues().openURL(DeepLinks.openAIChat.appendingParameter(name: WidgetSourceType.sourceKey, value: WidgetSourceType.controlCenter.rawValue))
        return .result()
    }
}
