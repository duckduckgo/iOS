//
//  CohortRequest.swift
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

public typealias CohortRequestCompletion = (Cohort?, Error?) -> Swift.Void

public class CohortRequest {

    private let appUrls = AppUrls()
    private let parser = CohortParser()

    public init() {}

    public func execute(completion: @escaping CohortRequestCompletion) {
        Logger.log(text: "Requesting cohort...")
        Alamofire.request(appUrls.cohort)
            .validate(statusCode: 200..<300)
            .responseData(queue: DispatchQueue.global(qos: .utility)) { response in
                Logger.log(text: "Cohort request completed with result \(response.result)")
                self.handleResponse(response: response, completion: completion)
        }
    }

    private func handleResponse(response: Alamofire.DataResponse<Data>, completion: @escaping CohortRequestCompletion) {
        if let error = response.result.error {
            complete(completion, withCohort: nil, error: error)
            return
        }

        guard let data = response.result.value else {
            complete(completion, withCohort: nil, error: ApiRequestError.noData)
            return
        }

        do {
            let cohort  = try self.parser.convert(fromJsonData: data)
            complete(completion, withCohort: cohort, error: nil)
        } catch {
            complete(completion, withCohort: nil, error: error)
        }
    }

    private func complete(_ completion: @escaping CohortRequestCompletion, withCohort cohort: Cohort?, error: Error?) {
        DispatchQueue.main.async {
            completion(cohort, error)
        }
    }
}
