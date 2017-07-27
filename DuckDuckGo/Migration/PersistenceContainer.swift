//
//  PersistenceContainer.swift
//  DuckDuckGo
//
//  Created by Christopher Brind on 27/07/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

class PersistenceContainer {
    
    init(name: String) {
        
    }
    
    func createStory() -> DDGStory {
        
        return DDGStory()
    }
    
    func save() -> Bool {
        
        return true
    }
    
}
