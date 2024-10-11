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

public protocol PersistentPixelFiring {
    func fire(pixel: Pixel.Event,
              error: Swift.Error?,
              includedParameters: [Pixel.QueryParameters],
              withAdditionalParameters params: [String: String],
              onComplete: @escaping (Error?) -> Void)

    func fireDailyAndCount(pixel: Pixel.Event,
                           error: Swift.Error?,
                           withAdditionalParameters params: [String: String],
                           includedParameters: [Pixel.QueryParameters],
                           completion: @escaping ([Error]) -> Void)

    func sendQueuedPixels(completion: @escaping (PersistentPixelStorageError?) -> Void)
}

public final class PersistentPixel: PersistentPixelFiring {

    enum Constants {
        static let lastProcessingDateKey = "com.duckduckgo.ios.persistent-pixel.last-processing-timestamp"

#if DEBUG
        static let minimumProcessingInterval: TimeInterval = .minutes(1)
#else
        static let minimumProcessingInterval: TimeInterval = .hours(1)
#endif
    }

    private let pixelFiring: PixelFiring.Type
    private let dailyPixelFiring: DailyPixelFiring.Type
    private let persistentPixelStorage: PersistentPixelStoring
    private let lastProcessingDateStorage: KeyValueStoring
    private let calendar: Calendar
    private let dateGenerator: () -> Date

    private let pixelProcessingLock = NSLock()
    private var isSendingQueuedPixels: Bool = false

    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    public convenience init() {
        self.init(pixelFiring: Pixel.self,
                  dailyPixelFiring: DailyPixel.self,
                  persistentPixelStorage: DefaultPersistentPixelStorage(),
                  lastProcessingDateStorage: UserDefaults.standard)
    }

    init(pixelFiring: PixelFiring.Type,
         dailyPixelFiring: DailyPixelFiring.Type,
         persistentPixelStorage: PersistentPixelStoring,
         lastProcessingDateStorage: KeyValueStoring,
         calendar: Calendar = .current,
         dateGenerator: @escaping () -> Date = { Date() }) {
        self.pixelFiring = pixelFiring
        self.dailyPixelFiring = dailyPixelFiring
        self.persistentPixelStorage = persistentPixelStorage
        self.lastProcessingDateStorage = lastProcessingDateStorage
        self.calendar = calendar
        self.dateGenerator = dateGenerator
    }

    // MARK: - Pixel Firing

    public func fire(pixel: Pixel.Event,
                     error: Swift.Error? = nil,
                     includedParameters: [Pixel.QueryParameters] = [.appVersion],
                     withAdditionalParameters additionalParameters: [String: String] = [:],
                     onComplete: @escaping (Error?) -> Void = { _ in }) {
        let fireDate = dateGenerator()
        let dateString = dateFormatter.string(from: fireDate)
        var additionalParameters = additionalParameters
        additionalParameters[PixelParameters.originalPixelTimestamp] = dateString

        Logger.general.debug("Firing persistent pixel named \(pixel.name)")

        pixelFiring.fire(pixel: pixel,
                         error: error,
                         includedParameters: includedParameters,
                         withAdditionalParameters: additionalParameters) { pixelFireError in
            if pixelFireError != nil {
                do {
                    if let error { additionalParameters.appendErrorPixelParams(error: error) }
                    try self.save(PersistentPixelMetadata(
                        eventName: pixel.name,
                        pixelType: .regular,
                        additionalParameters: additionalParameters,
                        includedParameters: includedParameters
                    ))
                } catch {
                    onComplete(error)
                }
            }
        }

        onComplete(nil)
    }

