//
//  SyncPromoViewModel.swift
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

struct SyncPromoViewModel {

    enum SyncPromoViewModelType {
        case bookmarks
        case passwords
    }

    var modelType: SyncPromoViewModelType = .bookmarks

    var primaryButtonAction: (() -> Void)?
    var dismissButtonAction: (() -> Void)?

    var title: String {
        switch modelType {
        case .bookmarks, .passwords:
            UserText.syncPromoTitle
        }
    }

    var subtitle: String {
        switch modelType {
        case .bookmarks:
            UserText.syncPromoBookmarksMessage
        case .passwords:
            UserText.syncPromoPasswordsMessage
        }
    }

    var image: String {
        switch modelType {
        default:
            return "Sync-Start-96"
        }
    }

    var primaryButtonTitle: String {
        switch modelType {
        case .bookmarks, .passwords:
            UserText.syncPromoConfirmAction
        }
    }

    var secondaryButtonTitle: String {
        switch modelType {
        case .bookmarks, .passwords:
            UserText.syncPromoDismissAction
        }
    }
}
