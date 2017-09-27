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
            if let data = data {
                try? DisconnectMeStore.shared.persist(data: data)
            }
            Logger.log(items: "DisconnectMeRequest", DisconnectMeStore.shared.allTrackers.count, "\(String(describing: error))")
            semaphore.signal()
        }

        APIRequest(url: urls.easylistBlockList).execute { (data, error) in
            if let data = data {
                self.easylistStore.persistEasylist(data: data)
            }

            Logger.log(items: "EasylistRequest", "\(String(describing: error))")
            semaphore.signal()
        }

        APIRequest(url: urls.easylistPrivacyBlockList).execute { (data, error) in
            if let data = data {
                self.easylistStore.persistEasylistPrivacy(data: data)
            }

            Logger.log(items: "EasylistPrivacyRequest", "\(String(describing: error))")
            semaphore.signal()
        }

        return 3
    }

}
