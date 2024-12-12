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
                           pixelNameSuffixes: (dailySuffix: String, countSuffix: String),
                           error: Swift.Error?,
                           withAdditionalParameters params: [String: String],
                           includedParameters: [Pixel.QueryParameters],
                           completion: @escaping ((dailyPixelStorageError: Error?, countPixelStorageError: Error?)) -> Void)

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
    private let workQueue = DispatchQueue(label: "Persistent Pixel Retry Queue")

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

        Logger.pixels.debug("Firing persistent pixel named \(pixel.name)")

        pixelFiring.fire(pixel: pixel,
                         error: error,
                         includedParameters: includedParameters,
                         withAdditionalParameters: additionalParameters) { pixelFireError in
            if pixelFireError != nil {
                do {
                    if let error {
                        additionalParameters.appendErrorPixelParams(error: error)
                    }

                    try self.persistentPixelStorage.append(pixels: [
                        PersistentPixelMetadata(eventName: pixel.name,
                                                additionalParameters: additionalParameters,
                                                includedParameters: includedParameters)
                    ])

                    onComplete(nil)
                } catch {
                    onComplete(error)
                }
            }
        }
    }

    public func fireDailyAndCount(pixel: Pixel.Event,
                                  pixelNameSuffixes: (dailySuffix: String, countSuffix: String) = DailyPixel.Constant.dailyPixelSuffixes,
                                  error: Swift.Error? = nil,
                                  withAdditionalParameters additionalParameters: [String: String],
                                  includedParameters: [Pixel.QueryParameters] = [.appVersion],
                                  completion: @escaping ((dailyPixelStorageError: Error?, countPixelStorageError: Error?)) -> Void = { _ in }) {
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
            pixelNameSuffixes: pixelNameSuffixes,
            error: error,
            withAdditionalParameters: additionalParameters,
            includedParameters: includedParameters,
            pixelFiring: Pixel.self,
            dailyPixelStore: DailyPixel.storage,
            onDailyComplete: { dailyError in
                if let dailyError, (dailyError as? DailyPixel.Error) != .alreadyFired {
                    do {
                        if let error { additionalParameters.appendErrorPixelParams(error: error) }
                        Logger.general.debug("Saving persistent daily pixel named \(pixel.name)")
                        try self.persistentPixelStorage.append(pixels: [
                            PersistentPixelMetadata(eventName: pixel.name + pixelNameSuffixes.dailySuffix,
                                                    additionalParameters: additionalParameters,
                                                    includedParameters: includedParameters)
                        ])
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
                        try self.persistentPixelStorage.append(pixels: [
                            PersistentPixelMetadata(eventName: pixel.name + pixelNameSuffixes.countSuffix,
                                                    additionalParameters: additionalParameters,
                                                    includedParameters: includedParameters)
                        ])
                    } catch {
                        countPixelStorageError = error
                    }
                }

                dispatchGroup.leave()
            }
        )

        dispatchGroup.notify(queue: .global()) {
            completion((dailyPixelStorageError: dailyPixelStorageError, countPixelStorageError: countPixelStorageError))
        }
    }

    // MARK: - Queue Processing

    public func sendQueuedPixels(completion: @escaping (PersistentPixelStorageError?) -> Void) {
        workQueue.async {
            if let lastProcessingDate = self.lastProcessingDateStorage.object(forKey: Constants.lastProcessingDateKey) as? Date {
                let threshold = self.dateGenerator().addingTimeInterval(-Constants.minimumProcessingInterval)
                if threshold <= lastProcessingDate {
                    completion(nil)
                    return
                }
            }

            self.lastProcessingDateStorage.set(self.dateGenerator(), forKey: Constants.lastProcessingDateKey)

            do {
                let queuedPixels = try self.persistentPixelStorage.storedPixels()

                if queuedPixels.isEmpty {
                    completion(nil)
                    return
                }

                Logger.general.debug("Persistent pixel retrying \(queuedPixels.count, privacy: .public) pixels")

                self.fire(queuedPixels: queuedPixels) { pixelIDsToRemove in
                    Logger.general.debug("Persistent pixel retrying done, \(pixelIDsToRemove.count, privacy: .public) pixels successfully sent")

                    do {
                        try self.persistentPixelStorage.remove(pixelsWithIDs: pixelIDsToRemove)
                        completion(nil)
                    } catch {
                        completion(PersistentPixelStorageError.writeError(error))
                    }
                }
            } catch {
                completion(PersistentPixelStorageError.readError(error))
            }
        }
    }

    // MARK: - Private

    /// Sends queued pixels and calls the completion handler with those that should be removed.
    private func fire(queuedPixels: [PersistentPixelMetadata], completion: @escaping (Set<UUID>) -> Void) {
        let dispatchGroup = DispatchGroup()

        let pixelIDsAccessQueue = DispatchQueue(label: "Failed Pixel Retry Attempt Metadata Queue")
        var pixelIDsToRemove: Set<UUID> = []
        let currentDate = dateGenerator()
        let date28DaysAgo = calendar.date(byAdding: .day, value: -28, to: currentDate)

        for pixelMetadata in queuedPixels {
            if let sendDateString = pixelMetadata.timestamp, let sendDate = dateFormatter.date(from: sendDateString), let date28DaysAgo {
                if sendDate < date28DaysAgo {
                    pixelIDsAccessQueue.sync {
                        _ = pixelIDsToRemove.insert(pixelMetadata.id)
                    }
                    continue
                }
            } else {
                // If we don't have a timestamp for some reason, ignore the retry - retries are only useful if they have a timestamp attached.
                // It's not expected that this will ever happen, so an assertion failure is used to report it when debugging.
                assertionFailure("Did not find a timestamp for pixel \(pixelMetadata.eventName)")
                pixelIDsAccessQueue.sync {
                    _ = pixelIDsToRemove.insert(pixelMetadata.id)
                }
                continue
            }

            var pixelParameters = pixelMetadata.additionalParameters
            pixelParameters[PixelParameters.retriedPixel] = "1"

            dispatchGroup.enter()

            pixelFiring.fire(
                pixelNamed: pixelMetadata.eventName,
                withAdditionalParameters: pixelParameters,
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

}
