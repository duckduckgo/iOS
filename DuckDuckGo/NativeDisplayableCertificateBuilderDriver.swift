//
//  NativeDisplayableCertificateBuilderDriver.swift
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

class NativeDisplayableCertificateBuilderDriver: DisplayableCertificateBuilderDriver {

    func build(usingTrust trust: SecTrust) -> DisplayableCertificate {

        let certCount = SecTrustGetCertificateCount(trust)
        guard certCount != 0 else { return DisplayableCertificate.error }

        var head: DisplayableCertificate!
        var next: DisplayableCertificate!

        for certIndex in 0 ..< certCount {
            guard let certInChain = SecTrustGetCertificateAtIndex(trust, certIndex) else { return DisplayableCertificate.error }
            let displayableCert = certInChain.toDisplayable()
            if head == nil {
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

fileprivate extension SecKey {

    func toDisplayable() -> DisplayableKey {
        var key = DisplayableKey()

        key.blockSize = SecKeyGetBlockSize(self)

        if #available(iOS 10.0, *) {
            key.externalRepresentation = SecKeyCopyExternalRepresentation(self, nil) as Data?
            
            guard let attrs: NSDictionary = SecKeyCopyAttributes(self) else { return key }

            key.bitSize = attrs[kSecAttrKeySizeInBits] as? Int
            key.effectiveSize = attrs[kSecAttrEffectiveKeySize] as? Int
            key.canDecrypt = attrs[kSecAttrCanDecrypt] as? Bool ?? false
            key.canDerive = attrs[kSecAttrCanDerive] as? Bool ?? false
            key.canEncrypt = attrs[kSecAttrCanEncrypt] as? Bool ?? false
            key.canSign = attrs[kSecAttrCanSign] as? Bool ?? false
            key.canUnwrap = attrs[kSecAttrCanUnwrap] as? Bool ?? false
            key.canVerify = attrs[kSecAttrCanVerify] as? Bool ?? false
            key.canWrap = attrs[kSecAttrCanWrap] as? Bool ?? false
            key.isPermanent = attrs[kSecAttrIsPermanent] as? Bool ?? false
            key.keyId = attrs[kSecAttrApplicationLabel] as? Data

            if let type = attrs[kSecAttrType] as? String {
                key.type = typeToString(type)
            }
        }

        return key
    }

    @available(iOS 10, *)
    private func typeToString(_ type: String) -> String? {
        switch(type as CFString) {
        case kSecAttrKeyTypeRSA: return "RSA"
        case kSecAttrKeyTypeEC: return "Elliptic Curve"
        case kSecAttrKeyTypeECSECPrimeRandom: return "Elliptic Curve (Prime Random)"
        default: return nil
        }
    }

}
