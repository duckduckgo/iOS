//
//  DataHashExtension.swift
//  Core
//
//  Created by duckduckgo on 20/08/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import Foundation
import CommonCrypto

extension Data {
    
    var sha256: String {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        let dataBytes = [UInt8](self)
        CC_SHA256(dataBytes, CC_LONG(self.count), &hash)
        let output = NSMutableString(capacity: Int(CC_SHA1_DIGEST_LENGTH))
        for byte in hash {
            output.appendFormat("%02x", byte)
        }
        return output as String
    }
}
