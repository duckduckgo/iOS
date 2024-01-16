//
//  ProductWaitlistRequest.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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

public typealias ProductWaitlistMakeHTTPRequest = (URL, _ method: String, _ body: Data?, @escaping ProductWaitlistHTTPRequestCompletion) -> Void
public typealias ProductWaitlistHTTPRequestCompletion = (Data?, Error?) -> Void

public class ProductWaitlistRequest: WaitlistRequest {

    public init(productName: String, makeHTTPRequest: @escaping ProductWaitlistMakeHTTPRequest) {
        self.productName = productName
        self.makeHTTPRequest = makeHTTPRequest
    }

    // MARK: - WaitlistRequesting

    public func joinWaitlist(completionHandler: @escaping (Result<WaitlistResponse.Join, WaitlistResponse.JoinError>) -> Void) {
        let url = endpoint.appendingPathComponent(productName).appendingPathComponent("join")

        makeHTTPRequest(url, "POST", nil) { data, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completionHandler(.failure(.noData))
                }

                return
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(WaitlistResponse.Join.self, from: data)

                DispatchQueue.main.async {
                    completionHandler(.success(response))
                }
            } catch {
                DispatchQueue.main.async {
                    completionHandler(.failure(.noData))
                }
            }

        }
    }

    public func joinWaitlist() async -> WaitlistJoinResult {
        await withCheckedContinuation { continuation in
            joinWaitlist { result in
                continuation.resume(returning: result)
            }
        }
    }

    public func getWaitlistStatus(completionHandler: @escaping (Result<WaitlistResponse.Status, WaitlistResponse.StatusError>) -> Void) {
        let url = endpoint.appendingPathComponent(productName).appendingPathComponent("status")

        makeHTTPRequest(url, "GET", nil) { data, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completionHandler(.failure(.noData))
                }

                return
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(WaitlistResponse.Status.self, from: data)

                DispatchQueue.main.async {
                    completionHandler(.success(response))
                }
            } catch {
                DispatchQueue.main.async {
                    completionHandler(.failure(.noData))
                }
            }
        }
    }

    public func getInviteCode(token: String, completionHandler: @escaping (Result<WaitlistResponse.InviteCode, WaitlistResponse.InviteCodeError>) -> Void) {
        let url = endpoint.appendingPathComponent(productName).appendingPathComponent("code")

        var components = URLComponents()
        components.queryItems = [URLQueryItem(name: "token", value: token)]
        let componentData = components.query?.data(using: .utf8)

        makeHTTPRequest(url, "POST", componentData) { data, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completionHandler(.failure(.noData))
                }

                return
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(WaitlistResponse.InviteCode.self, from: data)

                DispatchQueue.main.async {
                    completionHandler(.success(response))
                }
            } catch {
                DispatchQueue.main.async {
                    completionHandler(.failure(.noData))
                }
            }
        }
    }

    // MARK: -

    private let productName: String
    private let makeHTTPRequest: ProductWaitlistMakeHTTPRequest


    private var endpoint: URL {
#if DEBUG
        return URL(string: "https://quack.duckduckgo.com/api/auth/waitlist/")!
#else
        return URL(string: "https://quack.duckduckgo.com/api/auth/waitlist/")!
#endif
    }

}
