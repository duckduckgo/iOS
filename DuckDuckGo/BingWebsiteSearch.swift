//
//  BingWebsiteSearch.swift
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
import Core
import BrowserServicesKit
import Common

struct WebPageSearchResultValue: Identifiable, Hashable {
    let id: String
    let name: String
    let displayUrl: String
    let url: URL
}

protocol WebsiteSearch {
    func search(term: String) async throws -> [WebPageSearchResultValue]
}

struct BingWebsiteSearch {

    private let searchURL = URL(string: "https://api.bing.microsoft.com/v7.0/search")!
    private let subscriptionIDStorage = FavoritesBingSubscriptionStorage()
    private let tld = TLD()

    func search(term: String) async throws -> [BingWebPageSearchResultValue] {
        let request = createRequest(term: term)
        let result = try await URLSession.shared.data(for: request)

        if let urlResponse = result.1 as? HTTPURLResponse, urlResponse.isSuccessfulResponse {
            let searchResult = try JSONDecoder().decode(BingSearchResponse.self, from: result.0)
            
            let uniqueTLDResults = uniquingByTLDs(searchResult.webPages.value)

            return uniqueTLDResults
        } else {
            let errorPayload = try JSONDecoder().decode(BingErrorPayload.self, from: result.0)
            throw errorPayload.error
        }
    }

    private func uniquingByTLDs(_ results: [BingWebPageSearchResultValue]) -> [BingWebPageSearchResultValue] {

        var seenTLDs = Set<String>()

        return results.filter { searchResult in
            guard let tldPlus1 = tld.eTLDplus1(forStringURL: searchResult.url.absoluteString),
                  !seenTLDs.contains(tldPlus1)
            else {
                return false
            }

            seenTLDs.insert(tldPlus1)
            return true
        }
    }

    private func createRequest(term: String) -> URLRequest {
        let searchTermQueryItem = URLQueryItem(name: "q", value: term)
        let filterQueryItem = URLQueryItem(name: "responseFilter", value: "webpages")
        let marketQueryItem = URLQueryItem(name: "mkt", value: Locale.current.identifier)
        let countQueryItem = URLQueryItem(name: "count", value: "20")

        let queryItems = [
            searchTermQueryItem,
            filterQueryItem,
            marketQueryItem,
            countQueryItem
        ]

        let url = searchURL
            .appending(percentEncodedQueryItems: queryItems)
        var request = URLRequest(url: url)
        request.addValue(subscriptionIDStorage.subscriptionID, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")

        return request
    }
}

private struct BingErrorPayload: Codable {
    let error: BingError
}

struct BingError: Error, Codable {
    let code: String
    let message: String
}

private struct BingSearchResponse: Codable {
    let webPages: BingWebPagesSearchResult
}

private struct BingWebPagesSearchResult: Codable {
    let value: [BingWebPageSearchResultValue]
}

struct BingWebPageSearchResultValue: Codable {
    let id: String
    let name: String
    let displayUrl: String
    let url: URL
}

extension BingWebsiteSearch: WebsiteSearch {
    func search(term: String) async throws -> [WebPageSearchResultValue] {
        try await search(term: term).map { (bingResult: BingWebPageSearchResultValue) in
            WebPageSearchResultValue(id: bingResult.id, name: bingResult.name, displayUrl: bingResult.displayUrl, url: bingResult.url)
        }
    }
}

final class FavoritesBingSubscriptionStorage {
    @UserDefaultsWrapper(key: .debugNewTabPageSectionsBingSubKey, defaultValue: "")
    var subscriptionID: String
}
