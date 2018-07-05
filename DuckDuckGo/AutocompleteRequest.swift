//
//  AutocompleteRequester.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

class AutocompleteRequest {

    typealias Completion = ([Suggestion]?, Error?) -> Void

    private let url: URL
    private let autocompleteParser: AutocompleteParser
    private var task: URLSessionDataTask?

    init(query: String, parser: AutocompleteParser) {
        self.url = AppUrls().autocompleteUrl(forText: query)
        self.autocompleteParser = parser
    }

    func execute(completion: @escaping Completion) {
        let parser = autocompleteParser
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = APIHeaders().defaultHeaders

        task = URLSession.shared.dataTask(with: request) { [weak self] (data, _, error) -> Void in
            guard let weakSelf = self else { return }
            do {
                let suggestions = try weakSelf.processResult(parser: parser, data: data, error: error)
                weakSelf.complete(completion, withSuccess: suggestions)
            } catch {
                weakSelf.complete(completion, withError: error)
            }
        }
        task?.resume()
    }

    private func processResult(parser: AutocompleteParser, data: Data?, error: Error?) throws -> [Suggestion] {
        if let error = error { throw error }
        guard let data = data else { throw ApiRequestError.noData }
        let suggestions = try parser.convert(fromJsonData: data)
        return suggestions
    }

    private func complete(_ completion: @escaping Completion, withSuccess suggestions: [Suggestion]) {
        DispatchQueue.main.async {
            completion(suggestions, nil)
        }
    }

    private func complete(_ completion: @escaping Completion, withError error: Error) {
        DispatchQueue.main.async {
            completion(nil, error)
        }
    }

    func cancel() {
        task?.cancel()
    }
}
