//
//  DisconnectMeRequest.swift
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

public typealias DisconnectMeRequestCompletion = (Int, Error?) -> Swift.Void

public class DisconnectMeRequest: BaseAPIRequest {

    private var completion: DisconnectMeRequestCompletion?

    init() {
        super.init(url: AppUrls().disconnectMeBlockList)
    }

    public func execute(completion: @escaping DisconnectMeRequestCompletion) {
        self.completion = completion
        super.execute()
    }

    override func completed(with data: Data) {
        do {
            let count = try DisconnectMeStore.shared.persist(data: data)
            completion?(count, nil)
        } catch {
            completion?(0, error)
        }
    }

    override func completed(with error: Error) {
        completion?(0, error)
    }

}
