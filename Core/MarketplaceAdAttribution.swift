//
//  MarketplaceAdPostbackUpdater.swift
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
import AdAttributionKit
import os.log
import StoreKit

/// Updates anonymous attribution values.
///
/// DuckDuckGo uses the SKAdNetwork framework to monitor anonymous install attribution data.
/// No personally identifiable data is involved.
/// DuckDuckGo does not use the App Tracking Transparency framework at any point.
/// See https://developer.apple.com/documentation/storekit/skadnetwork/ for details.
///

protocol MarketplaceAdPostbackUpdating {
    func updatePostback(_ postback: MarketplaceAdPostback, lockPostback: Bool)
}

struct MarketplaceAdPostbackUpdater: MarketplaceAdPostbackUpdating {
    func updatePostback(_ postback: MarketplaceAdPostback, lockPostback: Bool) {
        Task {
            if #available(iOS 17.4, *) {
                // https://developer.apple.com/documentation/adattributionkit/adattributionkit-skadnetwork-interoperability
                await updateAdAttributionKitPostback(postback, lockPostback: lockPostback)
                await updateSKANPostback(postback, lockPostback: lockPostback)
            } else if #available(iOS 16.1, *) {
                await updateSKANPostback(postback, lockPostback: lockPostback)
            }
        }
    }

    @available(iOS 17.4, *)
    private func updateAdAttributionKitPostback(_ postback: MarketplaceAdPostback, lockPostback: Bool) async {
        do {
            try await AdAttributionKit.Postback.updateConversionValue(postback.fineValue,
                                                                      coarseConversionValue: postback.adAttributionKitCoarseValue,
                                                                      lockPostback: lockPostback)
            Logger.general.debug("Attribution: AdAttributionKit postback succeeded")
        } catch {
            Logger.general.error("Attribution: AdAttributionKit postback failed \(error.localizedDescription, privacy: .public)")
        }
    }

    @available(iOS 16.1, *)
    private func updateSKANPostback(_ postback: MarketplaceAdPostback, lockPostback: Bool) async {
        do {
            try await SKAdNetwork.updatePostbackConversionValue(postback.fineValue,
                                                                coarseValue: postback.SKAdCoarseValue,
                                                                lockWindow: lockPostback)
            Logger.general.debug("Attribution: SKAN 4 postback succeeded")
        } catch {
            Logger.general.error("Attribution: SKAN 4 postback failed \(error.localizedDescription, privacy: .public)")
        }
    }
}
