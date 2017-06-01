//
//  JsonError.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 22/05/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

public enum JsonError: Error {
    case invalidJson
    case typeMismatch
}