    public func fireDailyAndCount(pixel: Pixel.Event,
                                  error: Swift.Error? = nil,
                                  withAdditionalParameters additionalParameters: [String: String],
                                  includedParameters: [Pixel.QueryParameters] = [.appVersion],
                                  completion: @escaping ([Error]) -> Void = { _ in }) {
        let dispatchGroup = DispatchGroup()

        dispatchGroup.enter() // onDailyComplete
        dispatchGroup.enter() // onCountComplete

        var dailyPixelStorageError: Error?
        var countPixelStorageError: Error?

        let fireDate = dateGenerator()
        let dateString = dateFormatter.string(from: fireDate)
        var additionalParameters = additionalParameters
        additionalParameters[PixelParameters.originalPixelTimestamp] = dateString

        Logger.general.debug("Firing persistent daily/count pixel named \(pixel.name)")

        dailyPixelFiring.fireDailyAndCount(
            pixel: pixel,
            error: error,
            withAdditionalParameters: additionalParameters,
            includedParameters: includedParameters,
            onDailyComplete: { dailyError in
                if dailyError != nil {
                    do {
                        if let error { additionalParameters.appendErrorPixelParams(error: error) }
                        Logger.general.debug("Saving persistent daily pixel named \(pixel.name)")
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
                        if let error { additionalParameters.appendErrorPixelParams(error: error) }
                        Logger.general.debug("Saving persistent count pixel named \(pixel.name)")
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
            let errors = [dailyPixelStorageError, countPixelStorageError].compactMap { $0 }
            completion(errors)
        }
    }

    // MARK: - Queue Processing

    public func sendQueuedPixels(completion: @escaping (PersistentPixelStorageError?) -> Void) {
        pixelProcessingLock.lock()
        guard !self.isSendingQueuedPixels else {
            pixelProcessingLock.unlock()
            completion(nil)
            return
        }

        if let lastProcessingDate = lastProcessingDateStorage.object(forKey: Constants.lastProcessingDateKey) as? Date {
            let threshold = dateGenerator().addingTimeInterval(-Constants.minimumProcessingInterval)
            if threshold <= lastProcessingDate {
                pixelProcessingLock.unlock()
                completion(nil)
                return
            }
        }

        self.isSendingQueuedPixels = true
        pixelProcessingLock.unlock()

        do {
            let queuedPixels = try persistentPixelStorage.storedPixels()

            if queuedPixels.isEmpty {
                self.stopProcessingQueue()
                completion(nil)
                return
            }

            Logger.general.debug("Persistent pixel retrying \(queuedPixels.count, privacy: .public) pixels")

            fire(queuedPixels: queuedPixels) { pixelIDsToRemove in
                Logger.general.debug("Persistent pixel retrying done, \(queuedPixels.count, privacy: .public) pixels failed and will retry later")

                do {
                    try self.persistentPixelStorage.remove(pixelsWithIDs: pixelIDsToRemove)
                    self.stopProcessingQueue()
                    completion(nil)
                } catch {
                    self.stopProcessingQueue()
                    completion(PersistentPixelStorageError.writeError(error))
                }
            }
        } catch {
            self.stopProcessingQueue()
            completion(PersistentPixelStorageError.readError(error))
        }
    }

    // MARK: - Private

    /// Sends queued pixels and calls the completion handler with those that should be removed.
    private func fire(queuedPixels: [PersistentPixelMetadata], completion: @escaping (Set<UUID>) -> Void) {
        let dispatchGroup = DispatchGroup()

        let pixelIDsAccessQueue = DispatchQueue(label: "Failed Pixel Retry Attempt Metadata Queue")
        var pixelIDsToRemove: Set<UUID> = []
        let currentDate = dateGenerator()

        for pixelMetadata in queuedPixels {
            if let originalSendDateString = pixelMetadata.timestamp,
               let originalSendDate = dateFormatter.date(from: originalSendDateString),
               let date28DaysAgo = calendar.date(byAdding: .day, value: -28, to: currentDate) {
                if originalSendDate < date28DaysAgo {
                    pixelIDsAccessQueue.sync {
                        _ = pixelIDsToRemove.insert(pixelMetadata.id)
                    }
                    continue
                }
            } else {
                // If we don't have a timestamp for some reason, ignore the retry - retries are only useful if they have a timestamp attached
                continue
            }

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
                    if error == nil {
                        pixelIDsAccessQueue.sync {
                            _ = pixelIDsToRemove.insert(pixelMetadata.id)
                        }
                    }

                    dispatchGroup.leave()
                }
            )
        }

        dispatchGroup.notify(queue: .global()) {
            completion(pixelIDsToRemove)
        }
    }

    private func save(_ pixelMetadata: PersistentPixelMetadata) throws {
        pixelProcessingLock.lock()
        defer { pixelProcessingLock.unlock() }

        Logger.general.debug("Saving persistent pixel named \(pixelMetadata.pixelName)")

        try self.persistentPixelStorage.append(pixels: [pixelMetadata])
    }

    private func stopProcessingQueue() {
        pixelProcessingLock.lock()
        defer { pixelProcessingLock.unlock() }

        self.updateLastProcessingTimestamp()
        self.isSendingQueuedPixels = false
    }

    private func updateLastProcessingTimestamp() {
        lastProcessingDateStorage.set(dateGenerator(), forKey: Constants.lastProcessingDateKey)
    }

}
