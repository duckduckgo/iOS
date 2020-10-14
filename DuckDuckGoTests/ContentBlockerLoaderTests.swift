//
//  ContentBlockerLoaderTests.swift
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

import XCTest
@testable import Core

class ContentBlockerLoaderTests: XCTestCase {

    let mockEtagStorage = MockEtagStorage()
    let mockStorageCache = MockStorageCache()
    let mockRequest = MockContentBlockingRequest()
    
    func testWhenThereIsNoResponseThenThereIsNothingToUpdate() {
        
        mockRequest.mockResponse = .error
        
        let loader = ContentBlockerLoader(etagStorage: mockEtagStorage)
        XCTAssertFalse(loader.checkForUpdates(dataSource: mockRequest))
    }
    
    func testWhenNoEtagIsPresentThenResponseIsStored() {
        
        mockRequest.mockResponse = .success(etag: "test", data: Data())
        
        let loader = ContentBlockerLoader(etagStorage: mockEtagStorage)
        XCTAssertTrue(loader.checkForUpdates(dataSource: mockRequest))
        
        XCTAssertEqual(mockEtagStorage.etags[.surrogates], nil)
        
        loader.applyUpdate(to: mockStorageCache)
        
        XCTAssertEqual(mockEtagStorage.etags[.surrogates], "test")
        XCTAssertNotNil(mockStorageCache.processedUpdates[.surrogates])
    }
    
    func testWhenEtagIsPresentThenResponseIsStoredOnlyWhenNeeded() {
        
        mockRequest.mockResponse = .success(etag: "test", data: Data())
        
        // Incorect etag should be updated
        mockEtagStorage.set(etag: "old", for: .surrogates)

        // Has data and the correct etag
        XCTAssertTrue(FileStore().persist("{}".data(using: .utf8), forConfiguration: .trackerDataSet))
        mockEtagStorage.set(etag: "test", for: .trackerDataSet)

        let loader = ContentBlockerLoader(etagStorage: mockEtagStorage)
        XCTAssertTrue(loader.checkForUpdates(dataSource: mockRequest))
        
        XCTAssertEqual(mockEtagStorage.etags[.trackerDataSet], "test")
        XCTAssertEqual(mockEtagStorage.etags[.surrogates], "old")
        XCTAssertEqual(mockEtagStorage.etags[.temporaryUnprotectedSites], nil)
        
        loader.applyUpdate(to: mockStorageCache)
        
        XCTAssertEqual(mockEtagStorage.etags[.trackerDataSet], "test")
        XCTAssertEqual(mockEtagStorage.etags[.surrogates], "test")
        XCTAssertEqual(mockEtagStorage.etags[.temporaryUnprotectedSites], "test")

        XCTAssertNil(mockStorageCache.processedUpdates[.trackerDataSet])
        XCTAssertNotNil(mockStorageCache.processedUpdates[.surrogates])
        XCTAssertNotNil(mockStorageCache.processedUpdates[.temporaryUnprotectedSites])
    }

    func testWhenEtagIsMissingThenResponseIsStored() {
        
        mockRequest.mockResponse = .success(etag: nil, data: Data())
        mockEtagStorage.set(etag: "test", for: .surrogates)
        
        let loader = ContentBlockerLoader(etagStorage: mockEtagStorage)
        XCTAssertTrue(loader.checkForUpdates(dataSource: mockRequest))
        
        XCTAssertEqual(mockEtagStorage.etags[.surrogates], "test")
        
        loader.applyUpdate(to: mockStorageCache)
        
        XCTAssertEqual(mockEtagStorage.etags[.surrogates], "test")
        
        XCTAssertNotNil(mockStorageCache.processedUpdates[.surrogates])
    }
    
    func testWhenStoringFailsThenEtagIsNotStored() {
        
        mockRequest.mockResponse = .success(etag: "test", data: Data())
        
        let loader = ContentBlockerLoader(etagStorage: mockEtagStorage)
        XCTAssertTrue(loader.checkForUpdates(dataSource: mockRequest))
        
        XCTAssertNil(mockEtagStorage.etags[.surrogates])
        
        mockStorageCache.shouldFail = true
        loader.applyUpdate(to: mockStorageCache)
        
        XCTAssertNil(mockEtagStorage.etags[.surrogates])
        XCTAssertNotNil(mockStorageCache.processedUpdates[.surrogates])
    }
    
    // Etag OOS tests
    
    func testWhenEtagIsPresentButStoreHasNoDataThenResponseIsStored() {
        
        mockRequest.mockResponse = .success(etag: "test", data: Data())
        mockEtagStorage.set(etag: "test", for: .surrogates)
        
        let loader = ContentBlockerLoader(etagStorage: mockEtagStorage, fileStore: MockFileStore())
        
        XCTAssertTrue(loader.checkForUpdates(dataSource: mockRequest))
        
        XCTAssertEqual(mockEtagStorage.etags[.surrogates], "test")
        
        loader.applyUpdate(to: mockStorageCache)
        
        XCTAssertEqual(mockEtagStorage.etags[.surrogates], "test")
        
        XCTAssertNotNil(mockStorageCache.processedUpdates[.surrogates])
    }
}

class MockFileStore: FileStore {
    
    override func loadAsData(forConfiguration config: ContentBlockerRequest.Configuration) -> Data? {
        return nil
    }
    
    override func hasData(forConfiguration config: ContentBlockerRequest.Configuration) -> Bool {
        return false
    }
    
}

class MockEtagStorage: BlockerListETagStorage {
    var etags = [ContentBlockerRequest.Configuration: String]()
    
    func set(etag: String?, for list: ContentBlockerRequest.Configuration) {
        etags[list] = etag
    }
    
    func etag(for list: ContentBlockerRequest.Configuration) -> String? {
        return etags[list]
    }
}

class MockContentBlockingRequest: ContentBlockerRemoteDataSource {
    var requestCount: Int = 0
    
    var mockResponse: ContentBlockerRequest.Response?
    
    func request(_ configuration: ContentBlockerRequest.Configuration, completion: @escaping (ContentBlockerRequest.Response) -> Void) {
        guard let response = mockResponse else {
            fatalError("No mock response set")
        }
        requestCount += 1
        
        completion(response)
    }
}

class MockStorageCache: StorageCacheUpdating {
    
    var processedUpdates = [ContentBlockerRequest.Configuration: Any]()
    
    var shouldFail = false
    
    func update(_ configuration: ContentBlockerRequest.Configuration, with data: Any, etag: String?) -> Bool {
        processedUpdates[configuration] = data
        return !shouldFail
    }
}
