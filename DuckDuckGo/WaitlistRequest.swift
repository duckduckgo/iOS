//
//  WaitlistRequest.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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

enum WaitlistResponse {
    
    // MARK: Join
    
    struct Join: Decodable {
        let token: String
        let timestamp: Int
    }
    
    enum JoinError: Error {
        case failed
        case noData
    }
    
    // MARK: Status
    
    struct Status: Decodable {
        let timestamp: Int
    }
    
    enum StatusError: Error {
        case failed
        case noData
    }
    
    // MARK: Invite Code
    
    struct InviteCode: Decodable {
        let code: String
    }
    
    enum InviteCodeError: Error {
        case failed
        case noData
    }

}

typealias WaitlistJoinResult = Result<WaitlistResponse.Join, WaitlistResponse.JoinError>
typealias WaitlistJoinCompletion = (Result<WaitlistResponse.Join, WaitlistResponse.JoinError>) -> Void

protocol WaitlistRequesting {
    
    func joinWaitlist(completionHandler: @escaping WaitlistJoinCompletion)
    func joinWaitlist() async -> WaitlistJoinResult
    
    func getWaitlistStatus(completionHandler: @escaping (Result<WaitlistResponse.Status, WaitlistResponse.StatusError>) -> Void)
    func getInviteCode(token: String, completionHandler: @escaping (Result<WaitlistResponse.InviteCode, WaitlistResponse.InviteCodeError>) -> Void)
    
}

class WaitlistRequest: WaitlistRequesting {

    static let developmentEndpoint = URL(string: "https://quackdev.duckduckgo.com/api/auth/waitlist/")!
    
    enum Product: String {
        case macBrowser = "macosbrowser"
    }
    
    private let product: Product
    
    init(product: Product) {
        self.product = product
    }
    
    // MARK: - WaitlistRequesting
    
    func joinWaitlist(completionHandler: @escaping (Result<WaitlistResponse.Join, WaitlistResponse.JoinError>) -> Void) {
        let url = Self.developmentEndpoint.appendingPathComponent(product.rawValue).appendingPathComponent("join")
        
        APIRequest.request(url: url, method: .post) { response, error in
            guard let data = response?.data, error == nil else {
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
    
    func joinWaitlist() async -> WaitlistJoinResult {
        await withCheckedContinuation { continuation in
            joinWaitlist { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    func getWaitlistStatus(completionHandler: @escaping (Result<WaitlistResponse.Status, WaitlistResponse.StatusError>) -> Void) {
        let url = Self.developmentEndpoint.appendingPathComponent(product.rawValue).appendingPathComponent("status")
        
        APIRequest.request(url: url, method: .get) { response, error in
            guard let data = response?.data, error == nil else {
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
    
    func getInviteCode(token: String, completionHandler: @escaping (Result<WaitlistResponse.InviteCode, WaitlistResponse.InviteCodeError>) -> Void) {
        let url = Self.developmentEndpoint.appendingPathComponent(product.rawValue).appendingPathComponent("code")
        
        var components = URLComponents()
        components.queryItems = [URLQueryItem(name: "token", value: token)]
        let componentData = components.query?.data(using: .utf8)

        APIRequest.request(url: url, method: .post, httpBody: componentData) { response, error in
            guard let data = response?.data, error == nil else {
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
    
}
