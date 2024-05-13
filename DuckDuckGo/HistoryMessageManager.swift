//
//  HistoryMessageManager.swift
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
import Core

class HistoryMessageManager {

    @UserDefaultsWrapper(key: .historyMessageDisplayCount, defaultValue: 0)
    private var count: Int

    @UserDefaultsWrapper(key: .historyMessageDismissed, defaultValue: false)
    private var dismissed: Bool

    func incrementDisplayCount() {
        guard !dismissed else { return }
        count += 1
        if count >= 3 {
            dismissed = true
        }
    }

    func dismiss() {
        dismissed = true
    }

    func dismissedByUser() {
        dismissed = true
        Pixel.fire(pixel: .autocompleteMessageDismissed)
    }

    func shownToUser() {
        Pixel.fire(pixel: .autocompleteMessageShown)
    }

    func shouldShow() -> Bool {
        return !dismissed
    }

}
