//
//  WidgetKind.swift
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
import SwiftUI
import WidgetKit

enum WidgetKind: String, Codable {
    case vpn = "VPNStatusWidget"
    case aiChat = "AIChatWidget"
}

enum ControlWidgetKind: String, Codable {
    case vpn = "VPNControlWidget"
    case aiChat = "AIChatControlWidget"
}

extension WidgetCenter {
    func reloadTimelines(ofKind kind: WidgetKind) {
        reloadTimelines(ofKind: kind.rawValue)
    }
}

@available(iOS 18.0, *)
extension ControlCenter {
    func reloadControls(ofKind kind: ControlWidgetKind) {
        reloadControls(ofKind: kind.rawValue)
    }
}

@available(iOS 18.0, *)
extension StaticControlConfiguration {
    @MainActor @preconcurrency
    init<Provider>(kind: ControlWidgetKind,
                   provider: Provider,
                   @ControlWidgetTemplateBuilder content: @escaping (Provider.Value) -> Content)
    where Provider: ControlValueProvider {
        self.init(kind: kind.rawValue, provider: provider, content: content)
    }
}

func VPNReloadStatusWidgets() {
    WidgetCenter.shared.reloadTimelines(ofKind: .vpn)

    if #available(iOS 18.0, *) {
        ControlCenter.shared.reloadControls(ofKind: .vpn)
    }
}
