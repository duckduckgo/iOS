//
//  BookmarksDelegate.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 17/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation
import Core

protocol BookmarksDelegate: class {
    
    func bookmarksDidSelect(link: Link)
}
