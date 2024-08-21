//
//  RetentionSegmentation.swift
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

protocol RetentionSegmenting {

    func processATB(_ atb: Atb)

}

class RetentionSegmentation: RetentionSegmenting {

    private let pixelFiring: DailyPixelFiring.Type
    private var storage: RetentionSegmentationStoring

    init(pixelFiring: DailyPixelFiring.Type = DailyPixel.self,
         storage: RetentionSegmentationStoring = RetentionSegmentationStorage()) {
        self.pixelFiring = pixelFiring
        self.storage = storage
    }

    func processATB(_ atb: Atb) {
        // Check most recent entries first so we exit faster
        guard !storage.atbs.reversed().contains(where: { $0 == atb }) else { return }

        storage.atbs.append(atb)
        pixelFiring.fireDaily(.retentionSegments)
    }

}
