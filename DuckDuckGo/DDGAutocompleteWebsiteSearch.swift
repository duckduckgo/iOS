//
//  DDGAutocompleteWebsiteSearch.swift
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
import Suggestions
import Networking

final class DDGAutocompleteWebsiteSearch: WebsiteSearching {

    private var loader: SuggestionLoading?
    private var task: URLSessionDataTask?
    private static let session = URLSession(configuration: .ephemeral)

    func search(term: String) async throws -> [URL] {
        loader = SuggestionLoader { phrase in
            guard let url = URL(trimmedAddressBarString: phrase),
                  let scheme = url.scheme,
                  scheme.description.hasPrefix("http"),
                  url.isValid else {
                return nil
            }

            return url
        }

        let results: [URL] = await withCheckedContinuation { continuation in
            loader?.getSuggestions(query: term, usingDataSource: self) { result, error in
                guard let result, error == nil else {
                    continuation.resume(returning: [])
                    return
                }

                let results: [URL] = result.all.compactMap({ suggestion in
                    switch suggestion {
                    case .website(url: let url):
                        return url
                    default:
                        return nil
                    }
                })

                continuation.resume(returning: results)
            }
        }

        return results
    }
}

extension DDGAutocompleteWebsiteSearch: SuggestionLoadingDataSource {
    var platform: Suggestions.Platform {
        .mobile
    }
    
    func openTabs(for suggestionLoading: any Suggestions.SuggestionLoading) -> [any Suggestions.BrowserTab] {
        []
    }
    
    func history(for suggestionLoading: Suggestions.SuggestionLoading) -> [HistorySuggestion] {
        []
    }

    func bookmarks(for suggestionLoading: Suggestions.SuggestionLoading) -> [Suggestions.Bookmark] {
        []
    }

    func internalPages(for suggestionLoading: Suggestions.SuggestionLoading) -> [Suggestions.InternalPage] {
        []
    }

    func suggestionLoading(_ suggestionLoading: Suggestions.SuggestionLoading, suggestionDataFromUrl url: URL, withParameters parameters: [String: String], completion: @escaping (Data?, Error?) -> Void) {
        var queryURL = url
        parameters.forEach {
            queryURL = queryURL.appendingParameter(name: $0.key, value: $0.value)
        }

        var request = URLRequest.developerInitiated(queryURL)
        request.allHTTPHeaderFields = APIRequest.Headers().httpHeaders
        task = Self.session.dataTask(with: request) { data, _, error in
            completion(data, error)
        }
        task?.resume()
    }
}
