//
//  DailyPixel.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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

/// A variant of pixel that is fired at most once per day.
///
/// When fired it checks if the pixel was already fired on a given day:
/// - if not - a request is made as with standard Pixel
/// - if it was - nothing happens
///
/// The 'fire' method mimics standard Pixel API.
/// The 'onComplete' closure is always called - even when no pixel is fired.
/// In those scenarios a 'DailyPixelError' is returned denoting the reason.
/// 
public final class DailyPixel {

    public enum Error: Swift.Error {

        case alreadyFired

    }

    private enum Constant {

        static let dailyPixelStorageIdentifier = "com.duckduckgo.daily.pixel.storage"

    }

    private static let storage: UserDefaults = UserDefaults(suiteName: Constant.dailyPixelStorageIdentifier)!

    /// Sends a given Pixel once per day.
    /// This is useful in situations where pixels receive spikes in volume, as the daily pixel can be used to determine how many users are actually affected.
    /// Does not append any suffix unlike the alternative function below
    public static func fire(pixel: Pixel.Event,
                            error: Swift.Error? = nil,
                            withAdditionalParameters params: [String: String] = [:],
                            includedParameters: [Pixel.QueryParameters] = [.atb, .appVersion],
                            onComplete: @escaping (Swift.Error?) -> Void = { _ in }) {
        var key: String = pixel.name

        if let error = error {
            var errorParams: [String: String] = [:]
            errorParams.appendErrorPixelParams(error: error)
            key.append(":\(createSortedStringOfValues(from: errorParams))")
        }

        if !hasBeenFiredToday(forKey: key, dailyPixelStorage: storage) {
            Pixel.fire(pixel: pixel,
                       error: error,
                       includedParameters: includedParameters,
                       withAdditionalParameters: params,
                       onComplete: onComplete)
            updatePixelLastFireDate(forKey: key)
        } else {
            onComplete(Error.alreadyFired)
        }
    }

    /// Sends a given Pixel once per day with a `_d` suffix, in addition to every time it is called with a `_c` suffix.
    /// This means a pixel will get sent twice the first time it is called per-day, and subsequent calls that day will only send the `_c` variant.
    /// This is useful in situations where pixels receive spikes in volume, as the daily pixel can be used to determine how many users are actually affected.
    public static func fireDailyAndCount(pixel: Pixel.Event,
                                         error: Swift.Error? = nil,
                                         withAdditionalParameters params: [String: String] = [:],
                                         includedParameters: [Pixel.QueryParameters] = [.atb, .appVersion],
                                         onDailyComplete: @escaping (Swift.Error?) -> Void = { _ in },
                                         onCountComplete: @escaping (Swift.Error?) -> Void = { _ in }) {
        let key: String = pixel.name

        if !hasBeenFiredToday(forKey: key, dailyPixelStorage: storage) {
            Pixel.fire(
                pixelNamed: pixel.name + "_d",
                withAdditionalParameters: params,
                includedParameters: includedParameters,
                onComplete: onDailyComplete
            )
        } else {
            onDailyComplete(Error.alreadyFired)
        }
        updatePixelLastFireDate(forKey: key)
        var newParams = params
        if let error {
            newParams.appendErrorPixelParams(error: error)
        }
        Pixel.fire(
            pixelNamed: pixel.name + "_c",
            withAdditionalParameters: newParams,
            includedParameters: includedParameters,
            onComplete: onCountComplete
        )
    }

    private static func updatePixelLastFireDate(forKey key: String) {
        storage.set(Date(), forKey: key)
    }

    private static func hasBeenFiredToday(forKey key: String, dailyPixelStorage: UserDefaults) -> Bool {
        if let lastFireDate = dailyPixelStorage.object(forKey: key) as? Date {
            return Date().isSameDay(lastFireDate)
        }
        return false
    }

    private static func createSortedStringOfValues(from dict: [String: String], maxLength: Int = 50) -> String {
        let sortedKeys = dict.keys.sorted()

        let uniqueString = sortedKeys.map { "\(dict[$0]!)" }.joined(separator: ";")

        if uniqueString.count > maxLength {
            return String(uniqueString.prefix(maxLength))
        }

        return uniqueString
    }

}
