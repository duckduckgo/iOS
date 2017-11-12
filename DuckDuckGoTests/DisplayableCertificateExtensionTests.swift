//
//  DisplayableCertificateExtensionTests.swift
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
import XCTest
@testable import DuckDuckGo

class DisplayableCertificateExtensionTests: XCTestCase {

    func testErrorDisplayCertificateCreatesErrorMessage() {
        let testee = DisplayableCertificate.error

        XCTAssertEqual(1, testee.toSections().count)
        XCTAssertEqual("Error extracting certificate", testee.toSections()[0].name)
        XCTAssertEqual(0, testee.toSections()[0].rows.count)

    }

    func testDisplayCertificateWithPublicKeyCreatesPublicKeySectionWithExternalRepresentation() {
        let testee = DisplayableCertificate()
        testee.publicKey = DisplayableKey()
        testee.publicKey?.externalRepresentation = "Fake ID".data(using: .utf8)

        XCTAssertEqual(2, testee.toSections()[1].rows.count)
        XCTAssertEqual("Public Key", testee.toSections()[1].rows[1].name)
        XCTAssertEqual("7 bytes : 46 61 6b 65 20 49 44", testee.toSections()[1].rows[1].value)
    }

    func testDisplayCertificateWithPublicKeyCreatesPublicKeySectionWithKeyId() {
        let testee = DisplayableCertificate()
        testee.publicKey = DisplayableKey()
        testee.publicKey?.keyId = "Fake ID".data(using: .utf8)

        XCTAssertEqual(2, testee.toSections()[1].rows.count)
        XCTAssertEqual("Subject Key Identifier", testee.toSections()[1].rows[1].name)
        XCTAssertEqual("7 bytes : 46 61 6b 65 20 49 44", testee.toSections()[1].rows[1].value)
    }

    func testDisplayCertificateWithPublicKeyCreatesPublicKeySectionIsPermanent() {
        let testee = DisplayableCertificate()
        testee.publicKey = DisplayableKey()
        testee.publicKey?.isPermanent = true

        XCTAssertEqual(2, testee.toSections()[1].rows.count)
        XCTAssertEqual("Permanent", testee.toSections()[1].rows[1].name)
        XCTAssertEqual("Yes", testee.toSections()[1].rows[1].value)
    }

    func testDisplayCertificateWithPublicKeyCreatesPublicKeySectionAllUsages() {
        let testee = DisplayableCertificate()
        testee.publicKey = DisplayableKey()
        testee.publicKey?.canDecrypt = true
        testee.publicKey?.canDerive = true
        testee.publicKey?.canEncrypt = true
        testee.publicKey?.canSign = true
        testee.publicKey?.canUnwrap = true
        testee.publicKey?.canVerify = true
        testee.publicKey?.canWrap = true

        XCTAssertEqual(2, testee.toSections()[1].rows.count)
        XCTAssertEqual("Decrypt, Derive, Encrypt, Sign, Unwrap, Verify, Wrap", testee.toSections()[1].rows[1].value)
    }

    func testDisplayCertificateWithPublicKeyCreatesPublicKeySectionCanWrap() {
        let testee = DisplayableCertificate()
        testee.publicKey = DisplayableKey()
        testee.publicKey?.canWrap = true

        XCTAssertEqual(2, testee.toSections()[1].rows.count)
        XCTAssertEqual("Wrap", testee.toSections()[1].rows[1].value)
    }

    func testDisplayCertificateWithPublicKeyCreatesPublicKeySectionCanVerify() {
        let testee = DisplayableCertificate()
        testee.publicKey = DisplayableKey()
        testee.publicKey?.canVerify = true

        XCTAssertEqual(2, testee.toSections()[1].rows.count)
        XCTAssertEqual("Verify", testee.toSections()[1].rows[1].value)
    }

    func testDisplayCertificateWithPublicKeyCreatesPublicKeySectionCanUnwrap() {
        let testee = DisplayableCertificate()
        testee.publicKey = DisplayableKey()
        testee.publicKey?.canUnwrap = true

        XCTAssertEqual(2, testee.toSections()[1].rows.count)
        XCTAssertEqual("Unwrap", testee.toSections()[1].rows[1].value)
    }

    func testDisplayCertificateWithPublicKeyCreatesPublicKeySectionCanSign() {
        let testee = DisplayableCertificate()
        testee.publicKey = DisplayableKey()
        testee.publicKey?.canSign = true

        XCTAssertEqual(2, testee.toSections()[1].rows.count)
        XCTAssertEqual("Sign", testee.toSections()[1].rows[1].value)
    }

