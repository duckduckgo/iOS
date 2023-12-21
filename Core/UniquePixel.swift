//
//  UniquePixel.swift
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

/// A variant of pixel that is fired just once. Ever.
///
/// The 'fire' method mimics standard Pixel API.
/// The 'onComplete' closure is always called - even when no pixel is fired.
/// In those scenarios a 'UniquePixelError' is returned denoting the reason.
///
public final class UniquePixel {

    public enum Error: Swift.Error {

        case alreadyFired

    }

    private enum Constant {

        static let uniquePixelStorageIdentifier = "com.duckduckgo.unique.pixel.storage"

    }

    public static let storage = UserDefaults(suiteName: Constant.uniquePixelStorageIdentifier)!

    /// Sends a unique Pixel
    /// This requires the pixel name to end with `_u`
    public static func fire(pixel: Pixel.Event,
                            withAdditionalParameters params: [String: String] = [:],
                            onComplete: @escaping (Swift.Error?) -> Void = { _ in }) {
        guard pixel.name.hasSuffix("_u") else {
            assertionFailure("Unique pixel: must end with _u")
            return
        }

        if !pixel.hasBeenFiredEver(uniquePixelStorage: storage) {
            Pixel.fire(pixel: pixel, withAdditionalParameters: params, onComplete: onComplete)
            storage.set(Date(), forKey: pixel.name)
        } else {
            onComplete(Error.alreadyFired)
        }
    }

    public static func dateString(for date: Date?) -> String {
        guard let date else { return "" }

        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar.current
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd"

        return dateFormatter.string(from: date)
    }
}

extension Pixel.Event {

    public func lastFireDate(uniquePixelStorage: UserDefaults) -> Date? {
        uniquePixelStorage.object(forKey: name) as? Date
    }

    func hasBeenFiredEver(uniquePixelStorage: UserDefaults) -> Bool {
        lastFireDate(uniquePixelStorage: uniquePixelStorage) != nil
    }

}
