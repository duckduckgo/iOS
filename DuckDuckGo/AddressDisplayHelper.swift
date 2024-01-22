//
//  AddressDisplayHelper.swift
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

extension OmniBar {

    struct AddressDisplayHelper {

        static func addressForDisplay(url: URL, showsFullURL: Bool) -> String {
            guard !showsFullURL, let shortAddress = shortURLString(url) else {
                return url.absoluteString
            }

            return shortAddress
        }

        /// Creates a string containing a short version the http(s) URL.
        ///
        /// - returns: URL's host without `www` component. `nil` if no host present or scheme does not match http(s).
        static func shortURLString(_ url: URL) -> String? {
            
            guard !url.isCustomURLScheme() else {
                return nil
            }

            return url.host?.droppingWwwPrefix()
        }
    }
}
