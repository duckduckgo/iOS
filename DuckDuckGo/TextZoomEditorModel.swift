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

class TextZoomEditorModel: ObservableObject {

    let domain: String
    let storage: DomainTextZoomStoring

    var valueAsPercent: Int {
        TextZoomLevel.allCases[value].rawValue
    }

    @Published var value: Int = 0 {
        didSet {
            title = UserText.textZoomWithParcentSheetTitle(valueAsPercent)
            storage.set(textZoomLevel: TextZoomLevel.allCases[value], forDomain: domain)
            NotificationCenter.default.post(
                name: AppUserDefaults.Notifications.textSizeChange,
                object: nil)
        }
    }

    @Published var title: String = ""

    init(domain: String, storage: DomainTextZoomStoring, defaultTextZoom: TextZoomLevel) {
        self.domain = domain
        self.storage = storage
        let percent = (storage.textZoomLevelForDomain(domain) ?? defaultTextZoom)
        value = TextZoomLevel.allCases.firstIndex(of: percent) ?? 0
    }

    func increment() {
        value = min(TextZoomLevel.allCases.count - 1, value + 1)
    }

    func decrement() {
        value = max(0, value - 1)
    }

}
