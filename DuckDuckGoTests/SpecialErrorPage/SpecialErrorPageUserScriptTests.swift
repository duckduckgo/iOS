//
//  SpecialErrorPageUserScriptTests.swift
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

import Testing
import SpecialErrorPages
@testable import DuckDuckGo

@Suite("Special Error Pages - SpecialErrorPageUserScript Unit Tests", .serialized)
struct SpecialErrorPageUserScriptTests {

    @Test
    func localeStringsForNotSupportedLanguage() {
        // Given
        let languageCode = "ko"

        // When
        let result = SpecialErrorPageUserScript.localeStrings(for: languageCode)

        // Then
        #expect(result == nil, "The result should be nil for Korean language")
    }

    @Test
    func localeStringsForPolishLanguage() throws {
        // Given
        let languageCode = "pl"

        // When
        let result = try #require(SpecialErrorPageUserScript.localeStrings(for: languageCode))

        // Then
        #expect(result != nil, "The result should not be nil for the Polish language code.")
        let expectedSubstring = "Ostrzeżenie: ta witryna może być niebezpieczna"
        #expect(result.contains(expectedSubstring), "The result should contain the expected Polish string.")
    }

}
