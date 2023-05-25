//
//  MacPromoExperiment.swift
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

/**
 Encapsulate logic for showing the two types of promo.

 Decision making for showing the promo is based on the following:
 * Is the RMF message enabled?
 * For the sheet: has it been shown already?  The RMF message handles this already (via dismiss button)
 * Is it enabled in the current variant?
 * Is it at least 3 days since install?

 */
public struct MacPromoExperiment {

    public init() { }

    public func shouldShowSheet() -> Bool {
        return true
    }

    public func shouldShowMessage() -> Bool {
        return false
    }

    public func sheetWasShown() {
    }

}
