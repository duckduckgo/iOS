//
//  PrivacyProtectionEncryptionDetailController.swift
//  DuckDuckGo
//
//  Created by Christopher Brind on 01/11/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import Core

class PrivacyProtectionEncryptionDetailController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var domainLabel: UILabel!
    @IBOutlet weak var encryptedLabel: UILabel!
    @IBOutlet weak var unencryptedLabel: UILabel!
    @IBOutlet weak var mixedContentLabel: UILabel!

    lazy var serverTrustCache = ServerTrustCache.shared

    weak var siteRating: SiteRating!

    override func viewDidLoad() {

        updateHttpsStatus()
        updateDomain()
        beginCertificateInfoExtraction()

    }

    @IBAction func onBack() {
        navigationController?.popViewController(animated: true)
    }

    private func updateDomain() {
        domainLabel.text = siteRating.domain
    }

    private func updateHttpsStatus() {
        imageView.image = siteRating.https ? #imageLiteral(resourceName: "PP Hero Connection On") : #imageLiteral(resourceName: "PP Hero Connection Off")
        encryptedLabel.isHidden = true
        unencryptedLabel.isHidden = true
        mixedContentLabel.isHidden = true

        if !siteRating.https {
            unencryptedLabel.isHidden = false
        } else if !siteRating.hasOnlySecureContent {
            mixedContentLabel.isHidden = false
        } else {
            encryptedLabel.isHidden = false
        }
    }

    private func beginCertificateInfoExtraction() {
        guard siteRating.https else { return }
        guard let serverTrust = serverTrustCache.get(forDomain: siteRating.domain) else {
            print("***", #function, "no serverTrust for", siteRating.domain)
            return
        }
        DisplayableCertificateBuilder().build(usingTrust: serverTrust) { [weak self] displayable in
            DispatchQueue.main.async {
                self?.renderCertificates(displayable)
            }
        }
    }

    private func renderCertificates(_ cert: DisplayableCertificate) {
        print("***", #function, "Certificate: ", cert.commonName, "issuer:", cert.issuer?.commonName)
        print("***", #function, "Public Key: ", cert.publicKey)

        if let issuer = cert.issuer {
            renderCertificates(issuer)
        }
        
    }

}

extension PrivacyProtectionEncryptionDetailController: PrivacyProtectionInfoDisplaying {

    func using(_ siteRating: SiteRating) {
        self.siteRating = siteRating
    }

}
