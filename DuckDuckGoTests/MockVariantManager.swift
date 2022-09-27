//
//  MockVariantManager.swift
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
@testable import BrowserServicesKit

struct MockVariantManager: VariantManager {

    var isSupportedReturns = false {
        didSet {
            let newValue = isSupportedReturns
            isSupportedBlock = { _ in return newValue }
        }
    }
    
    var isSupportedBlock: (FeatureName) -> Bool

    var currentVariant: Variant?

    init(isSupportedReturns: Bool = false, currentVariant: Variant? = nil) {
        self.isSupportedReturns = isSupportedReturns
        self.isSupportedBlock = { _ in return isSupportedReturns }
        self.currentVariant = currentVariant
    }

    func assignVariantIfNeeded(_ newInstallCompletion: (VariantManager) -> Void) {
    }
    
    func isSupported(feature: FeatureName) -> Bool {
        return isSupportedBlock(feature)
    }

}
