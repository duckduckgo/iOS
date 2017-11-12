//
//  CertificateInfoExtractor.swift
//  DuckDuckGo
//
//  Created by Christopher Brind on 09/11/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

    static let error = DisplayableCertificate(summary: "Error extracting certificate")

    var summary: String?
    var commonName: String?
    var emails: [String]?
    var publicKey: DisplayableKey?

    var issuer: DisplayableCertificate?

    init() { }

    init(summary: String) {
        self.summary = summary
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
