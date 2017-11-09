//
//  CertificateInfoExtractor.swift
//  DuckDuckGo
//
//  Created by Christopher Brind on 09/11/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

typealias CertificateInfoExtractionCompletion = (CertificateInfo) -> Void

protocol CertificateInfoExtractionDriver {

    func extract(from serverTrust: SecTrust) -> CertificateInfo

}

class CertificateInfoExtractor {

    let driver: CertificateInfoExtractionDriver

    init(withDriver driver: CertificateInfoExtractionDriver = NativeCertificateInfoExtractionDriver()) {
        self.driver = driver
    }

    func extract(serverTrust: SecTrust, completion: @escaping CertificateInfoExtractionCompletion) {
        DispatchQueue.global(qos: .background).async {
            completion(self.driver.extract(from: serverTrust))
        }
    }

}

class CertificateInfo {

}

class NativeCertificateInfoExtractionDriver: CertificateInfoExtractionDriver {

    func extract(from serverTrust: SecTrust) -> CertificateInfo {
        return CertificateInfo()
    }

}
