//
//  File.swift
//  
//
//  Created by Dominik Kapusta on 08/02/2023.
//

import Foundation

public typealias ProductWaitlistMakeHTTPRequest = (URL, _ method: String, _ body: Data?, @escaping ProductWaitlistHTTPRequestCompletion) -> Void
public typealias ProductWaitlistHTTPRequestCompletion = (Data?, Error?) -> Void

public class ProductWaitlistRequest: WaitlistRequest {

    public init(feature: WaitlistFeature, makeHTTPRequest: @escaping ProductWaitlistMakeHTTPRequest) {
        self.productName = feature.apiProductName
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
        return URL(string: "https://quackdev.duckduckgo.com/api/auth/waitlist/")!
#else
        return URL(string: "https://quack.duckduckgo.com/api/auth/waitlist/")!
#endif
    }

}
