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
    let storage: DomainTextZoomStoring
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

    init(domain: String, storage: DomainTextZoomStoring, defaultTextZoom: TextZoomLevel) {
        self.domain = domain
        self.storage = storage
        self.initialValue = (storage.textZoomLevelForDomain(domain) ?? defaultTextZoom)
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
        storage.set(textZoomLevel: TextZoomLevel.allCases[value], forDomain: domain)
        NotificationCenter.default.post(
            name: AppUserDefaults.Notifications.textSizeChange,
            object: nil)
        DailyPixel.fire(pixel: .zoomChangedOnPageDaily)
    }

    func onDismiss() {
        guard initialValue.rawValue != TextZoomLevel.allCases[value].rawValue else { return }
        Pixel.fire(.zoomChangedOnPage, withAdditionalParameters: [
            "text_size_initial": String(initialValue.rawValue),
            "text_size_updated": String(TextZoomLevel.allCases[value].rawValue),
        ])
    }

}