    func testDisplayCertificateWithPublicKeyCreatesPublicKeySectionCanEncrypt() {
        let testee = DisplayableCertificate()
        testee.publicKey = DisplayableKey()
        testee.publicKey?.canEncrypt = true

        XCTAssertEqual(2, testee.toSections()[1].rows.count)
        XCTAssertEqual("Encrypt", testee.toSections()[1].rows[1].value)
    }

    func testDisplayCertificateWithPublicKeyCreatesPublicKeySectionCanDerive() {
        let testee = DisplayableCertificate()
        testee.publicKey = DisplayableKey()
        testee.publicKey?.canDerive = true

        XCTAssertEqual(2, testee.toSections()[1].rows.count)
        XCTAssertEqual("Derive", testee.toSections()[1].rows[1].value)
    }

    func testDisplayCertificateWithPublicKeyCreatesPublicKeySectionCanDecrypt() {
        let testee = DisplayableCertificate()
        testee.publicKey = DisplayableKey()
        testee.publicKey?.canDecrypt = true

        XCTAssertEqual(2, testee.toSections()[1].rows.count)
        XCTAssertEqual("Usage", testee.toSections()[1].rows[1].name)
        XCTAssertEqual("Decrypt", testee.toSections()[1].rows[1].value)
    }

    func testDisplayCertificateWithPublicKeyCreatesPublicKeySectionAndBitSize() {
        let testee = DisplayableCertificate()
        testee.publicKey = DisplayableKey()
        testee.publicKey?.bitSize = 66

        XCTAssertEqual(2, testee.toSections()[1].rows.count)
        XCTAssertEqual("Key Size", testee.toSections()[1].rows[1].name)
        XCTAssertEqual("66 bits", testee.toSections()[1].rows[1].value)
    }

    func testDisplayCertificateWithPublicKeyCreatesPublicKeySectionAndType() {
        let testee = DisplayableCertificate()
        testee.publicKey = DisplayableKey()
        testee.publicKey?.type = "Fake"

        XCTAssertEqual(2, testee.toSections().count)
        XCTAssertEqual("Public Key", testee.toSections()[1].name)

        XCTAssertEqual(1, testee.toSections()[1].rows.count)
        XCTAssertEqual("Algorithm", testee.toSections()[1].rows[0].name)
    }

    func testBasicDisplayCertificateCreatesSingleSectionWithSummaryAndCommonNameRows() {
        let testee = DisplayableCertificate()
        XCTAssertEqual(2, testee.toSections()[0].rows.count)
        XCTAssertEqual("Summary", testee.toSections()[0].rows[0].name)
        XCTAssertEqual("Common Name", testee.toSections()[0].rows[1].name)
    }

    func testDisplayCertificateWithIssuerCreatesIssuerSection() {
        let testee = DisplayableCertificate()
        testee.issuer = DisplayableCertificate()
        testee.issuer?.summary = "Summary Value"

        XCTAssertEqual("Issuer", testee.toSections()[1].name)
        XCTAssertEqual("Summary", testee.toSections()[1].rows[0].name)
        XCTAssertEqual("Summary Value", testee.toSections()[1].rows[0].value)
    }

    func testDisplayCertificateWithNoCommonNameIssuerCreatesUnknownIssuerRow() {
        let testee = DisplayableCertificate()
        testee.issuer = DisplayableCertificate()

        XCTAssertEqual(2, testee.toSections().count)
        XCTAssertEqual("Issuer", testee.toSections()[0].rows[2].name)
        XCTAssertEqual("Unknown", testee.toSections()[0].rows[2].value)
    }

    func testDisplayCertificateWithIssuerCreatesIssuerRow() {
        let testee = DisplayableCertificate()
        testee.issuer = DisplayableCertificate()
        testee.issuer?.commonName = "Common Name Value"

        XCTAssertEqual(2, testee.toSections().count)
        XCTAssertEqual("Issuer", testee.toSections()[0].rows[2].name)
        XCTAssertEqual("Common Name Value", testee.toSections()[0].rows[2].value)
    }

    func testBasicDisplayCertificateCreatesSingleSubjectNameSection() {
        let testee = DisplayableCertificate()
        XCTAssertEqual(1, testee.toSections().count)
        XCTAssertEqual("Subject Name", testee.toSections()[0].name)
    }

}
