//
//  ArrayExtension.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 20/05/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

public extension Array {
    public func isLast(index: Int) -> Bool {
        return (index >= 0) && (index == count-1)
    }
}
