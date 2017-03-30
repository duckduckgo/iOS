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
    private let parser: AutocompleteParser
    private var task: URLSessionDataTask?
    
    init(query : String, parser: AutocompleteParser) {
        self.url = AppUrls.autocompleteUrl(forText: query)!
        self.parser = parser
    }
    
    func execute(completion: @escaping Completion)  {
        task = URLSession.shared.dataTask(with: URLRequest(url: url)) { [weak self] (data, response, error) -> Void in
            if let error = error {
                self?.complete(completion, withError: error)
                return
            }
            self?.processData(data: data, completion: completion)
        }
        task?.resume()
    }
    
    private func processData(data: Data?, completion: @escaping Completion) {
        do {
            let suggestions = try parser.parse(data: data)
            complete(completion, withSuccess: suggestions)
        } catch {
            complete(completion, withError: error)
        }
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
