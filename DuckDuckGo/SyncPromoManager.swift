//
//  SyncPromoManager.swift
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
import Bookmarks
import BrowserServicesKit
import Common
import Core
import Persistence
import DDGSync

protocol SyncPromoManaging {
    func shouldPresentPromoFor(_ touchpoint: SyncPromoManager.Touchpoint, count: Int) -> Bool
    func dismissPromoFor(_ touchpoint: SyncPromoManager.Touchpoint)
    func resetPromos()
}

final class SyncPromoManager: SyncPromoManaging {

    enum Touchpoint: String {
        case bookmarks
        case passwords
    }

    private let featureFlagger: FeatureFlagger
    private let syncService: DDGSyncing

    @UserDefaultsWrapper(key: .syncPromoBookmarksDismissed, defaultValue: nil)
    private var syncPromoBookmarksDismissed: Date?

    @UserDefaultsWrapper(key: .syncPromoPasswordsDismissed, defaultValue: nil)
    private var syncPromoPasswordsDismissed: Date?

    init(syncService: DDGSyncing,
         featureFlagger: FeatureFlagger = AppDependencyProvider.shared.featureFlagger) {
        self.featureFlagger = featureFlagger
        self.syncService = syncService
    }

    func shouldPresentPromoFor(_ touchpoint: Touchpoint, count: Int) -> Bool {
        switch touchpoint {
        case .bookmarks:
            if featureFlagger.isFeatureOn(.syncPromotionBookmarks),
               syncService.authState == .inactive,
               featureFlagger.isFeatureOn(.sync),
               syncPromoBookmarksDismissed == nil,
               count > 0 {
                return true
            }
        case .passwords:
            if featureFlagger.isFeatureOn(.syncPromotionPasswords),
               syncService.authState == .inactive,
               featureFlagger.isFeatureOn(.sync),
               syncPromoPasswordsDismissed == nil,
               count > 0 {
                return true
            }
        }

        return false
    }

    func dismissPromoFor(_ touchpoint: Touchpoint) {
        switch touchpoint {
        case .bookmarks:
            syncPromoBookmarksDismissed = Date()
        case .passwords:
            syncPromoPasswordsDismissed = Date()
        }

        Pixel.fire(.syncPromoDismissed, withAdditionalParameters: ["source": touchpoint.rawValue])
    }

    func resetPromos() {
        syncPromoBookmarksDismissed = nil
        syncPromoPasswordsDismissed = nil
    }
}
