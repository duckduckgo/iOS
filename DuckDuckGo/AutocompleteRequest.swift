//
//  AutocompleteRequester.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 09/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation
import Core

class AutocompleteRequest {
    
    typealias Completion = ([Suggestion]?, Error?) -> Swift.Void
    
    private let url: URL
    private let autocompleteParser: AutocompleteParser
    private var task: URLSessionDataTask?
    
    init(query : String, parser: AutocompleteParser) {
        self.url = AppUrls.autocompleteUrl(forText: query)!
        self.autocompleteParser = parser
    }
    
    func execute(completion: @escaping Completion)  {
        let parser = autocompleteParser
        task = URLSession.shared.dataTask(with: URLRequest(url: url)) { [weak self] (data, response, error) -> Void in
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
