//
//  AutocompleteRequest.swift
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
import Networking

class AutocompleteRequest {
    
    enum Error: Swift.Error {
        
        case noData
        
    }

    private static let session = URLSession(configuration: .ephemeral)
    
    typealias Completion = ([Suggestion]?, Swift.Error?) -> Void

    private let url: URL
    private var task: URLSessionDataTask?

    init(query: String) throws {
        self.url = try URL.makeAutocompleteURL(for: query)
    }

    func execute(completion: @escaping Completion) {
        var request = URLRequest.developerInitiated(url)
        request.allHTTPHeaderFields = APIRequest.Headers().httpHeaders

        task = AutocompleteRequest.session.dataTask(with: request) { [weak self] (data, _, error) -> Void in
            guard let weakSelf = self else { return }
            do {
                let suggestions = try weakSelf.processResult(data: data, error: error)
                weakSelf.complete(completion, withSuccess: suggestions)
            } catch {
                weakSelf.complete(completion, withError: error)
            }
        }
        task?.resume()
    }

    private func processResult(data: Data?, error: Swift.Error?) throws -> [Suggestion] {
        if let error = error { throw error }
        guard let data = data else { throw Error.noData }
        let entries = try JSONDecoder().decode([AutocompleteEntry].self, from: data)

        return entries.compactMap {
            guard let phrase = $0.phrase else { return nil }

            if let isNav = $0.isNav {
                // We definitely have a nav indication so use it. Phrase should be a fully qualified URL.
                //  Assume HTTP and that we'll auto-upgrade if needed.
                let url = isNav ? URL(string: "http://\(phrase)") : nil
                return Suggestion(source: .remote, suggestion: phrase, url: url)
            } else {
                // We need to infer nav based on the phrase to maintain previous behaviour (ie treat phrase that look like URLs like URLs)
                let url = URL.webUrl(from: phrase)
                return Suggestion(source: .remote, suggestion: phrase, url: url)
            }
        }
    }

    private func complete(_ completion: @escaping Completion, withSuccess suggestions: [Suggestion]) {
        DispatchQueue.main.async {
            completion(suggestions, nil)
        }
    }

    private func complete(_ completion: @escaping Completion, withError error: Swift.Error) {
        DispatchQueue.main.async {
            completion(nil, error)
        }
    }

    func cancel() {
        task?.cancel()
    }
}
