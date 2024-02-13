//
//  AppDelegate+SKAD4.swift
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
import StoreKit
import Common

extension AppDelegate {
    
    func update(conversionValue: Int) {
        
        if #available(iOS 16.1, *) {
            SKAdNetwork.updatePostbackConversionValue(conversionValue, coarseValue: .high, lockWindow: true, completionHandler: { error in
                if let error = error {
                    os_log("SKAD 4 postback failed %@", type: .error, error.localizedDescription)
                }
            })
        } else {
            os_log("SKAD 4 Not supported in this iOS version", type: .debug)
        }
    }
}
