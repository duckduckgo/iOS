//
//  DisplayableCertificateBuilderDriver.swift
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

typealias DisplayableCertificateBuilderCompletion = (DisplayableCertificate) -> Void

protocol DisplayableCertificateBuilderDriver {

    func build(usingTrust trust: SecTrust) -> DisplayableCertificate

}

class DisplayableCertificateBuilder {

    let driver: DisplayableCertificateBuilderDriver

    init(withDriver driver: DisplayableCertificateBuilderDriver = NativeDisplayableCertificateBuilderDriver()) {
        self.driver = driver
    }

    func build(usingTrust trust: SecTrust, completion: @escaping DisplayableCertificateBuilderCompletion) {
        DispatchQueue.global(qos: .background).async {
            completion(self.driver.build(usingTrust: trust))
        }
    }

}

class DisplayableCertificate {

    static let error = DisplayableCertificate(error: true)

    let isError: Bool

    var summary: String?
    var commonName: String?
    var emails: [String]?
    var publicKey: DisplayableKey?

    var issuer: DisplayableCertificate?

    private init(error: Bool) {
        isError = error
    }

    init() {
        isError = false
    }

}

struct DisplayableKey {

    var keyId: Data?
    var externalRepresentation: Data?

    var bitSize: Int?
    var blockSize: Int?
    var effectiveSize: Int?

    var canDecrypt: Bool?
    var canDerive: Bool?
    var canEncrypt: Bool?
    var canSign: Bool?
    var canUnwrap: Bool?
    var canVerify: Bool?
    var canWrap: Bool?

    var isPermanent: Bool?
    var type: String?

}
