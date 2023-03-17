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
/// The 'fire' method first checks if the pixel was already fired on a given day:
/// - if not - a request is made as with standard Pixel
/// - if it was - nothing happens
public class DailyPixel {
    
    struct Constants {
        static let dailyPixelStorageIdentifier = "com.duckduckgo.daily.pixel.storage"
    }
    
    private static var storage: UserDefaults? = UserDefaults(suiteName: Constants.dailyPixelStorageIdentifier)
    
    public static func fire(pixel: Pixel.Event,
                            withAdditionalParameters params: [String: String] = [:]) {
        
        guard let storage = storage else {
            Pixel.fire(pixel: .debugDailyPixelStorageError)
            return
        }
        
        if !hasPixelBeenFiredToday(pixel: pixel, dailyPixelStorage: storage) {
            Pixel.fire(pixel: pixel, withAdditionalParameters: params)
            updatePixelLastFireDate(pixel: pixel, dailyPixelStorage: storage)
        }
    }
    
    private static func hasPixelBeenFiredToday(pixel: Pixel.Event, dailyPixelStorage: UserDefaults) -> Bool {
        if let lastFireDate = dailyPixelStorage.object(forKey: pixel.name) as? Date {
            return Date().isSameDay(lastFireDate)
        }
        
        return false
    }
    
    private static func updatePixelLastFireDate(pixel: Pixel.Event, dailyPixelStorage: UserDefaults) {
        dailyPixelStorage.set(Date(), forKey: pixel.name)
    }
    
}
