//
//  BlockerListsLoader.swift
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

public typealias BlockerListsLoaderCompletion = () -> Swift.Void

public class BlockerListsLoader {

    private var easylistStore = EasylistStore()

    public var hasData: Bool {
        get {
            return DisconnectMeStore.shared.hasData && easylistStore.hasData
        }
    }

    public init() { }

    public func start(completion: BlockerListsLoaderCompletion?) {

        DispatchQueue.global(qos: .background).async {
            let semaphore = DispatchSemaphore(value: 0)
            let numberOfRequests = self.startRequests(with: semaphore)

            for _ in 0 ..< numberOfRequests {
                semaphore.wait()
            }

            Logger.log(items: "BlockerListsLoader", "completed")
            completion?()
        }

    }

    private func startRequests(with semaphore: DispatchSemaphore) -> Int {

        let urls = AppUrls()

        APIRequest(url: urls.disconnectMeBlockList).execute { (data, error) in
            Logger.log(items: "DisconnectMe request completion", "\(String(describing: error))")
           return BlockerListsLoader.handleResponseAndSignalCompletion(data: data, error: error, semaphore: semaphore, dataHandler: { (data) in
                try? DisconnectMeStore.shared.persist(data: data)
            })
        }

        APIRequest(url: urls.easylistBlockList).execute { (data, error) in
            Logger.log(items: "Easylist request completion", "\(String(describing: error))")
            return BlockerListsLoader.handleResponseAndSignalCompletion(data: data, error: error, semaphore: semaphore, dataHandler: { (data) in
                self.easylistStore.persistEasylist(data: data)
            })
        }

        APIRequest(url: urls.easylistPrivacyBlockList).execute { (data, error) in
            Logger.log(items: "EasylistPrivate request completion", "\(String(describing: error))")
            return BlockerListsLoader.handleResponseAndSignalCompletion(data: data, error: error, semaphore: semaphore, dataHandler: { (data) in
                self.easylistStore.persistEasylistPrivacy(data: data)
            })

        }

        return 1
    }

    private class func handleResponseAndSignalCompletion(data: Data?, error: Error?, semaphore: DispatchSemaphore, dataHandler: (Data) -> Void) -> APIRequestCompleteionResult {
        var result: APIRequestCompleteionResult = .errorHandled
        if data != nil && error == nil {
            dataHandler(data!)
            result = .dataPersisted
        }
        semaphore.signal()
        return result
    }

}
