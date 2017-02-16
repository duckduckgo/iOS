//
//  Logger.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 24/01/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

public struct Logger {

    public static func log(text: String) {
        #if DEBUG
        print(text, separator: " ", terminator: "\n")
        #endif
    }

    public static func log(items: Any...) {
        #if DEBUG
            debugPrint(items, separator: " ", terminator: "\n")
        #endif
    }
}
