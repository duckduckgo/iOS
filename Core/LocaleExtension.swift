//
//  LocaleExtension.swift
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

extension Locale {
    
    public var isRegionInEurope: Bool {
        ["AD", "AL", "AT", "AZ", "BA", "BE", "BG", "BY", "CH", "CY", "CZ", "DE", "DK", "EE", "ES",
         "FI", "FR", "GE", "GI", "GR", "HR", "HU", "IE", "IS", "IT", "KZ", "LI", "LT", "LU", "LV",
         "MC", "MD", "ME", "MK", "MT", "NL", "NO", "PL", "PT", "RO", "RS", "RU", "SE", "SI", "SK",
         "SM", "TR", "UA", "GB", "VA"].contains(regionCode)
    }

    public var isEnglishLanguage: Bool {
        return Locale.preferredLanguages.first?.lowercased().starts(with: "en") ?? false
    }
}
