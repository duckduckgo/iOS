//
//  AtbAndVariantCleanup.swift
//  DuckDuckGo
//
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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
import BrowserServicesKit

public class AtbAndVariantCleanup {

    static func cleanup(statisticsStorage: StatisticsStore = StatisticsUserDefaults(),
                        variantManager: VariantManager = DefaultVariantManager()) {

        guard let variant = statisticsStorage.variant else { return }

        // clean up ATB
        if let atb = statisticsStorage.atb, atb.hasSuffix(variant) {
            statisticsStorage.atb = String(atb.dropLast(variant.count))
        }

        // remove existing variant if not in an active experiment
        if variantManager.currentVariant == nil {
            statisticsStorage.variant = nil
        }

    }

}
