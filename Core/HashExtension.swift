//
//  HashExtension.swift
//  DuckDuckGo
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

import Foundation
import CommonCrypto

extension Data {
    
    private typealias Algorithm = (UnsafeRawPointer?, CC_LONG, UnsafeMutablePointer<UInt8>?) -> UnsafeMutablePointer<UInt8>?
    
    var sha1: String {
        return hash(algorithm: CC_SHA1, length: CC_SHA1_DIGEST_LENGTH)
    }
    
    var sha256: String {
        return hash(algorithm: CC_SHA256, length: CC_SHA256_DIGEST_LENGTH)
    }
    
    private func hash(algorithm: Algorithm, length: Int32) -> String {
        var hash = [UInt8](repeating: 0, count: Int(length))
        let dataBytes = [UInt8](self)
        _ = algorithm(dataBytes, CC_LONG(self.count), &hash)
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}

extension String {
    
    var sha1: String {
        let dataBytes = data(using: .utf8)!
        return dataBytes.sha1
    }
    
}
