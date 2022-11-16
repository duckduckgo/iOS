//
//  CrashCollectionExtension.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
import Crashes
import Core

/// The first crash flag can be removed in a few versions, once the new collection mechanism is bedded in.
///   In the mean time if we have a spike of crashes in the version this is released in we can see if it's because iOS has sent a bunch the first time
extension CrashCollection {

    static let firstCrashKey = "CrashCollection.first"

    static var firstCrash: Bool {
        get {
            UserDefaults().bool(forKey: Self.firstCrashKey, defaultValue: true)
        }

        set {
            UserDefaults().set(newValue, forKey: Self.firstCrashKey)
        }
    }

    static func firePixel(withAdditionalParameters params: [String: String], isFirstCollection first: Bool) {
        var params = params
        if first {
            params["first"] = "1"
        }
        Pixel.fire(pixel: .dbCrashDetected, withAdditionalParameters: params, includedParameters: [.appVersion])
    }

    static func start() {
        let first = Self.firstCrash
        CrashCollection.collectCrashesAsync { params in
            Self.firePixel(withAdditionalParameters: params, isFirstCollection: first)
        }
        // Turn the flag off for next time
        Self.firstCrash = false
    }

}
