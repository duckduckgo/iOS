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

public typealias APIRequestCompletion = (APIRequest.Response?, Error?) -> Void

public class APIRequest {
    
    private static let callbackQueue = DispatchQueue(label: "APIRequest callback queue", qos: .utility)
    
    public struct Response {
        
        var data: Data?
        var etag: String?
        
    }
    
    @discardableResult
    public static func request(url: URL,
                               method: HTTPMethod = .get,
                               parameters: [String: Any]? = nil,
                               completion: @escaping APIRequestCompletion) -> Request {
        
        Logger.log(text: "Requesting \(url)")
        
        return Alamofire.request(url, method: method, parameters: parameters, headers: APIHeaders().defaultHeaders)
            .validate(statusCode: 200..<300)
            .responseData(queue: callbackQueue) { response in
                
                Logger.log(text: "Request for \(url) completed with response code: \(String(describing: response.response?.statusCode))")
                Logger.log(text: " and headers \(String(describing: response.response?.allHeaderFields))")
                
                if let error = response.error {
                    completion(nil, error)
                } else {
                    let etag = response.response?.headerValue(for: APIHeaders.Name.etag)
                    completion(Response(data: response.data, etag: etag), nil)
                }
        }
    }
    
}

fileprivate extension HTTPURLResponse {
    
    func headerValue(for name: String) -> String? {
        let lname = name.lowercased()
        return allHeaderFields.filter { ($0.key as? String)?.lowercased() == lname }.first?.value as? String
    }
    
}
