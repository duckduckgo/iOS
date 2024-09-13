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
import Networking
import Persistence

protocol PersistentPixelFiring {
    func fireDailyAndCount(pixel: Pixel.Event,
                           error: Swift.Error?,
                           withAdditionalParameters params: [String: String],
                           includedParameters: [Pixel.QueryParameters],
                           completion: @escaping (Error?) -> Void)
}

public final class PersistentPixel: PersistentPixelFiring {

    private let pixelFiring: PixelFiring.Type
    private let dailyPixelFiring: DailyPixelFiring.Type
    private let persistentPixelStorage: PersistentPixelStoring
    private let lastSentTimestampStorage: KeyValueStoring
    private let dateGenerator: () -> Date

    private let isSendingQueuedPixels: Bool = false
    private let queue = DispatchQueue(label: "Persistent Pixel File Access Queue", qos: .utility)
    private var failedPixelsPendingStorage: [URL] = []

    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    init(pixelFiring: PixelFiring.Type,
         dailyPixelFiring: DailyPixelFiring.Type,
         persistentPixelStorage: PersistentPixelStoring,
         lastSentTimestampStorage: KeyValueStoring,
         dateGenerator: @escaping () -> Date = { Date() }) {
        self.pixelFiring = pixelFiring
        self.dailyPixelFiring = dailyPixelFiring
        self.persistentPixelStorage = persistentPixelStorage
        self.lastSentTimestampStorage = lastSentTimestampStorage
        self.dateGenerator = dateGenerator
    }

    func fireDailyAndCount(pixel: Pixel.Event,
                           error: Swift.Error? = nil,
                           withAdditionalParameters additionalParameters: [String: String],
                           includedParameters: [Pixel.QueryParameters],
                           completion: @escaping (Error?) -> Void) {
        let dispatchGroup = DispatchGroup()

        dispatchGroup.enter() // onDailyComplete
        dispatchGroup.enter() // onCountComplete

        var dailyPixelStorageError: Error?
        var countPixelStorageError: Error?

        let fireDate = dateGenerator()
        let dateString = dateFormatter.string(from: fireDate)
        var additionalParameters = additionalParameters
        additionalParameters[PixelParameters.originalPixelTimestamp] = dateString

        dailyPixelFiring.fireDailyAndCount(
            pixel: pixel,
            error: error,
            withAdditionalParameters: additionalParameters,
            includedParameters: includedParameters,
            onDailyComplete: { dailyError in
                if dailyError != nil {
                    do {
                        let pixel = PersistentPixelMetadata(
                            eventName: pixel.name,
                            pixelType: .daily,
                            additionalParameters: additionalParameters,
                            includedParameters: includedParameters
                        )
                        try self.persistentPixelStorage.append(pixel: pixel)
                    } catch {
                        dailyPixelStorageError = error
                    }
                }

                dispatchGroup.leave()
            }, onCountComplete: { countError in
                if countError != nil {
                    do {
                        let pixel = PersistentPixelMetadata(
                            eventName: pixel.name,
                            pixelType: .count,
                            additionalParameters: additionalParameters,
                            includedParameters: includedParameters
                        )
                        try self.persistentPixelStorage.append(pixel: pixel)
                    } catch {
                        countPixelStorageError = error
                    }
                }

                dispatchGroup.leave()
            }
        )

        dispatchGroup.notify(queue: .global()) {
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
        do {
            let queuedPixels = try persistentPixelStorage.storedPixels()

            if queuedPixels.isEmpty {
                completion(nil)
                return
            }

            let dispatchGroup = DispatchGroup()

            let failedPixelsAccessQueue = DispatchQueue(label: "Failed Pixel Retry Attempt Metadata Queue")
            var failedPixels: [PersistentPixelMetadata] = []

            for pixelMetadata in queuedPixels {
                var pixelParameters = pixelMetadata.additionalParameters
                pixelParameters[PixelParameters.retriedPixel] = "1"

                dispatchGroup.enter()
                pixelFiring.fire(
                    pixelNamed: pixelMetadata.pixelName,
                    forDeviceType: UIDevice.current.userInterfaceIdiom,
                    withAdditionalParameters: pixelParameters,
                    allowedQueryReservedCharacters: nil,
                    withHeaders: APIRequest.Headers(),
                    includedParameters: pixelMetadata.includedParameters,
                    onComplete: { error in
                        if error != nil {
                            failedPixelsAccessQueue.sync {
                                failedPixels.append(pixelMetadata)
                            }
                        }

                        dispatchGroup.leave()
                    }
                )
            }

            dispatchGroup.notify(queue: .global()) {
                do {
                    try self.persistentPixelStorage.replaceStoredPixels(with: failedPixels)
                    completion(nil)
                } catch {
                    completion(nil) // TODO: Use correct error
                }
            }
        } catch {
            completion(nil) // TODO: Use correct error
        }
    }

}
