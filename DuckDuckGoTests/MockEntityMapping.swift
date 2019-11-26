//
//  MockEntityMapping.swift
//  Core
//
//  Created by Chris Brind on 26/11/2019.
//  Copyright © 2019 DuckDuckGo. All rights reserved.
//

import Foundation

class MockEntityMapping: EntityMapping {
    
    private var entity: String?
    private var prevalence: Double?
    
    init(entity: String?, prevalence: Double? = nil) {
        self.entity = entity
        self.prevalence = prevalence
    }

    override func findEntity(forHost host: String) -> Entity? {
        return Entity(displayName: entity, domains: nil, prevalence: prevalence)
    }
        
}
