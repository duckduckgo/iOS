//
//  SyncErrorHandler.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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

import Common
import DDGSync
import Foundation

public class SyncErrorHandler: EventMapping<SyncError> {

    public init() {
        super.init { event, error, _, _ in
            switch event {
            case .failedToMigrate:
                Pixel.fire(pixel: .syncFailedToMigrate, error: error)
            case .failedToLoadAccount:
                Pixel.fire(pixel: .syncFailedToLoadAccount, error: error)
            case .failedToSetupEngine:
                Pixel.fire(pixel: .syncFailedToSetupEngine, error: error)
            default:
                // Should this be so generic?
                let domainEvent = Pixel.Event.syncSentUnauthenticatedRequest
                Pixel.fire(pixel: domainEvent, error: event)
            }

        }
    }

    override init(mapping: @escaping EventMapping<SyncError>.Mapping) {
        fatalError("Use init()")
    }
}
