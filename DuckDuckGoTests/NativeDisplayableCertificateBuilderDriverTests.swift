//
//  NativeDisplayableCertificateBuilderDriver.swift
//  UnitTests
//
//  Created by Christopher Brind on 12/11/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation
import XCTest
@testable import DuckDuckGo

class NativeDisplayableCertificateBuilderDriverTests: XCTestCase {

    func testDisplayableCertificateBuiltFromTrustWithPublicKey() {
        let trust = readCertsAsTrust(["testcert"])
        let displayableCert = NativeDisplayableCertificateBuilderDriver().build(usingTrust: trust)
        XCTAssertEqual("RSA", displayableCert.publicKey?.type)
        XCTAssertEqual(false, displayableCert.publicKey?.canSign)
        XCTAssertEqual(true, displayableCert.publicKey?.canWrap)
        XCTAssertEqual(false, displayableCert.publicKey?.canDerive)
        XCTAssertEqual(false, displayableCert.publicKey?.canUnwrap)
        XCTAssertEqual(true, displayableCert.publicKey?.canVerify)
        XCTAssertEqual(true, displayableCert.publicKey?.canDecrypt)
        XCTAssertEqual(true, displayableCert.publicKey?.canEncrypt)
        XCTAssertEqual(4096, displayableCert.publicKey?.bitSize)
        XCTAssertEqual(512, displayableCert.publicKey?.blockSize)
        XCTAssertEqual(4096, displayableCert.publicKey?.effectiveSize)
    }

    func testDisplayableCertificateBuiltFromTrustWithIssuer() {
        let trust = readCertsAsTrust(["ddgcert", "ddgissuercert"])
        let displayableCert = NativeDisplayableCertificateBuilderDriver().build(usingTrust: trust)
        XCTAssertEqual("DigiCert SHA2 Secure Server CA", displayableCert.issuer?.summary)
    }

    func testDisplayableCertificateBuiltFromTrustWithEmail() {
        let trust = readCertsAsTrust(["testcert"])
        let displayableCert = NativeDisplayableCertificateBuilderDriver().build(usingTrust: trust)
        XCTAssertEqual("test@example.com", displayableCert.emails?[0])
    }

    func testDisplayableCertificateBuiltFromTrustWithCommonNameAndSummary() {
        let trust = readCertsAsTrust(["testcert"])
        let displayableCert = NativeDisplayableCertificateBuilderDriver().build(usingTrust: trust)
        XCTAssertEqual("Test Cert", displayableCert.commonName)
        XCTAssertEqual("Test Cert", displayableCert.summary)
    }

    private func readCertsAsTrust(_ names: [String]) -> SecTrust {

        var certs = [SecCertificate]()

        for name in names {
            let url = Bundle(for: type(of: self)).url(forResource: name, withExtension: "der")
            let data = try? Data(contentsOf: url!) as CFData
            let cert = SecCertificateCreateWithData(nil, data!)
            certs.append(cert!)
        }

        var trust: SecTrust?
        SecTrustCreateWithCertificates(certs as CFTypeRef, SecPolicyCreateBasicX509(), &trust)

        return trust!
    }

}
