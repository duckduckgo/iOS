//
//  APIRequest.swift
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
import Alamofire

public enum APIRequestCompleteionResult {

    case dataPersisted
    case errorHandled

}

public typealias APIRequestCompletion = (Data?, Error?) -> APIRequestCompleteionResult

public class APIRequest {

    struct HeaderNames {

        static let etag = "ETag"

    }

    let url: URL
    var etagStorage: APIRequestETagStorage

    init(url: URL, etagStorage: APIRequestETagStorage = UserDefaultsETagStorage()) {
        self.url = url
        self.etagStorage = etagStorage
    }

    func execute(completion: @escaping APIRequestCompletion) {
        let etag = etagStorage.etag(for: url)

        Logger.log(text: "Requesting \(url)")

        Alamofire.request(url)
            .validate(statusCode: 200..<300)
            .responseData(queue: DispatchQueue.global(qos: .utility)) { response in

                Logger.log(text: "Request for \(self.url) completed with response code: \(String(describing: response.response?.statusCode)) and headers \(String(describing: response.response?.allHeaderFields))")

                if etag != nil && etag == response.response?.headerValue(for: HeaderNames.etag) {
                    Logger.log(text: "Using cached version of \(self.url) with etag: \(String(describing: etag))")
                    _ = completion(nil, nil)
                    return
                }

                if completion(response.data, response.error) == .dataPersisted {
                    self.etagStorage.set(etag: response.response?.headerValue(for: HeaderNames.etag), for: self.url)
                }
            }

    }

}

protocol APIRequestETagStorage {

    func set(etag: String?, for url: URL)

    func etag(for url: URL) -> String?

}

class UserDefaultsETagStorage: APIRequestETagStorage {

    lazy var defaults = UserDefaults(suiteName: "com.duckduckgo.api.etags")

    func etag(for url: URL) -> String? {
        let etag = defaults?.string(forKey: url.absoluteString)
        Logger.log(items: "stored etag for ", url, etag as Any)
        return etag
    }

    func set(etag: String?, for url: URL) {
        defaults?.set(etag, forKey: url.absoluteString)
    }

}

fileprivate extension HTTPURLResponse {

    func headerValue(for name: String) -> String? {
        let lname = name.lowercased()
        return allHeaderFields.filter { ($0.key as? String)?.lowercased() == lname }.first?.value as? String
    }

}

