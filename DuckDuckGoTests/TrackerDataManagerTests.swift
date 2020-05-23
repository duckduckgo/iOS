//
//  TrackerDataManagerTests.swift
//  Core
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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
import CommonCrypto
@testable import Core

class TrackerDataManagerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        try? FileManager.default.removeItem(at: FileStore().persistenceLocation(forConfiguration: .trackerDataSet))
    }
    
    func testWhenReloadCalledInitiallyThenDataSetIsEmbedded() {
        XCTAssertEqual(TrackerDataManager.shared.reload(etag: nil), .embedded)
    }

    func testFindTrackerByUrl() {
        let tracker = TrackerDataManager.shared.findTracker(forUrl: "http://googletagmanager.com")
        XCTAssertNotNil(tracker)
        XCTAssertEqual("Google", tracker?.owner?.displayName)
    }
    
    func testFindEntityByName() {
        let entity = TrackerDataManager.shared.findEntity(byName: "Google LLC")
        XCTAssertNotNil(entity)
        XCTAssertEqual("Google", entity?.displayName)
    }
    
    func testFindEntityForHost() {
        let entity = TrackerDataManager.shared.findEntity(forHost: "www.google.com")
        XCTAssertNotNil(entity)
        XCTAssertEqual("Google", entity?.displayName)
    }
    
    // swiftlint:disable function_body_length
    func testWhenDownloadedDataAvailableThenReloadUsesIt() {

        let update = """
        {
          "trackers": {
            "notreal.io": {
              "domain": "notreal.io",
              "default": "block",
              "owner": {
                "name": "CleverDATA LLC",
                "displayName": "CleverDATA",
                "privacyPolicy": "https://hermann.ai/privacy-en",
                "url": "http://hermann.ai"
              },
              "source": [
                "DDG"
              ],
              "prevalence": 0.002,
              "fingerprinting": 0,
              "cookies": 0.002,
              "performance": {
                "time": 1,
                "size": 1,
                "cpu": 1,
                "cache": 3
              },
              "categories": [
                "Ad Motivated Tracking",
                "Advertising",
                "Analytics",
                "Third-Party Analytics Marketing"
              ]
            }
          },
          "entities": {
            "Not Real": {
              "domains": [
                "notreal.io"
              ],
              "displayName": "Not Real",
              "prevalence": 0.666
            }
          },
          "domains": {
            "notreal.io": "Not Real"
          }
        }
        """

        XCTAssertTrue(FileStore().persist(update.data(using: .utf8), forConfiguration: .trackerDataSet))
        XCTAssertEqual(TrackerDataManager.shared.etag, TrackerDataManager.Constants.embeddedDataSetETag)
        XCTAssertEqual(TrackerDataManager.shared.reload(etag: "new etag"), .downloaded)
        XCTAssertEqual(TrackerDataManager.shared.etag, "new etag")
        XCTAssertNil(TrackerDataManager.shared.findEntity(byName: "Google LLC"))
        XCTAssertNotNil(TrackerDataManager.shared.findEntity(byName: "Not Real"))

    }
    // swiftlint:enable function_body_length
        
    func testWhenEmbeddedDataIsUpdatedThenUpdateSHAAndEtag() {
        
        let hash = calculateHash(for: TrackerDataManager.embeddedUrl)
        XCTAssertEqual(hash, TrackerDataManager.Constants.embeddedDatsSetSHA, "Error: please update SHA and ETag when changing embedded TDS")
    }
    
    private func calculateHash(for fileURL: URL) -> String {
        if let data = sha256(url: fileURL) {
            return data.base64EncodedString()
        }
        
        XCTFail("Could not calculate TDS hash")
        return ""
    }
    
    // Source:
    // https://stackoverflow.com/questions/42934154/how-can-i-hash-a-file-on-ios-using-swift-3/49878022#49878022
    func sha256(url: URL) -> Data? {
        do {
            let bufferSize = 1024 * 1024
            // Open file for reading:
            let file = try FileHandle(forReadingFrom: url)
            defer {
                file.closeFile()
            }

            // Create and initialize SHA256 context:
            var context = CC_SHA256_CTX()
            CC_SHA256_Init(&context)

            // Read up to `bufferSize` bytes, until EOF is reached, and update SHA256 context:
            while autoreleasepool(invoking: {
                // Read up to `bufferSize` bytes
                let data = file.readData(ofLength: bufferSize)
                if data.count > 0 {
                    _ = data.withUnsafeBytes { bytesFromBuffer -> Int32 in
                        guard let rawBytes = bytesFromBuffer.bindMemory(to: UInt8.self).baseAddress else {
                            return Int32(kCCMemoryFailure)
                        }
                        
                        return CC_SHA256_Update(&context, rawBytes, numericCast(data.count))
                    }
                    // Continue
                    return true
                } else {
                    // End of file
                    return false
                }
            }) { }

            // Compute the SHA256 digest:
            var digestData = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
            _ = digestData.withUnsafeMutableBytes { bytesFromDigest -> Int32 in
              guard let rawBytes = bytesFromDigest.bindMemory(to: UInt8.self).baseAddress else {
                return Int32(kCCMemoryFailure)
              }

              return CC_SHA256_Final(rawBytes, &context)
            }

            return digestData
        } catch {
            print(error)
            return nil
        }
    }
}
