//
//  ThreatProtectionEventMapper.swift
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
import PhishingDetection
import Core
import PixelKit

final class ThreatProtectionEventMapper: EventMapping<PhishingDetectionEvents> {

    public init() {
        super.init { event, _, _, _ in
            switch event {
            case let .errorPageShown(clientSideHit):
                PixelKit.fire(PhishingDetectionEvents.errorPageShown(clientSideHit: clientSideHit))
            case .iframeLoaded:
                PixelKit.fire(PhishingDetectionEvents.iframeLoaded)
            case .visitSite:
                PixelKit.fire(PhishingDetectionEvents.visitSite)
            case let .updateTaskFailed48h(error):
                PixelKit.fire(PhishingDetectionEvents.updateTaskFailed48h(error: error))
            case let .settingToggled(settingState):
                PixelKit.fire(PhishingDetectionEvents.settingToggled(to: settingState))
            }
        }
    }

    @available(*, unavailable)
    override init(mapping: @escaping EventMapping<PhishingDetectionEvents>.Mapping) {
        fatalError("Use init()")
    }

}
