//
//  InfoBundle.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 31/01/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

protocol InfoBundle {
    func object(forInfoDictionaryKey key: String) -> Any?
}

extension Bundle: InfoBundle {
}
