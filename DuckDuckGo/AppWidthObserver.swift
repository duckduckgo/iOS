//
//  AppWidthObserver.swift
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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
import Core

public class AppWidthObserver {
    
    struct Constants {
        
        static let minPadWidth: CGFloat = 678
        
    }
    
    public static let shared = AppWidthObserver()

    // mutable for testing
    var isPad = UIDevice.current.userInterfaceIdiom == .pad
    var currentWidth: CGFloat = 0
    
    public var isLargeWidth: Bool {
        return isPad && currentWidth >= Constants.minPadWidth
    }

    private init() {}

    func willResize(toWidth width: CGFloat) -> Bool {
        guard isPad else { return false }
        
        if width != currentWidth {
            currentWidth = width
            return true
        }
        
        return false
    }

}
