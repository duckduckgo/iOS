//
//  AdAttributionPixelReporterTests.swift
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

import Core
import XCTest

@testable import DuckDuckGo

final class AdAttributionPixelReporterTests: XCTestCase {

    private var attributionFetcher: AdAttributionFetcherMock!
    private var fetcherStorage: AdAttributionReporterStorageMock!

    override func setUpWithError() throws {
        attributionFetcher = AdAttributionFetcherMock()
        fetcherStorage = AdAttributionReporterStorageMock()
    }

    override func tearDownWithError() throws {
        attributionFetcher = nil
        fetcherStorage = nil
        PixelFiringMock.tearDown()
    }

    func testReportsAttribution() async {
        let sut = createSUT()
        attributionFetcher.fetchResponse = AdServicesAttributionResponse(attribution: true)

        let result = await sut.reportAttributionIfNeeded()

        XCTAssertEqual(PixelFiringMock.lastPixel, .appleAdAttribution)
        XCTAssertTrue(result)
    }

    func testReportsOnce() async {
        let sut = createSUT()
        attributionFetcher.fetchResponse = AdServicesAttributionResponse(attribution: true)

        await fetcherStorage.markAttributionReportSuccessful()
        let result = await sut.reportAttributionIfNeeded()

        XCTAssertNil(PixelFiringMock.lastPixel)
        XCTAssertFalse(result)
    }

    func testPixelname() async {
        let sut = createSUT()
        attributionFetcher.fetchResponse = AdServicesAttributionResponse(attribution: true)

        let result = await sut.reportAttributionIfNeeded()

        XCTAssertEqual(PixelFiringMock.lastPixel?.name, "m_apple-ad-attribution")
        XCTAssertTrue(result)
    }

    func testPixelAttributesNaming() async throws {
        let sut = createSUT()
        attributionFetcher.fetchResponse = AdServicesAttributionResponse(attribution: true)

        await sut.reportAttributionIfNeeded()

        let pixelAttributes = try XCTUnwrap(PixelFiringMock.lastParams)

        XCTAssertEqual(pixelAttributes["org_id"], "1")
        XCTAssertEqual(pixelAttributes["campaign_id"], "2")
        XCTAssertEqual(pixelAttributes["conversion_type"], "conversionType")
        XCTAssertEqual(pixelAttributes["ad_group_id"], "3")
        XCTAssertEqual(pixelAttributes["country_or_region"], "countryOrRegion")
        XCTAssertEqual(pixelAttributes["keyword_id"], "4")
        XCTAssertEqual(pixelAttributes["ad_id"], "5")
    }

    func testPixelAdditionalParameters() async throws {
        let sut = createSUT()
        attributionFetcher.fetchResponse = AdServicesAttributionResponse(attribution: true)

        await sut.reportAttributionIfNeeded()

        let pixelAttributes = try XCTUnwrap(PixelFiringMock.lastIncludedParams)

        XCTAssertEqual(pixelAttributes, [.appVersion, .atb])
    }

    func testPixelAttributes_WhenPartialAttributionData() async throws {
        let sut = createSUT()
        attributionFetcher.fetchResponse = AdServicesAttributionResponse(
            attribution: true,
            orgId: 1,
            campaignId: 2,
            conversionType: "conversionType",
            adGroupId: nil,
            countryOrRegion: nil,
            keywordId: nil,
            adId: nil
        )

        await sut.reportAttributionIfNeeded()

        let pixelAttributes = try XCTUnwrap(PixelFiringMock.lastParams)

        XCTAssertEqual(pixelAttributes["org_id"], "1")
        XCTAssertEqual(pixelAttributes["campaign_id"], "2")
        XCTAssertEqual(pixelAttributes["conversion_type"], "conversionType")
        XCTAssertNil(pixelAttributes["ad_group_id"])
        XCTAssertNil(pixelAttributes["country_or_region"])
        XCTAssertNil(pixelAttributes["keyword_id"])
        XCTAssertNil(pixelAttributes["ad_id"])
    }

    func testPixelNotFiredAndMarksReport_WhenAttributionFalse() async {
        let sut = createSUT()
        attributionFetcher.fetchResponse = AdServicesAttributionResponse(attribution: false)

        let result = await sut.reportAttributionIfNeeded()

        XCTAssertNil(PixelFiringMock.lastPixel)
        XCTAssertTrue(fetcherStorage.wasAttributionReportSuccessful)
        XCTAssertTrue(result)
    }

    func testPixelNotFiredAndReportNotMarked_WhenAttributionUnavailable() async {
        let sut = createSUT()
        attributionFetcher.fetchResponse = nil

        let result = await sut.reportAttributionIfNeeded()

        XCTAssertNil(PixelFiringMock.lastPixel)
        XCTAssertFalse(fetcherStorage.wasAttributionReportSuccessful)
        XCTAssertFalse(result)
    }

    func testDoesNotMarkSuccessful_WhenPixelFiringFailed() async {
        let sut = createSUT()
        attributionFetcher.fetchResponse = AdServicesAttributionResponse(attribution: true)
        PixelFiringMock.expectedFireError = NSError(domain: "PixelFailure", code: 1)

        let result = await sut.reportAttributionIfNeeded()

        XCTAssertFalse(fetcherStorage.wasAttributionReportSuccessful)
        XCTAssertFalse(result)
    }

    private func createSUT() -> AdAttributionPixelReporter {
        AdAttributionPixelReporter(fetcherStorage: fetcherStorage,
                                   attributionFetcher: attributionFetcher,
                                   pixelFiring: PixelFiringMock.self)
    }
}

class AdAttributionReporterStorageMock: AdAttributionReporterStorage {
    func markAttributionReportSuccessful() async {
        wasAttributionReportSuccessful = true
    }
    
    private(set) var wasAttributionReportSuccessful: Bool = false
}

class AdAttributionFetcherMock: AdAttributionFetcher {
    var fetchResponse: AdServicesAttributionResponse?
    func fetch() async -> AdServicesAttributionResponse? {
        fetchResponse
    }
}

extension AdServicesAttributionResponse {
    init(attribution: Bool) {
        self.init(
            attribution: attribution,
            orgId: 1,
            campaignId: 2,
            conversionType: "conversionType",
            adGroupId: 3,
            countryOrRegion: "countryOrRegion",
            keywordId: 4,
            adId: 5
        )
    }
}
