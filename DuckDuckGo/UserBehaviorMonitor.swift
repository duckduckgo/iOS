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

protocol UserBehaviorStoring {

    var didRefreshTimestamp: Date? { get set }
    var didDoubleRefreshTimestamp: Date? { get set }
    var didRefreshCounter: Int { get set }

}

final class UserBehaviorStore: UserBehaviorStoring {

    @UserDefaultsWrapper(key: .didRefreshTimestamp, defaultValue: .distantPast)
    var didRefreshTimestamp: Date?

    @UserDefaultsWrapper(key: .didDoubleRefreshTimestamp, defaultValue: .distantPast)
    var didDoubleRefreshTimestamp: Date?

    @UserDefaultsWrapper(key: .didRefreshCounter, defaultValue: 0)
    var didRefreshCounter: Int

}

public enum UserBehaviorEvent: String {

    case reloadTwiceWithin12Seconds = "reload-twice-within-12-seconds"
    case reloadThreeTimesWithin20Seconds = "reload-three-times-within-20-seconds"

}

final class UserBehaviorMonitor {

    enum Action: Equatable {

        case refresh

    }

    private let eventMapping: EventMapping<UserBehaviorEvent>
    private var store: UserBehaviorStoring

    init(eventMapping: EventMapping<UserBehaviorEvent> = AppUserBehaviorMonitor.eventMapping,
         store: UserBehaviorStoring = UserBehaviorStore()) {
        self.eventMapping = eventMapping
        self.store = store
    }

    var didRefreshTimestamp: Date? {
        get { store.didRefreshTimestamp }
        set { store.didRefreshTimestamp = newValue }
    }

    var didDoubleRefreshTimestamp: Date? {
        get { store.didDoubleRefreshTimestamp }
        set { store.didDoubleRefreshTimestamp = newValue }
    }

    var didRefreshCounter: Int {
        get { store.didRefreshCounter }
        set { store.didRefreshCounter = newValue }
    }

    func handleRefreshAction(date: Date = Date()) {
        fireEventIfActionOccurredRecently(within: 12.0, since: didRefreshTimestamp, eventToFire: .reloadTwiceWithin12Seconds)
        didRefreshTimestamp = date

        if didRefreshCounter == 0 {
            didDoubleRefreshTimestamp = date
        }
        didRefreshCounter += 1
        if didRefreshCounter > 2 {
            fireEventIfActionOccurredRecently(within: 20.0, since: didDoubleRefreshTimestamp, eventToFire: .reloadThreeTimesWithin20Seconds)
            didRefreshCounter = 0
        }

        func fireEventIfActionOccurredRecently(within interval: Double = 30.0, since timestamp: Date?, eventToFire: UserBehaviorEvent) {
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
        case .reloadTwiceWithin12Seconds: domainEvent = .userBehaviorReloadTwiceWithin12Seconds
        case .reloadThreeTimesWithin20Seconds: domainEvent = .userBehaviorReloadThreeTimesWithin20Seconds
        }
        Pixel.fire(pixel: domainEvent)
    }

}
