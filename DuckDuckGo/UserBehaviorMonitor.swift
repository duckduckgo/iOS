//
//  UserBehaviorMonitor.swift
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
import Common
import Core

final class UserBehaviorMonitor {

    enum Action: Equatable {

        case refresh
        case burn
        case reopenApp
        case openSettings
        case toggleProtections

    }

    private let eventMapping: EventMapping<UserBehaviorEvent>
    init(eventMapping: EventMapping<UserBehaviorEvent> = AppUserBehaviorMonitor.eventMapping) {
        self.eventMapping = eventMapping
    }

    @UserDefaultsWrapper(key: .didRefreshTimestamp, defaultValue: .distantPast)
    private var didRefreshTimestamp: Date?
    @UserDefaultsWrapper(key: .didBurnTimestamp, defaultValue: .distantPast)
    private var didBurnTimestamp: Date?

    func handleAction(_ action: Action, date: Date = Date()) {
        switch action {
        case .refresh:
            fireEventIfActionOccurredRecently(since: didRefreshTimestamp, eventToFire: .reloadTwice, within: 10.0)
            didRefreshTimestamp = date
        case .burn:
            fireEventIfActionOccurredRecently(since: didRefreshTimestamp, eventToFire: .reloadAndFireButton)
            didBurnTimestamp = date
        case .reopenApp:
            fireEventIfActionOccurredRecently(since: didRefreshTimestamp, eventToFire: .reloadAndRestart)
            fireEventIfActionOccurredRecently(since: didBurnTimestamp, eventToFire: .fireButtonAndRestart)
        case .openSettings:
            fireEventIfActionOccurredRecently(since: didRefreshTimestamp, eventToFire: .reloadAndOpenSettings)
        case .toggleProtections:
            fireEventIfActionOccurredRecently(since: didRefreshTimestamp, eventToFire: .reloadAndTogglePrivacyControls)
            fireEventIfActionOccurredRecently(since: didBurnTimestamp, eventToFire: .fireButtonAndTogglePrivacyControls)
        }

        func fireEventIfActionOccurredRecently(since timestamp: Date?, eventToFire: UserBehaviorEvent, within interval: Double = 30.0) {
            if let timestamp = timestamp, date.timeIntervalSince(timestamp) < interval {
                eventMapping.fire(eventToFire)
            }
        }
    }

}

final class AppUserBehaviorMonitor {

    static let eventMapping = EventMapping<UserBehaviorEvent> { event, _, _, _ in
        let domainEvent: Pixel.Event
        switch event {
        case .reloadTwice: domainEvent = .userBehaviorReloadTwice
        case .reloadAndRestart: domainEvent = .userBehaviorReloadAndRestart
        case .reloadAndFireButton: domainEvent = .userBehaviorReloadAndFireButton
        case .reloadAndOpenSettings: domainEvent = .userBehaviorReloadAndOpenSettings
        case .reloadAndTogglePrivacyControls: domainEvent = .userBehaviorReloadAndTogglePrivacyControls
        case .fireButtonAndRestart: domainEvent = .userBehaviorFireButtonAndRestart
        case .fireButtonAndTogglePrivacyControls: domainEvent = .userBehaviorFireButtonAndTogglePrivacyControls
        }
        Pixel.fire(pixel: domainEvent)
    }

}
