//
//  AppDelegate+Attribution.swift
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

import Foundation
import Common
import StoreKit
import AdAttributionKit
import os.log

extension AppDelegate {
    
    func updateAttribution(conversionValue: Int) {
        Task {
            if #available(iOS 17.4, *) {
                // https://developer.apple.com/documentation/adattributionkit/adattributionkit-skadnetwork-interoperability
                await updateAdAttributionKitPostback(conversionValue: conversionValue)
                await updateSKANPostback(conversionValue: conversionValue)
            } else if #available(iOS 16.1, *) {
                await updateSKANPostback(conversionValue: conversionValue)
            }
        }
    }

    @available(iOS 17.4, *)
    private func updateAdAttributionKitPostback(conversionValue: Int) async {
        do {
            try await AdAttributionKit.Postback.updateConversionValue(conversionValue, coarseConversionValue: .high, lockPostback: true)
            Logger.general.debug("Attribution: AdAttributionKit postback succeeded")
        } catch {
            Logger.general.error("Attribution: AdAttributionKit postback failed \(String(describing: error), privacy: .public)")
        }
    }

    @available(iOS 16.1, *)
    private func updateSKANPostback(conversionValue: Int) async {
        do {
            try await SKAdNetwork.updatePostbackConversionValue(conversionValue, coarseValue: .high, lockWindow: true)
            Logger.general.debug("Attribution: SKAN 4 postback succeeded")
        } catch let error {
            Logger.general.error("Attribution: SKAN 4 postback failed \(String(describing: error), privacy: .public)")
        }
    }

}
