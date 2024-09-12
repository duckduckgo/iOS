//
//  PersistentPixel.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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
import Persistence

protocol PersistentPixelFiring {
    func fireDailyAndCount(pixel: Pixel.Event,
                           error: Swift.Error?,
                           withAdditionalParameters params: [String: String],
                           includedParameters: [Pixel.QueryParameters],
                           completion: @escaping (Error?) -> Void)
}

public final class PersistentPixel: PersistentPixelFiring {

    private let dailyPixelFiring: DailyPixelFiring.Type
    private let persistentPixelStorage: PersistentPixelStoring
    private let lastSentTimestampStorage: KeyValueStoring

    private let isSendingQueuedPixels: Bool = false
    private let queue = DispatchQueue(label: "Persistent Pixel File Access Queue", qos: .utility)
    private var failedPixelsPendingStorage: [URL] = []

    init(dailyPixelFiring: DailyPixelFiring.Type,
         persistentPixelStorage: PersistentPixelStoring,
         lastSentTimestampStorage: KeyValueStoring) {
        self.dailyPixelFiring = dailyPixelFiring
        self.persistentPixelStorage = persistentPixelStorage
        self.lastSentTimestampStorage = lastSentTimestampStorage
    }

    func fireDailyAndCount(pixel: Pixel.Event,
                           error: Swift.Error? = nil,
                           withAdditionalParameters params: [String: String],
                           includedParameters: [Pixel.QueryParameters],
                           completion: @escaping (Error?) -> Void) {
        let dispatchGroup = DispatchGroup()

        dispatchGroup.enter() // onDailyComplete
        dispatchGroup.enter() // onCountComplete

        var dailyPixelStorageError: Error?
        var countPixelStorageError: Error?

        dailyPixelFiring.fireDailyAndCount(
            pixel: pixel,
            error: error,
            withAdditionalParameters: params,
            includedParameters: includedParameters,
            onDailyComplete: { dailyError in
                if dailyError != nil {
                    do {
                        let pixel = PersistentPixelMetadata(pixelName: pixel.name, parameters: params)
                        try self.persistentPixelStorage.append(pixel: pixel)
                    } catch {
                        dailyPixelStorageError = error
                    }
                }

                dispatchGroup.leave()
            }, onCountComplete: { countError in
                if countError != nil {
                    do {
                        let pixel = PersistentPixelMetadata(pixelName: pixel.name, parameters: params)
                        try self.persistentPixelStorage.append(pixel: pixel)
                    } catch {
                        countPixelStorageError = error
                    }
                }

                dispatchGroup.leave()
            }
        )

        dispatchGroup.notify(queue: .main) {
            if let dailyPixelStorageError {
                completion(dailyPixelStorageError)
            } else if let countPixelStorageError {
                completion(countPixelStorageError)
            } else {
                completion(nil)
            }
        }
    }

    func sendQueuedPixels(completion: @escaping (PersistentPixelStorageError?) -> Void) {

    }

}
