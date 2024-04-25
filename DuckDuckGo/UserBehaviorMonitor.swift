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

public extension Notification.Name {

    static let userBehaviorDidMatchExperimentVariant = Notification.Name("com.duckduckgo.app.userBehaviorDidMatchExperimentVariant")

}

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

final class UserBehaviorMonitor {

    enum Action: Equatable {

        case refresh
        case reopenApp

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

    func handleAction(_ action: Action, date: Date = Date()) {
        switch action {
        case .refresh:
            fireEventIfActionOccurredRecently(within: 12.0, since: didRefreshTimestamp, eventToFire: .reloadTwiceWithin12Seconds)
            fireEventIfActionOccurredRecently(within: 24.0, since: didRefreshTimestamp, eventToFire: .reloadTwiceWithin24Seconds)
            didRefreshTimestamp = date
            
            if didRefreshCounter == 0 {
                didDoubleRefreshTimestamp = date
            }
            didRefreshCounter += 1
            if didRefreshCounter > 2 {
                fireEventIfActionOccurredRecently(within: 20.0, since: didDoubleRefreshTimestamp, eventToFire: .reloadThreeTimesWithin20Seconds)
                fireEventIfActionOccurredRecently(within: 40.0, since: didDoubleRefreshTimestamp, eventToFire: .reloadThreeTimesWithin40Seconds)
                didRefreshCounter = 0
            }
        case .reopenApp:
            fireEventIfActionOccurredRecently(within: 30.0, since: didRefreshTimestamp, eventToFire: .reloadAndRestartWithin30Seconds)
            fireEventIfActionOccurredRecently(within: 50.0, since: didRefreshTimestamp, eventToFire: .reloadAndRestartWithin50Seconds)
        }

        func fireEventIfActionOccurredRecently(within interval: Double = 30.0, since timestamp: Date?, eventToFire: UserBehaviorEvent) {
            if let timestamp = timestamp, date.timeIntervalSince(timestamp) < interval {
                eventMapping.fire(eventToFire)
                PixelExperiment.install() // Do we have better place to install it?
                if PixelExperiment.cohort == eventToFire.matchingPixelExperimentVariant {
                    NotificationCenter.default.post(name: .userBehaviorDidMatchExperimentVariant, 
                                                    object: self, 
                                                    userInfo: [UserBehaviorEvent.Key.event: eventToFire])
                }
            }
        }
    }

}

final class AppUserBehaviorMonitor {

    static let eventMapping = EventMapping<UserBehaviorEvent> { event, _, _, _ in
        let domainEvent: Pixel.Event
        switch event {
        case .reloadTwiceWithin12Seconds: domainEvent = .userBehaviorReloadTwiceWithin12Seconds
        case .reloadTwiceWithin24Seconds: domainEvent = .userBehaviorReloadTwiceWithin24Seconds
        case .reloadAndRestartWithin30Seconds: domainEvent = .userBehaviorReloadAndRestartWithin30Seconds
        case .reloadAndRestartWithin50Seconds: domainEvent = .userBehaviorReloadAndRestartWithin50Seconds
        case .reloadThreeTimesWithin20Seconds: domainEvent = .userBehaviorReloadThreeTimesWithin20Seconds
        case .reloadThreeTimesWithin40Seconds: domainEvent = .userBehaviorReloadThreeTimesWithin40Seconds
        }
        Pixel.fire(pixel: domainEvent)
    }

}
