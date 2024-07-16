//
//  OnboardingSuggestedSitesProviderTests.swift
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

import XCTest
@testable import DuckDuckGo

class OnboardingSuggestedSitesProviderTests: XCTestCase {

    func testSuggestedSitesForIndonesia() {
        // GIVEN
        let mockProvider = MockOnboardingRegionAndLanguageProvider(regionCode: "ID", languageCode: "")
        let sut = OnboardingSuggestedSitesProvider(countryProvider: mockProvider)

        // WHEN
        let sitesList = sut.list

        // THEN
        XCTAssertEqual(sitesList[0], ContextualOnboardingListItem.site(title: "bolasport.com"))
        XCTAssertEqual(sitesList[1], ContextualOnboardingListItem.site(title: "kompas.com"))
        XCTAssertEqual(sitesList[2], ContextualOnboardingListItem.site(title: "tokopedia.com"))
        XCTAssertEqual(sitesList[3], ContextualOnboardingListItem.surprise(title: "britannica.com/animal/duck"))
    }

    func testSuggestedSitesForGB() {
        // GIVEN
        let mockProvider = MockOnboardingRegionAndLanguageProvider(regionCode: "GB", languageCode: "")
        let sut = OnboardingSuggestedSitesProvider(countryProvider: mockProvider)

        // WHEN
        let sitesList = sut.list

        // THEN
        XCTAssertEqual(sitesList[0], ContextualOnboardingListItem.site(title: "skysports.com"))
        XCTAssertEqual(sitesList[1], ContextualOnboardingListItem.site(title: "bbc.co.uk"))
        XCTAssertEqual(sitesList[2], ContextualOnboardingListItem.site(title: "eBay.com"))
        XCTAssertEqual(sitesList[3], ContextualOnboardingListItem.surprise(title: "britannica.com/animal/duck"))
    }

    func testSuggestedSitesForGermany() {
        // GIVEN
        let mockProvider = MockOnboardingRegionAndLanguageProvider(regionCode: "DE", languageCode: "")
        let sut = OnboardingSuggestedSitesProvider(countryProvider: mockProvider)

        // WHEN
        let sitesList = sut.list

        // THEN
        XCTAssertEqual(sitesList[0], ContextualOnboardingListItem.site(title: "kicker.de"))
        XCTAssertEqual(sitesList[1], ContextualOnboardingListItem.site(title: "tagesschau.de"))
        XCTAssertEqual(sitesList[2], ContextualOnboardingListItem.site(title: "eBay.com"))
        XCTAssertEqual(sitesList[3], ContextualOnboardingListItem.surprise(title: "https://www.duden.de/rechtschreibung/Ente"))
    }

    func testSuggestedSitesForCanada() {
        // GIVEN
        let mockProvider = MockOnboardingRegionAndLanguageProvider(regionCode: "CA", languageCode: "")
        let sut = OnboardingSuggestedSitesProvider(countryProvider: mockProvider)

        // WHEN
        let sitesList = sut.list

        // THEN
        XCTAssertEqual(sitesList[0], ContextualOnboardingListItem.site(title: "tsn.ca"))
        XCTAssertEqual(sitesList[1], ContextualOnboardingListItem.site(title: "cbc.ca"))
        XCTAssertEqual(sitesList[2], ContextualOnboardingListItem.site(title: "canadiantire.ca"))
        XCTAssertEqual(sitesList[3], ContextualOnboardingListItem.surprise(title: "britannica.com/animal/duck"))
    }

    func testSuggestedSitesForNetherlands() {
        // GIVEN
        let mockProvider = MockOnboardingRegionAndLanguageProvider(regionCode: "NL", languageCode: "")
        let sut = OnboardingSuggestedSitesProvider(countryProvider: mockProvider)

        // WHEN
        let sitesList = sut.list

        // THEN
        XCTAssertEqual(sitesList[0], ContextualOnboardingListItem.site(title: "voetbalprimeur.nl"))
        XCTAssertEqual(sitesList[1], ContextualOnboardingListItem.site(title: "nu.nl"))
        XCTAssertEqual(sitesList[2], ContextualOnboardingListItem.site(title: "bol.com"))
        XCTAssertEqual(sitesList[3], ContextualOnboardingListItem.surprise(title: "https://www.woorden.org/woord/eend"))
    }

