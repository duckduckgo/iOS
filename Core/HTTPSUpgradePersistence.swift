//
//  HTTPSUpgradePersistence.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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
import CoreData


public protocol HTTPSUpgradePersistence {

    func persist(domains: [String], wildcardDomains: [String])

    func hasDomain(_ domain: String) -> Bool

}

public class CoreDataHTTPSUpgradePersistence: HTTPSUpgradePersistence {

    let container = DDGPersistenceContainer(name: "HTTPSUpgrade")!

    public init() {
    }

    public func persist(domains: [String], wildcardDomains: [String]) {
        deleteAll()

        for simpleDomain in domains {
            let entityName = String(describing: HTTPSUpgradeSimpleDomain.self)
            let content = container.managedObjectContext
            let storedDomain = NSEntityDescription.insertNewObject(forEntityName: entityName, into: content) as! HTTPSUpgradeSimpleDomain
            storedDomain.domain = simpleDomain
        }

        for wildcardDomain in wildcardDomains {
            let domain = String(wildcardDomain.suffix(from: String.Index.init(encodedOffset: 1)))
            let entityName = String(describing: HTTPSUpgradeWildcardDomain.self)
            let content = container.managedObjectContext
            let storedDomain = NSEntityDescription.insertNewObject(forEntityName: entityName, into: content) as! HTTPSUpgradeWildcardDomain
            storedDomain.domain = domain
        }

        _ = container.save()
    }

    public func hasDomain(_ domain: String) -> Bool {
        return false
    }

    private func loadAll(domains: [String], createEntity: (String) -> NSManagedObject) {
        for domain in domains {
            let object = createEntity(domain)
            container.managedObjectContext.insert(object)
        }
    }

    private func deleteAll() {
        container.deleteAll(entities: try? container.managedObjectContext.fetch(HTTPSUpgradeSimpleDomain.fetchRequest()))
        container.deleteAll(entities: try? container.managedObjectContext.fetch(HTTPSUpgradeWildcardDomain.fetchRequest()))
    }

}
