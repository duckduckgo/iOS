//
//  PrivacyConfigurationManagerTests.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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

class PrivacyConfigurationManagerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        try? FileManager.default.removeItem(at: FileStore().persistenceLocation(forConfiguration: .privacyConfiguration))
    }

    func testEmbeddedConfigurationEtagAndSHA() throws {
        let hash = calculateHash(for: PrivacyConfigurationManager.embeddedUrl)
        XCTAssertEqual(hash, PrivacyConfigurationManager.Constants.embeddedConfigurationSHA,
                       "Error: please update SHA and ETag when changing embedded TDS")
        XCTAssertEqual(PrivacyConfigurationManager.shared.embeddedConfigData.etag,
                       PrivacyConfigurationManager.Constants.embeddedConfigETag)
    }

    func testEmbeddedConfigurationFeaturesAreCorrect() throws {
        let embeddedConfig = AppPrivacyConfiguration(data: PrivacyConfigurationManager.shared.embeddedConfigData.data, identifier: "")
        XCTAssertTrue(embeddedConfig.isEnabled(featureKey: .contentBlocking))
        XCTAssertTrue(embeddedConfig.isEnabled(featureKey: .gpc))
        XCTAssertTrue(embeddedConfig.isEnabled(featureKey: .fingerprintingBattery))
        XCTAssertTrue(embeddedConfig.isEnabled(featureKey: .fingerprintingScreenSize))
        XCTAssertTrue(embeddedConfig.isEnabled(featureKey: .fingerprintingTemporaryStorage))
        XCTAssertTrue(embeddedConfig.isEnabled(featureKey: .httpsUpgrade))
        XCTAssertTrue(embeddedConfig.isEnabled(featureKey: .ampLinks))
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
