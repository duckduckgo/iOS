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

    struct Section {
        var name: String
        var rows: [Row]
    }

    struct Row {
        var name: String
        var value: String
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var domainLabel: UILabel!
    @IBOutlet weak var encryptedLabel: UILabel!
    @IBOutlet weak var unencryptedLabel: UILabel!
    @IBOutlet weak var mixedContentLabel: UILabel!

    weak var siteRating: SiteRating!

    private let serverTrustCache = ServerTrustCache.shared
    private var sections = [Section]()

    override func viewDidLoad() {

        initTableView()
        initHttpsStatus()
        initDomain()
        beginCertificateInfoExtraction()

    }

    @IBAction func onBack() {
        navigationController?.popViewController(animated: true)
    }

    private func initTableView() {
        tableView.dataSource = self
    }

    private func initDomain() {
        domainLabel.text = siteRating.domain
    }

    private func initHttpsStatus() {
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
            return
        }
        DisplayableCertificateBuilder().build(usingTrust: serverTrust) { [weak self] displayable in
            self?.sections = displayable.toSections()
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }

}

extension PrivacyProtectionEncryptionDetailController: PrivacyProtectionInfoDisplaying {

    func using(_ siteRating: SiteRating) {
        self.siteRating = siteRating
    }

}

extension PrivacyProtectionEncryptionDetailController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].name
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        cell.textLabel?.text = sections[indexPath.section].rows[indexPath.row].name
        cell.detailTextLabel?.text = sections[indexPath.section].rows[indexPath.row].value
        return cell
    }

}

fileprivate extension Data {

    func hexString() -> String {
        let bytes =  map { String(format: "%02hhx", $0) }
        return "\(bytes.count) bytes : \(bytes.joined(separator: " "))"
    }

}

extension DisplayableCertificate {

    func toSections() -> [PrivacyProtectionEncryptionDetailController.Section] {
        var sections = [PrivacyProtectionEncryptionDetailController.Section]()

        if isError {
            sections.append(PrivacyProtectionEncryptionDetailController.Section(name: "Error extracting certificate", rows: []))
            return sections
        }

        sections.append(PrivacyProtectionEncryptionDetailController.Section(name: "Subject Name", rows: buildIdentitySection()))

        if let publicKey = publicKey {
            sections.append(PrivacyProtectionEncryptionDetailController.Section(name: "Public Key", rows: publicKey.toRows()))
        }

        var issuer: DisplayableCertificate! = self.issuer
        while issuer != nil {
            sections.append(PrivacyProtectionEncryptionDetailController.Section(name: issuer.commonName ?? "Issuer", rows: issuer.buildIdentitySection()))

            if let issuerKey = issuer.publicKey {
                sections.append(PrivacyProtectionEncryptionDetailController.Section(name: "Public Key", rows: issuerKey.toRows()))
            }

            issuer = issuer.issuer
        }

        return sections
    }

    private func buildIdentitySection() -> [PrivacyProtectionEncryptionDetailController.Row] {
        var rows = [PrivacyProtectionEncryptionDetailController.Row]()

        rows.append(PrivacyProtectionEncryptionDetailController.Row(name: "Summary", value: summary ?? "" ))
        rows.append(PrivacyProtectionEncryptionDetailController.Row(name: "Common Name", value: commonName ?? "" ))

        for email in emails ?? [] {
            rows.append(PrivacyProtectionEncryptionDetailController.Row(name: "Email", value: email))
        }

        if let issuer = issuer {
            rows.append(PrivacyProtectionEncryptionDetailController.Row(name: "Issuer", value: issuer.commonName ?? "Unknown"))
        }

        return rows
    }



}

extension DisplayableKey {

    func toRows() -> [PrivacyProtectionEncryptionDetailController.Row] {
        var rows = [PrivacyProtectionEncryptionDetailController.Row]()

        rows.append(PrivacyProtectionEncryptionDetailController.Row(name: "Algorithm", value: type ?? ""))
        if let bitSize = bitSize {
            rows.append(PrivacyProtectionEncryptionDetailController.Row(name: "Key Size", value: "\(bitSize) bits"))
        }

        if let effectiveSize = effectiveSize {
            rows.append(PrivacyProtectionEncryptionDetailController.Row(name: "Effective Size", value: "\(effectiveSize) bits"))
        }

        let usage = [
            canDecrypt ?? false ? "Decrypt" : "",
            canDerive ?? false ? "Derive" : "",
            canEncrypt ?? false ? "Encrypt" : "",
            canSign ?? false ? "Sign" : "",
            canUnwrap ?? false ? "Unwrap" : "",
            canVerify ?? false ? "Verify" : "",
            canWrap ?? false ? "Wrap" : "",
            ].filter({ $0.count > 0 })
        if usage.count > 0 {
            rows.append(PrivacyProtectionEncryptionDetailController.Row(name: "Usage", value: usage.joined(separator: ", ")))
        }

        if let permanent = isPermanent {
            rows.append(PrivacyProtectionEncryptionDetailController.Row(name: "Permanent", value: permanent ? "Yes" : "No"))
        }

        if let keyId = keyId {
            rows.append(PrivacyProtectionEncryptionDetailController.Row(name: "ID", value: keyId.hexString()))
        }

        if let externalRepresentation = externalRepresentation {
            rows.append(PrivacyProtectionEncryptionDetailController.Row(name: "Key", value: externalRepresentation.hexString()))
        }

        return rows
    }

}

