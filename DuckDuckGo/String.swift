//
//  String.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 26/01/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

extension String {

    func trimWhitespace() -> String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }

}
