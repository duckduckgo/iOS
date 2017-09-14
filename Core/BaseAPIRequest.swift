//
//  BaseAPIRequest.swift
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

public typealias APIRequestCompletion = (Int, Error?) -> Swift.Void

public class BaseAPIRequest {

    let url: URL

    init(url: URL) {
        self.url = url
    }

    func execute() {

        Logger.log(text: "Requesting trackers...")
        Alamofire.request(url)
            .validate(statusCode: 200..<300)
            .responseData(queue: DispatchQueue.global(qos: .utility)) { response in
                Logger.log(text: "Request for \(self.url) completed with result \(response.result)")
                self.handleResponse(response: response)
        }

    }

    private func handleResponse(response: Alamofire.DataResponse<Data>) {
        if let error = response.result.error {
            completed(with: error)
            return
        }

        guard let data = response.result.value else {
            completed(with: ApiRequestError.noData)
            return
        }

        completed(with: data)
    }

    func completed(with data: Data) {
    }

    func completed(with error: Error) {
    }

}
