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
    let mockRequest = MockContenBlockingRequest()
    
    func testWhenThereIsNoResponseThenThereIsNothingToUpdate() {
        
        mockRequest.mockResponse = .error
        
        let loader = ContentBlockerLoader(etagStorage: mockEtagStorage)
        XCTAssertFalse(loader.checkForUpdates(with: mockStorageCache, dataSource: mockRequest))
    }
    
    func testWhenNoEtagIsPresentThenResponseIsStored() {
        
        mockRequest.mockResponse = .success(etag: "test", data: Data())
        
        let loader = ContentBlockerLoader(etagStorage: mockEtagStorage)
        XCTAssert(loader.checkForUpdates(with: mockStorageCache, dataSource: mockRequest))
        
        XCTAssertEqual(mockEtagStorage.etags[.disconnectMe], nil)
        
        loader.applyUpdate(to: mockStorageCache)
        
        XCTAssertEqual(mockEtagStorage.etags[.disconnectMe], "test")
        XCTAssertNotNil(mockStorageCache.processedUpdates[.disconnectMe])
    }

    func testWhenEtagIsPresentThenResponseIsStoredOnlyWhenNeeded() {
        
        mockRequest.mockResponse = .success(etag: "test", data: Data())
        mockEtagStorage.set(etag: "test", for: .disconnectMe)
        mockEtagStorage.set(etag: "old", for: .surrogates)
        
        let loader = ContentBlockerLoader(etagStorage: mockEtagStorage)
        XCTAssert(loader.checkForUpdates(with: mockStorageCache, dataSource: mockRequest))
        
        XCTAssertEqual(mockEtagStorage.etags[.disconnectMe], "test")
        XCTAssertEqual(mockEtagStorage.etags[.surrogates], "old")
        XCTAssertEqual(mockEtagStorage.etags[.trackersWhitelist], nil)
        
        loader.applyUpdate(to: mockStorageCache)
        
        XCTAssertEqual(mockEtagStorage.etags[.disconnectMe], "test")
        XCTAssertEqual(mockEtagStorage.etags[.surrogates], "test")
        XCTAssertEqual(mockEtagStorage.etags[.trackersWhitelist], "test")

        XCTAssertNil(mockStorageCache.processedUpdates[.disconnectMe])
        XCTAssertNotNil(mockStorageCache.processedUpdates[.surrogates])
        XCTAssertNotNil(mockStorageCache.processedUpdates[.trackersWhitelist])
    }
    
    func testWhenStoringFailsThenEtagIsNotStored() {
        
        mockRequest.mockResponse = .success(etag: "test", data: Data())
        
        let loader = ContentBlockerLoader(etagStorage: mockEtagStorage)
        XCTAssert(loader.checkForUpdates(with: mockStorageCache, dataSource: mockRequest))
        
        XCTAssertNil(mockEtagStorage.etags[.disconnectMe])
        
        mockStorageCache.shouldFail = true
        loader.applyUpdate(to: mockStorageCache)
        
        XCTAssertNil(mockEtagStorage.etags[.disconnectMe])
        XCTAssertNotNil(mockStorageCache.processedUpdates[.disconnectMe])
    }
    
    // Etag OOS tests
    
    func testWhenEtagIsPresentButStoreHasNoDataThenResponseIsStored() {
        
        mockRequest.mockResponse = .success(etag: "test", data: Data())
        mockEtagStorage.set(etag: "test", for: .disconnectMe)
        mockEtagStorage.set(etag: "test", for: .trackersWhitelist)
        
        let loader = ContentBlockerLoader(etagStorage: mockEtagStorage)
        
        mockStorageCache.hasDisconnectMeData = false
        mockStorageCache.hasEasylistData = false
        
        XCTAssert(loader.checkForUpdates(with: mockStorageCache, dataSource: mockRequest))
        
        XCTAssertEqual(mockEtagStorage.etags[.disconnectMe], "test")
        XCTAssertEqual(mockEtagStorage.etags[.trackersWhitelist], "test")
        
        loader.applyUpdate(to: mockStorageCache)
        
        XCTAssertEqual(mockEtagStorage.etags[.disconnectMe], "test")
        XCTAssertEqual(mockEtagStorage.etags[.trackersWhitelist], "test")
        
        XCTAssertNotNil(mockStorageCache.processedUpdates[.disconnectMe])
        XCTAssertNotNil(mockStorageCache.processedUpdates[.trackersWhitelist])
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

class MockContenBlockingRequest: ContentBlockerRemoteDataSource {
    var requestCount: Int = 0
    
    var mockResponse: ContentBlockerRequest.Response?
    
    func request(_ configuration: ContentBlockerRequest.Configuration, completion: @escaping (ContentBlockerRequest.Response) -> Void) {
        guard let response = mockResponse else {
            XCTFail("No mock response set")
            return
        }
        requestCount += 1
        
        completion(response)
    }
}

class MockStorageCache: StorageCacheUpdating, EtagOOSCheckStore {
    
    var hasDisconnectMeData: Bool = true
    var hasEasylistData: Bool = true
    
    var processedUpdates = [ContentBlockerRequest.Configuration: Any]()
    
    var shouldFail = false
    
    func update(_ configuration: ContentBlockerRequest.Configuration, with data: Any) -> Bool {
        processedUpdates[configuration] = data
        return !shouldFail
    }
}