    func testSuggestedSitesForAustralia() {
        // GIVEN
        let mockProvider = MockOnboardingRegionAndLanguageProvider(regionCode: "AU", languageCode: "")
        let sut = OnboardingSuggestedSitesProvider(countryProvider: mockProvider)

        // WHEN
        let sitesList = sut.list

        // THEN
        XCTAssertEqual(sitesList[0], ContextualOnboardingListItem.site(title: "afl.com.au"))
        XCTAssertEqual(sitesList[1], ContextualOnboardingListItem.site(title: "abc.net.au"))
        XCTAssertEqual(sitesList[2], ContextualOnboardingListItem.site(title: "eBay.com"))
        XCTAssertEqual(sitesList[3], ContextualOnboardingListItem.surprise(title: "britannica.com/animal/duck"))
    }

    func testSuggestedSitesForSweden() {
        // GIVEN
        let mockProvider = MockOnboardingRegionAndLanguageProvider(regionCode: "SE", languageCode: "")
        let sut = OnboardingSuggestedSitesProvider(countryProvider: mockProvider)

        // WHEN
        let sitesList = sut.list

        // THEN
        XCTAssertEqual(sitesList[0], ContextualOnboardingListItem.site(title: "svenskafans.com"))
        XCTAssertEqual(sitesList[1], ContextualOnboardingListItem.site(title: "dn.se"))
        XCTAssertEqual(sitesList[2], ContextualOnboardingListItem.site(title: "tradera.com"))
        XCTAssertEqual(sitesList[3], ContextualOnboardingListItem.surprise(title: "https://www.synonymer.se/sv-syn/anka"))
    }

    func testSuggestedSitesForIreland() {
        // GIVEN
        let mockProvider = MockOnboardingRegionAndLanguageProvider(regionCode: "IE", languageCode: "")
        let sut = OnboardingSuggestedSitesProvider(countryProvider: mockProvider)

        // WHEN
        let sitesList = sut.list

        // THEN
        XCTAssertEqual(sitesList[0], ContextualOnboardingListItem.site(title: "skysports.com"))
        XCTAssertEqual(sitesList[1], ContextualOnboardingListItem.site(title: "bbc.co.uk"))
        XCTAssertEqual(sitesList[2], ContextualOnboardingListItem.site(title: "eBay.com"))
        XCTAssertEqual(sitesList[3], ContextualOnboardingListItem.surprise(title: "britannica.com/animal/duck"))
    }

    func testSuggestedSitesForUS() {
        // GIVEN
        let mockProvider = MockOnboardingRegionAndLanguageProvider(regionCode: "US", languageCode: "")
        let sut = OnboardingSuggestedSitesProvider(countryProvider: mockProvider)

        // WHEN
        let sitesList = sut.list

        // THEN
        XCTAssertEqual(sitesList[0], ContextualOnboardingListItem.site(title: "ESPN.com"))
        XCTAssertEqual(sitesList[1], ContextualOnboardingListItem.site(title: "yahoo.com"))
        XCTAssertEqual(sitesList[2], ContextualOnboardingListItem.site(title: "eBay.com"))
        XCTAssertEqual(sitesList[3], ContextualOnboardingListItem.surprise(title: "britannica.com/animal/duck"))
    }

    func testSuggestedSitesForUnknownCountry() {
        // GIVEN
        let mockProvider = MockOnboardingRegionAndLanguageProvider(regionCode: "UNKNOWN", languageCode: "")
        let sut = OnboardingSuggestedSitesProvider(countryProvider: mockProvider)

        // WHEN
        let sitesList = sut.list

        // THEN
        XCTAssertEqual(sitesList[0], ContextualOnboardingListItem.site(title: "ESPN.com"))
        XCTAssertEqual(sitesList[1], ContextualOnboardingListItem.site(title: "yahoo.com"))
        XCTAssertEqual(sitesList[2], ContextualOnboardingListItem.site(title: "eBay.com"))
        XCTAssertEqual(sitesList[3], ContextualOnboardingListItem.surprise(title: "britannica.com/animal/duck"))
    }
}
