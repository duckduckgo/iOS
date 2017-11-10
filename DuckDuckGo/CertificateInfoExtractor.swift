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

    static let error = DisplayableCertificate()

    var summary: String?
    var commonName: String?
    var emails: [String]?
    var publicKey: DisplayableKey?

    var issuer: DisplayableCertificate?

}

struct DisplayableKey {

    var keyId: Data?

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

class NativeDisplayableCertificateBuilderDriver: DisplayableCertificateBuilderDriver {

    func build(usingTrust trust: SecTrust) -> DisplayableCertificate {

        var head: DisplayableCertificate!
        var next: DisplayableCertificate!

        let certCount = SecTrustGetCertificateCount(trust)
        for certIndex in 0 ..< certCount {
            guard let certInChain = SecTrustGetCertificateAtIndex(trust, certIndex) else { return DisplayableCertificate.error }
            let displayableCert: DisplayableCertificate = certInChain.toDisplayable()
            if nil == head {
                head = displayableCert
            } else {
                next.issuer = displayableCert
            }
            next = displayableCert
        }

        return head
    }

}

fileprivate extension SecCertificate {

    func toDisplayable() -> DisplayableCertificate {
        print("***", #function, "SecCertificate", self)

        let displayable = DisplayableCertificate()

        displayable.summary = extractSummary()
        if #available(iOS 10.3, *) {
            displayable.commonName = extractCommonName()
            displayable.emails = extractEmails()
        }

        displayable.publicKey = extractKey()

        return displayable
    }

    private func extractKey() -> DisplayableKey? {
        var secTrust: SecTrust?
        guard errSecSuccess == SecTrustCreateWithCertificates(self, SecPolicyCreateBasicX509(), &secTrust),
            let certTrust = secTrust else { return nil }

        return SecTrustCopyPublicKey(certTrust)?.toDisplayable()
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

    func toDisplayable() -> DisplayableKey {
        print("***", #function, "SecKey", self)

        var key = DisplayableKey()

        key.blockSize = SecKeyGetBlockSize(self)

        if #available(iOS 10.0, *) {
            guard let attrs: NSDictionary = SecKeyCopyAttributes(self) else { return key }

            key.bitSize = attrs[kSecAttrKeySizeInBits] as? Int
            key.effectiveSize = attrs[kSecAttrEffectiveKeySize] as? Int
            key.canDecrypt = attrs[kSecAttrCanDecrypt] as? Bool
            key.canDerive = attrs[kSecAttrCanDerive] as? Bool
            key.canEncrypt = attrs[kSecAttrCanEncrypt] as? Bool
            key.canSign = attrs[kSecAttrCanSign] as? Bool
            key.canUnwrap = attrs[kSecAttrCanUnwrap] as? Bool
            key.canVerify = attrs[kSecAttrCanVerify] as? Bool
            key.canWrap = attrs[kSecAttrCanWrap] as? Bool
            key.isPermanent = attrs[kSecAttrIsPermanent] as? Bool
            key.keyId = attrs[kSecAttrApplicationLabel] as? Data

            if let type = attrs[kSecAttrType] as? String {
                 key.type = typeToString(type)
            }

            print("***", #function, attrs)
        }

        return key
    }

    @available(iOS 10, *)
    private func typeToString(_ type: String) -> String? {
        switch(type as CFString) {
        case kSecAttrKeyTypeRSA: return "RSA"
        case kSecAttrKeyTypeEC: return "EC"
        case kSecAttrKeyTypeECSECPrimeRandom: return "EC Prime Random"
        default: return nil
        }
    }

}

