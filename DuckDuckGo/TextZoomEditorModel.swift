//
//  TextZoomEditorModel.swift
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
import Core

class TextZoomEditorModel: ObservableObject {

    let domain: String
    let coordinator: TextZoomCoordinating
    let initialValue: TextZoomLevel

    var valueAsPercent: Int {
        TextZoomLevel.allCases[value].rawValue
    }

    @Published var value: Int = 0 {
        didSet {
            valueWasSet()
        }
    }

    @Published var title: String = ""

    init(domain: String, coordinator: TextZoomCoordinating, defaultTextZoom: TextZoomLevel) {
        self.domain = domain
        self.coordinator = coordinator
        self.initialValue = coordinator.textZoomLevel(forHost: domain)
        value = TextZoomLevel.allCases.firstIndex(of: initialValue) ?? 0
    }

    func increment() {
        value = min(TextZoomLevel.allCases.count - 1, value + 1)
    }

    func decrement() {
        value = max(0, value - 1)
    }

    private func valueWasSet() {
        title = UserText.textZoomWithPercentSheetTitle(TextZoomLevel.allCases[value].rawValue)
        coordinator.set(textZoomLevel: TextZoomLevel.allCases[value], forHost: domain)
        NotificationCenter.default.post(
            name: AppUserDefaults.Notifications.textZoomChange,
            object: nil)
    }

    func onDismiss() {
        guard initialValue.rawValue != TextZoomLevel.allCases[value].rawValue else { return }
        DailyPixel.fire(pixel: .textZoomChangedOnPageDaily)
        Pixel.fire(.textZoomChangedOnPage, withAdditionalParameters: [
            PixelParameters.textZoomInitial: String(initialValue.rawValue),
            PixelParameters.textZoomUpdated: String(TextZoomLevel.allCases[value].rawValue),
        ])
    }

}
