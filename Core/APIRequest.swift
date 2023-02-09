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
import os.log

public typealias APIRequestCompletion = (APIRequest.Response?, Error?) -> Void
public typealias APIRequestResult = Result<APIRequest.Response, Error>

// swiftlint:disable line_length
public class APIRequest {
    
    private static var defaultCallbackQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "APIRequest default callback queue"
        queue.qualityOfService = .utility
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    private static let defaultSession = URLSession(configuration: .ephemeral, delegate: nil, delegateQueue: defaultCallbackQueue)
    private static let mainThreadCallbackSession = URLSession(configuration: .ephemeral, delegate: nil, delegateQueue: OperationQueue.main)
    
    public struct Response {
        
        public var data: Data?
        public var etag: String?
        public var urlResponse: URLResponse?
        
    }
    
    public enum APIRequestError: Error {
        case noResponseOrError
    }
    
    public enum HTTPMethod: String {
        case get = "GET"
        case head = "HEAD"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
        case connect = "CONNECT"
        case options = "OPTIONS"
        case trace = "TRACE"
        case patch = "PATCH"
    }
    
    public static func request<C: Collection>(url: URL,
                                              method: HTTPMethod = .get,
                                              parameters: C,
                                              headers: HTTPHeaders = APIHeaders().defaultHeaders,
                                              httpBody: Data? = nil,
                                              callBackOnMainThread: Bool = false,
                                              timeoutInterval: TimeInterval = 60.0) async -> APIRequestResult
    where C.Element == (key: String, value: String) {

        await withCheckedContinuation { continuation in
            request(url: url,
                    method: method,
                    parameters: parameters,
                    headers: headers,
                    httpBody: httpBody,
                    timeoutInterval: timeoutInterval,
                    callBackOnMainThread: callBackOnMainThread) { response, error in
                if let error = error {
                    continuation.resume(returning: .failure(error))
                } else if let response = response {
                    continuation.resume(returning: .success(response))
                } else {
                    continuation.resume(returning: .failure(APIRequestError.noResponseOrError))
                }
            }
        }
    }

    public static func request(url: URL,
                               method: HTTPMethod = .get,
                               headers: HTTPHeaders = APIHeaders().defaultHeaders,
                               httpBody: Data? = nil,
                               callBackOnMainThread: Bool = false,
                               timeoutInterval: TimeInterval = 60.0) async -> APIRequestResult {
        return await request(url: url, method: method, parameters: Array(), headers: headers, httpBody: httpBody, callBackOnMainThread: callBackOnMainThread, timeoutInterval: timeoutInterval)
    }

    @discardableResult
    public static func request<C: Collection>(url: URL,
                                              method: HTTPMethod = .get,
                                              parameters: C,
                                              headers: HTTPHeaders = APIHeaders().defaultHeaders,
                                              httpBody: Data? = nil,
                                              timeoutInterval: TimeInterval = 60.0,
                                              callBackOnMainThread: Bool = false,
                                              completion: @escaping APIRequestCompletion) -> URLSessionDataTask
    where C.Element == (key: String, value: String) {

        os_log("Requesting %s", log: generalLog, type: .debug, url.absoluteString)

        let urlRequest = urlRequestFor(url: url,
                                       method: method,
                                       parameters: parameters,
                                       headers: headers,
                                       httpBody: httpBody,
                                       timeoutInterval: timeoutInterval)

        let session = callBackOnMainThread ? mainThreadCallbackSession : defaultSession

        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            
            let httpResponse = response as? HTTPURLResponse
            
            os_log("Request for %s completed with response code: %s and headers %s",
                   log: generalLog,
                   type: .debug,
                   url.absoluteString,
                   String(describing: httpResponse?.statusCode),
                   String(describing: httpResponse?.allHeaderFields))
            
            if let error = error {
                completion(nil, error)
            } else if let error = httpResponse?.validateStatusCode(statusCode: 200..<300) {
                completion(nil, error)
            } else {
                var etag = httpResponse?.headerValue(for: APIHeaders.Name.etag)
                
                // Handle weak etags
                etag = etag?.dropping(prefix: "W/")
                completion(Response(data: data, etag: etag, urlResponse: response), nil)
            }
        }

        task.resume()
        return task
    }

    @discardableResult
    public static func request(url: URL,
                               method: HTTPMethod = .get,
                               headers: HTTPHeaders = APIHeaders().defaultHeaders,
                               httpBody: Data? = nil,
                               timeoutInterval: TimeInterval = 60.0,
                               callBackOnMainThread: Bool = false,
                               completion: @escaping APIRequestCompletion) -> URLSessionDataTask? {
        return request(url: url, method: method, parameters: Array(), headers: headers, httpBody: httpBody, timeoutInterval: timeoutInterval, callBackOnMainThread: callBackOnMainThread, completion: completion)
    }

    // swiftlint:disable:next function_parameter_count
    private static func urlRequestFor<C: Collection>(url: URL,
                                                     method: HTTPMethod,
                                                     parameters: C,
                                                     headers: HTTPHeaders,
                                                     httpBody: Data?,
                                                     timeoutInterval: TimeInterval) -> URLRequest
    where C.Element == (key: String, value: String) {

        let url = url.appendingParameters(parameters)
        var urlRequest = URLRequest.developerInitiated(url)
        urlRequest.allHTTPHeaderFields = headers
        urlRequest.httpMethod = method.rawValue
        urlRequest.httpBody = httpBody
        urlRequest.timeoutInterval = timeoutInterval
        return urlRequest
    }
}

public extension HTTPURLResponse {
        
    enum HTTPURLResponseError: Error {
        case invalidStatusCode
    }
    
    func validateStatusCode<S: Sequence>(statusCode acceptedStatusCodes: S) -> Error? where S.Iterator.Element == Int {
        return acceptedStatusCodes.contains(statusCode) ? nil : HTTPURLResponseError.invalidStatusCode
    }
    
    fileprivate func headerValue(for name: String) -> String? {
        let lname = name.lowercased()
        return allHeaderFields.filter { ($0.key as? String)?.lowercased() == lname }.first?.value as? String
    }
}
