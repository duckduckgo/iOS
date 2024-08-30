//
//  AdAttributionFetcher.swift
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

import AdServices
import os.log

protocol AdAttributionFetcher {
    func fetch() async -> (String, AdServicesAttributionResponse)?
}

/// Fetches ad attribution data for from Apple.
///
/// DuckDuckGo uses the AdServices framework to fetch and monitor anonymous install attribution data from Apple. No personally identifiable data is involved.
/// DuckDuckGo does not use the App Tracking Transparency framework at any point, and only uses the “standard” attribution payload.
/// See https://developer.apple.com/documentation/adservices/aaattribution/attributiontoken()#Attribution-payload-descriptions for details.
struct DefaultAdAttributionFetcher: AdAttributionFetcher {

    typealias TokenGetter = () throws -> String

    private let tokenGetter: TokenGetter
    private let urlSession: URLSession
    private let retryInterval: TimeInterval

    init(tokenGetter: @escaping TokenGetter = Self.fetchAttributionToken,
         urlSession: URLSession = .shared,
         retryInterval: TimeInterval = .seconds(5)) {
        self.tokenGetter = tokenGetter
        self.urlSession = urlSession
        self.retryInterval = retryInterval
    }

    func fetch() async -> (String, AdServicesAttributionResponse)? {
        var lastToken: String?

        for _ in 0..<Constant.maxRetries {
            do {
                try Task.checkCancellation()

                let token = try (lastToken ?? tokenGetter())
                lastToken = token
                return try await fetchAttributionData(using: token)
            } catch let error as AdAttributionFetcherError {
                Logger.adAttribution.error("AdAttributionFetcher failed to fetch attribution data: \(error.localizedDescription, privacy: .public). Retrying.")

                if error == .invalidToken {
                    lastToken = nil
                }

                if error.allowsRetry {
                    try? await Task.sleep(interval: retryInterval)
                    continue
                } else {
                    break
                }
            } catch {
                Logger.adAttribution.error("AdAttributionFetcher failed to fetch attribution data: \(error.localizedDescription, privacy: .public)")

                // Do not retry
                break
            }
        }

        return nil
    }

    private func fetchAttributionData(using token: String) async throws -> (String, AdServicesAttributionResponse) {
        let request = createAttributionDataRequest(with: token)
        let (data, response) = try await urlSession.data(for: request)

        guard let response = response as? HTTPURLResponse else {
            throw AdAttributionFetcherError.invalidResponse
        }

        switch response.statusCode {
        case 200:
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(AdServicesAttributionResponse.self, from: data)

            return (token, decoded)
        case 400:
            throw AdAttributionFetcherError.invalidToken
        case 404:
            throw AdAttributionFetcherError.invalidResponse
        default:
            throw AdAttributionFetcherError.unknown
        }
    }

    private func createAttributionDataRequest(with token: String) -> URLRequest {
        var request = URLRequest(url: Constant.attributionServiceURL)
        request.httpMethod = "POST"
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        request.httpBody = token.data(using: .utf8)

        return request
    }

    private struct Constant {
        static let attributionServiceURL = URL(string: "https://api-adservices.apple.com/api/v1/")!
        static let maxRetries = 3
    }
}

extension AdAttributionFetcher {
    static func fetchAttributionToken() throws -> String {
        return try AAAttribution.attributionToken()
    }
}

struct AdServicesAttributionResponse: Decodable {
    let attribution: Bool
    let orgId: Int?
    let campaignId: Int?
    let conversionType: String?
    let adGroupId: Int?
    let countryOrRegion: String?
    let keywordId: Int?
    let adId: Int?
}

enum AdAttributionFetcherError: Error {
    case attributionUnsupported
    case invalidResponse
    case invalidToken
    case unknown

    var allowsRetry: Bool {
        switch self {
        case .invalidToken, .invalidResponse:
            return true
        case .unknown, .attributionUnsupported:
            return false
        }
    }
}
