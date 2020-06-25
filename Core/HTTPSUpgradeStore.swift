//
//  HTTPSUpgradeStore.swift
//  DuckDuckGo
//
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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
import os.log

public protocol HTTPSUpgradeStore {
    
    func bloomFilter() -> BloomFilterWrapper?
    
    func bloomFilterSpecification() -> HTTPSBloomFilterSpecification?
    
    func persistBloomFilter(specification: HTTPSBloomFilterSpecification, data: Data) -> Bool
    
    func shouldUpgradeDomain(_ domain: String) -> Bool
    
    func persistExcludedDomains(_ domains: [String]) -> Bool
}

public class HTTPSUpgradePersistence: HTTPSUpgradeStore {
    
    private let context = Database.shared.makeContext(concurrencyType: .privateQueueConcurrencyType, name: "HTTPSUpgrade")
    
    public init() {
    }
    
    private var hasBloomFilterData: Bool {
        return (try? bloomFilterPath.checkResourceIsReachable()) ?? false
    }
    
    private var bloomFilterPath: URL {
        let path = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: ContentBlockerStoreConstants.groupName)
        return path!.appendingPathComponent("HttpsBloomFilter.bin")
    }
    
    public func bloomFilter() -> BloomFilterWrapper? {
        guard hasBloomFilterData else { return nil }
        var bloomFilter: BloomFilterWrapper?
        context.performAndWait {
            if let specification = bloomFilterSpecification() {
                let entries = specification.totalEntries
                bloomFilter = BloomFilterWrapper(fromPath: bloomFilterPath.path, withTotalItems: Int32(entries))
            }
        }
        return bloomFilter
    }

    public func bloomFilterSpecification() -> HTTPSBloomFilterSpecification? {
        var specification: HTTPSBloomFilterSpecification?
        context.performAndWait {
            let request: NSFetchRequest<HTTPSStoredBloomFilterSpecification> = HTTPSStoredBloomFilterSpecification.fetchRequest()
            guard let result = try? request.execute() else { return }
            specification = HTTPSBloomFilterSpecification.copy(storedSpecification: result.first)
        }
        return specification
    }
    
    public func persistBloomFilter(specification: HTTPSBloomFilterSpecification, data: Data) -> Bool {
        os_log("HTTPS Bloom Filter %s", log: generalLog, type: .debug, bloomFilterPath.absoluteString)
        guard data.sha256 == specification.sha256 else { return false }
        guard persistBloomFilter(data: data) else { return false }
        persistBloomFilterSpecification(specification)
        return true
    }
    
    func persistBloomFilter(data: Data) -> Bool {
        do {
            try data.write(to: bloomFilterPath, options: .atomic)
            return true
        } catch _ {
            return false
        }
    }
    
    private func deleteBloomFilter() {
        try? FileManager.default.removeItem(at: bloomFilterPath)
    }
    
    func persistBloomFilterSpecification(_ specification: HTTPSBloomFilterSpecification) {
        
        context.performAndWait {
            deleteBloomFilterSpecification()

            let entityName = String(describing: HTTPSStoredBloomFilterSpecification.self)
            
            if let storedEntity = NSEntityDescription.insertNewObject(
                forEntityName: entityName,
                into: context) as? HTTPSStoredBloomFilterSpecification {
                
                storedEntity.totalEntries = Int64(specification.totalEntries)
                storedEntity.errorRate = specification.errorRate
                storedEntity.sha256 = specification.sha256
                
            }
            
            do {
                try context.save()
            } catch {
                Pixel.fire(pixel: .dbSaveBloomFilterError, error: error, isCounted: true)
            }
        }
    }
    
    private func deleteBloomFilterSpecification() {
        context.performAndWait {
            context.deleteAll(matching: HTTPSStoredBloomFilterSpecification.fetchRequest())
        }
    }
    
    public func shouldUpgradeDomain(_ domain: String) -> Bool {
        var result = true
        context.performAndWait {
            let request: NSFetchRequest<HTTPSExcludedDomain> = HTTPSExcludedDomain.fetchRequest()
            request.predicate = NSPredicate(format: "domain = %@", domain.lowercased())
            guard let count = try? context.count(for: request) else { return }
            result = count == 0
        }
        return result
    }
    
    @discardableResult
    public func persistExcludedDomains(_ domains: [String]) -> Bool {
        var result = true
        context.performAndWait {
            deleteExcludedDomains()

            for domain in domains {
                let entityName = String(describing: HTTPSExcludedDomain.self)
                if let storedDomain = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as? HTTPSExcludedDomain {
                    storedDomain.domain = domain.lowercased()
                }
            }
            do {
                try context.save()
            } catch {
                Pixel.fire(pixel: .dbSaveWhitelistError, error: error, isCounted: true)
                result = false
            }
        }
        return result
    }
    
    private func deleteExcludedDomains() {
        context.performAndWait {
            context.deleteAll(matching: HTTPSExcludedDomain.fetchRequest())
        }
    }
    
    func reset() {
        deleteBloomFilterSpecification()
        deleteBloomFilter()
        deleteExcludedDomains()
    }
}
