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
    
    public static func fire(pixel: Pixel.Event,
                            withAdditionalParameters params: [String: String] = [:],
                            onComplete: @escaping (Swift.Error?) -> Void = { _ in }) {
                
        if !pixel.hasBeenFiredToday(dailyPixelStorage: storage) {
            Pixel.fire(pixel: pixel, withAdditionalParameters: params, onComplete: onComplete)
            updatePixelLastFireDate(pixel: pixel)
        } else {
            onComplete(Error.alreadyFired)
        }
    }
    
    private static func updatePixelLastFireDate(pixel: Pixel.Event) {
        storage.set(Date(), forKey: pixel.name)
    }
    
}

private extension Pixel.Event {
    
    func hasBeenFiredToday(dailyPixelStorage: UserDefaults) -> Bool {
        if let lastFireDate = dailyPixelStorage.object(forKey: name) as? Date {
            return Date().isSameDay(lastFireDate)
        }
        return false
    }
    
}
