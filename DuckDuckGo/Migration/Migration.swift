//
//  Migration.swift
//  DuckDuckGo
//
//  Created by Christopher Brind on 27/07/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation
import CoreData

class Migration {
    
    private var container: PersistenceContainer
    
    init(container: PersistenceContainer = PersistenceContainer(name: "Stories")) {
        self.container = container
    }
    
    func start(queue: DispatchQueue = DispatchQueue.global(qos: .background), completion: @escaping () -> ()) {
        queue.async {
            completion()
        }
    }
    
}
