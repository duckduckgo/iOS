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
import os.log
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

    private var isSendingQueuedPixels: Bool = false
    private let pixelProcessingQueue = DispatchQueue(label: "Persistent Pixel Processing Queue", qos: .utility)
    private var failedPixelsPendingStorage: [PersistentPixelMetadata] = []

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
                        try self.save(PersistentPixelMetadata(
                            eventName: pixel.name,
                            pixelType: .daily,
                            additionalParameters: additionalParameters,
                            includedParameters: includedParameters
                        ))
                    } catch {
                        dailyPixelStorageError = error
                    }
                }

                dispatchGroup.leave()
            }, onCountComplete: { countError in
                if countError != nil {
                    do {
                        try self.save(PersistentPixelMetadata(
                            eventName: pixel.name,
                            pixelType: .count,
                            additionalParameters: additionalParameters,
                            includedParameters: includedParameters
                        ))
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
        pixelProcessingQueue.sync {
            guard !self.isSendingQueuedPixels else {
                completion(nil)
                return
            }

            self.isSendingQueuedPixels = true
        }

        do {
            let queuedPixels = try persistentPixelStorage.storedPixels()

            if queuedPixels.isEmpty {
                self.stopProcessingQueueAndPersistPendingPixels()
                completion(nil)
                return
            }

            Logger.general.debug("Persistent pixel processing \(queuedPixels.count, privacy: .public) pixels")

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
                    self.stopProcessingQueueAndPersistPendingPixels()
                    completion(nil)
                } catch {
                    self.stopProcessingQueueAndPersistPendingPixels()
                    completion(PersistentPixelStorageError.writeError(error))
                }
            }
        } catch {
            self.stopProcessingQueueAndPersistPendingPixels()
            completion(PersistentPixelStorageError.readError(error))
        }
    }

    // MARK: - Private

    private func save(_ pixelMetadata: PersistentPixelMetadata) throws {
        dispatchPrecondition(condition: .notOnQueue(self.pixelProcessingQueue))

        Logger.general.debug("Saving persistent pixel named \(pixelMetadata.pixelName)")

        try self.pixelProcessingQueue.sync {
            if self.isSendingQueuedPixels {
                self.failedPixelsPendingStorage.append(pixelMetadata)
            } else {
                try self.persistentPixelStorage.append(pixel: pixelMetadata)
            }
        }
    }

    private func stopProcessingQueueAndPersistPendingPixels() {
        dispatchPrecondition(condition: .notOnQueue(self.pixelProcessingQueue))

        self.pixelProcessingQueue.sync {
            for pixel in self.failedPixelsPendingStorage {
                try? self.persistentPixelStorage.append(pixel: pixel)
            }

            self.failedPixelsPendingStorage = []
            self.isSendingQueuedPixels = false
        }
    }

}
