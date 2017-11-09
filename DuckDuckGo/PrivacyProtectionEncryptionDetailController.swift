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
        encryptedLabel.isHidden = !siteRating.https
        unencryptedLabel.isHidden = siteRating.https
    }

    private func beginCertificateInfoExtraction() {
        guard siteRating.https else { return }
        guard let serverTrust = serverTrustCache.get(forDomain: siteRating.domain) else { return }
        CertificateInfoExtractor().extract(serverTrust: serverTrust) { [weak self] certInfo in
            DispatchQueue.main.async {
                self?.updateCertificateInfo(certInfo)
            }
        }
    }

    private func updateCertificateInfo(_ certInfo: CertificateInfo) {
        print("***", #function, certInfo)
    }

}

extension PrivacyProtectionEncryptionDetailController: PrivacyProtectionInfoDisplaying {

    func using(_ siteRating: SiteRating) {
        self.siteRating = siteRating
    }

}
