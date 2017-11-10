//
//  CertificateInfoExtractor.swift
//  DuckDuckGo
//
//  Created by Christopher Brind on 09/11/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation
import Core
import Security

typealias DisplayableCertificateBuilderCompletion = ([DisplayableCertificate]) -> Void

protocol DisplayableCertificateBuilderDriver {

    func build(usingTrust trust: SecTrust) -> [DisplayableCertificate]

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

struct DisplayableCertificate {

    static let error = DisplayableCertificate()

    var summary: String?
    var commonName: String?
    var emails: [String]?
    var publicKey: DisplayableKey?

}

struct DisplayableKey {

    var keyId: Data?
    var keyType = "RSA" // it's always RSA on iOS, see kSecAttrKeyType in SecItem.h
    var blockSize: Int?

    var canDecrypt: Bool?
    var canDerive: Bool?
    var canEncrypt: Bool?
    var canSign: Bool?
    var canUnwrap: Bool?
    var canVerify: Bool?
    var canWrap: Bool?

}

class NativeDisplayableCertificateBuilderDriver: DisplayableCertificateBuilderDriver {

    func build(usingTrust trust: SecTrust) -> [DisplayableCertificate] {
        var certs = [DisplayableCertificate]()

        guard errSecSuccess == SecTrustSetNetworkFetchAllowed(trust, true) else {
            Logger.log(text: "SecTrustSetNetworkFetchAllowed FAILED")
            return certs
        }

        var steResult: SecTrustResultType = .unspecified
        guard errSecSuccess == SecTrustEvaluate(trust, &steResult) else {
            Logger.log(text: "SecTrustEvaluate FAILED")
            return certs
        }

        Logger.log(text: "steResult = \(steResult.rawValue)")

        let certCount = SecTrustGetCertificateCount(trust)
        for certIndex in 0 ..< certCount {
            guard let cert = SecTrustGetCertificateAtIndex(trust, certIndex) else {
                certs.append(DisplayableCertificate.error)
                continue
            }
            certs.append(cert.displayable)
        }
        return certs
    }

}

fileprivate extension SecCertificate {

    var displayable: DisplayableCertificate {
        var displayable = DisplayableCertificate()

        displayable.summary = extractSummary()
        if #available(iOS 10.3, *) {
            displayable.commonName = extractCommonName()
            displayable.emails = extractEmails()
        }

        var secTrust: SecTrust?
        guard errSecSuccess == SecTrustCreateWithCertificates(self, SecPolicyCreateBasicX509(), &secTrust),
            let certTrust = secTrust else { return displayable }

        guard errSecSuccess == SecTrustSetNetworkFetchAllowed(certTrust, true) else {
            return displayable
        }

        var evaluationResultType: SecTrustResultType = .unspecified
        guard errSecSuccess == SecTrustEvaluate(certTrust, &evaluationResultType) else { return displayable }

        displayable.publicKey = SecTrustCopyPublicKey(certTrust)?.displayable

        return displayable
    }

    private func extractSummary() -> String {
        return SecCertificateCopySubjectSummary(self) as String? ?? ""
    }

    @available(iOS 10.3, *)
    private func extractCommonName() -> String {
        var commonName: CFString?
        SecCertificateCopyCommonName(self, &commonName)
        return commonName as String? ?? ""
    }

    @available(iOS 10.3, *)
    private func extractEmails() -> [String]? {
        var emails: CFArray?
        guard errSecSuccess == SecCertificateCopyEmailAddresses(self, &emails) else { return nil }
        return emails as? [String]
    }

}

// how to get modulus and exp, if needed: https://stackoverflow.com/a/43225656/73479

fileprivate extension SecKey {

    var displayable: DisplayableKey {
        var key = DisplayableKey()

        key.blockSize = SecKeyGetBlockSize(self)

        if #available(iOS 10.0, *) {

            guard let attrs: NSDictionary = SecKeyCopyAttributes(self) else { return key }

            key.keyId = attrs[kSecAttrApplicationLabel] as? Data
            key.canDecrypt = attrs[kSecAttrCanDecrypt] as? Bool
            key.canDerive = attrs[kSecAttrCanDerive] as? Bool
            key.canEncrypt = attrs[kSecAttrCanEncrypt] as? Bool
            key.canSign = attrs[kSecAttrCanSign] as? Bool
            key.canUnwrap = attrs[kSecAttrCanUnwrap] as? Bool
            key.canVerify = attrs[kSecAttrCanVerify] as? Bool
            key.canWrap = attrs[kSecAttrCanWrap] as? Bool

            print("***", #function, attrs)
        }

        return key
    }

}

