//
//  AppHTTPSUpgradeStore.swift
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
import BrowserServicesKit

extension HTTPSStoredBloomFilterSpecification: Managed {}
extension HTTPSExcludedDomain: Managed {}

public final class AppHTTPSUpgradeStore: HTTPSUpgradeStore {
    
    public enum Error: Swift.Error {
        
        case specMismatch
        case saveError(Swift.Error)
        
        public var errorDescription: String? {
            switch self {
            case .specMismatch:
                return "The spec and the data do not match."
            case .saveError(let error):
                return "Error occurred while saving data: \(error.localizedDescription)"
            }
        }
        
    }
    
    private struct Resource {
        static var bloomFilter: URL {
            let path = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: ContentBlockerStoreConstants.groupName)
            return path!.appendingPathComponent("HttpsBloomFilter.bin")
        }
    }
    
    private struct EmbeddedResource {
        static let bloomSpecification = Bundle.core.url(forResource: "httpsMobileV2BloomSpec", withExtension: "json")!
        static let bloomFilter = Bundle.core.url(forResource: "httpsMobileV2Bloom", withExtension: "bin")!
        static let excludedDomains = Bundle.core.url(forResource: "httpsMobileV2FalsePositives", withExtension: "json")!
    }
    
    private struct EmbeddedBloomData {
        let specification: HTTPSBloomFilterSpecification
        let bloomFilter: Data
        let excludedDomains: [String]
    }
    
    private let context = Database.shared.makeContext(concurrencyType: .privateQueueConcurrencyType, name: "HTTPSUpgrade")
    
    private var hasBloomFilterData: Bool {
        return (try? Resource.bloomFilter.checkResourceIsReachable()) ?? false
    }
    
    public var bloomFilter: BloomFilterWrapper? {
        let storedSpecification = hasBloomFilterData ? bloomFilterSpecification : loadEmbeddedData()?.specification
        guard let specification = storedSpecification else { return nil }
        return BloomFilterWrapper(fromPath: Resource.bloomFilter.path,
                                  withBitCount: Int32(specification.bitCount),
                                  andTotalItems: Int32(specification.totalEntries))
    }
    
    public var bloomFilterSpecification: HTTPSBloomFilterSpecification? {
        var specification: HTTPSBloomFilterSpecification?
        context.performAndWait {
            let request: NSFetchRequest<HTTPSStoredBloomFilterSpecification> = HTTPSStoredBloomFilterSpecification.fetchRequest()
            guard let result = try? request.execute() else { return }
            guard let storedSpecification = HTTPSBloomFilterSpecification.copy(storedSpecification: result.first) else { return }
            guard storedSpecification.bitCount > 0, storedSpecification.totalEntries > 0 else { return }
            specification = storedSpecification
        }
        return specification ?? loadEmbeddedData()?.specification
    }
    
    private func loadEmbeddedData() -> EmbeddedBloomData? {
        os_log("Loading embedded https data")
        guard let specificationData = try? Data(contentsOf: EmbeddedResource.bloomSpecification),
              let specification = try? JSONDecoder().decode(HTTPSBloomFilterSpecification.self, from: specificationData),
              let bloomData = try? Data(contentsOf: EmbeddedResource.bloomFilter),
              let excludedDomainsData = try? Data(contentsOf: EmbeddedResource.excludedDomains),
              let excludedDomains = try? JSONDecoder().decode(HTTPSExcludedDomains.self, from: excludedDomainsData)
        else {
            return nil
        }
        try? persistBloomFilter(specification: specification, data: bloomData)
        try? persistExcludedDomains(excludedDomains.data)
        return EmbeddedBloomData(specification: specification, bloomFilter: bloomData, excludedDomains: excludedDomains.data)
    }
    
    public func persistBloomFilter(specification: HTTPSBloomFilterSpecification, data: Data) throws {
        os_log("HTTPS Bloom Filter %s", log: .generalLog, type: .debug, Resource.bloomFilter.absoluteString)
        guard data.sha256 == specification.sha256 else { throw Error.specMismatch }
        try persistBloomFilter(data: data)
        try persistBloomFilterSpecification(specification)
    }
    
    private func persistBloomFilter(data: Data) throws {
        try data.write(to: Resource.bloomFilter, options: .atomic)
    }
    
    private func deleteBloomFilter() {
        try? FileManager.default.removeItem(at: Resource.bloomFilter)
    }
    
    func persistBloomFilterSpecification(_ specification: HTTPSBloomFilterSpecification) throws {
        var saveError: Swift.Error?
        context.performAndWait {
            deleteBloomFilterSpecification()
            
            let storedEntity: HTTPSStoredBloomFilterSpecification = context.insertObject()
            storedEntity.bitCount = Int64(specification.bitCount)
            storedEntity.totalEntries = Int64(specification.totalEntries)
            storedEntity.errorRate = specification.errorRate
            storedEntity.sha256 = specification.sha256
            
            do {
                try context.save()
            } catch {
                Pixel.fire(pixel: .dbSaveBloomFilterError, error: error)
                saveError = error
            }
        }
        if let saveError = saveError {
            throw Error.saveError(saveError)
        }
    }
    
    private func deleteBloomFilterSpecification() {
        context.performAndWait {
            context.deleteAll(matching: HTTPSStoredBloomFilterSpecification.fetchRequest())
        }
    }
    
    public func hasExcludedDomain(_ domain: String) -> Bool {
        var result = false
        context.performAndWait {
            let request: NSFetchRequest<HTTPSExcludedDomain> = HTTPSExcludedDomain.fetchRequest()
            request.predicate = NSPredicate(format: "domain = %@", domain.lowercased())
            guard let count = try? context.count(for: request) else { return }
            result = count != 0
        }
        return result
    }
    
    public func persistExcludedDomains(_ domains: [String]) throws {
        var saveError: Swift.Error?
        context.performAndWait {
            deleteExcludedDomains()
            
            for domain in domains {
                let storedDomain: HTTPSExcludedDomain = context.insertObject()
                storedDomain.domain = domain.lowercased()
            }
            do {
                try context.save()
            } catch {
                Pixel.fire(pixel: .dbSaveExcludedHTTPSDomainsError, error: error)
                saveError = error
            }
        }
        if let saveError = saveError {
            throw Error.saveError(saveError)
        }
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
