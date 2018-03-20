//
//  PrivacyProtectionEncryptionDetailController.swift
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
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var domainLabel: UILabel!
    @IBOutlet weak var encryptedLabel: UILabel!
    @IBOutlet weak var unencryptedLabel: UILabel!
    @IBOutlet weak var mixedContentLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!

    private weak var siteRating: SiteRating!
    private weak var contentBlocker: ContentBlockerConfigurationStore!

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
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func initDomain() {
        domainLabel.text = siteRating.domain
    }

    private func initHttpsStatus() {
        if siteRating.hasOnlySecureContent {
            iconImage.image = #imageLiteral(resourceName: "PP Hero Connection On")
        } else if siteRating.https {
            iconImage.image = #imageLiteral(resourceName: "PP Hero Connection Off")
        } else {
            iconImage.image = #imageLiteral(resourceName: "PP Hero Connection Bad")
        }

        encryptedLabel.isHidden = true
        unencryptedLabel.isHidden = true
        mixedContentLabel.isHidden = true

        messageLabel.text = UserText.ppEncryptionStandardMessage
        if !siteRating.https {
            unencryptedLabel.isHidden = false
        } else if !siteRating.hasOnlySecureContent {
            mixedContentLabel.isHidden = false
            messageLabel.text = UserText.ppEncryptionMixedMessage
        } else {
            encryptedLabel.isHidden = false
        }
    }

    private func beginCertificateInfoExtraction() {
        guard siteRating.https else { return }
        guard let serverTrust = serverTrustCache.get(forDomain: siteRating.url.host ?? "") else {
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

    func using(siteRating: SiteRating, contentBlocker: ContentBlockerConfigurationStore) {
        self.contentBlocker = contentBlocker
        self.siteRating = siteRating
    }

}

extension PrivacyProtectionEncryptionDetailController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "Header") as! PrivacyProtectionEncryptionHeaderCell
        header.update(section: sections[section].name)
        return header
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! PrivacyProtectionEncryptionDetailCell
        cell.update(name: sections[indexPath.section].rows[indexPath.row].name, value: sections[indexPath.section].rows[indexPath.row].value)
        return cell
    }

}

fileprivate extension Data {

    func hexString() -> String {
        let bytes =  map { String(format: "%02hhx", $0) }
        return "\(bytes.count) bytes : \(bytes.joined(separator: " "))"
    }

}

class PrivacyProtectionEncryptionDetailCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!

    func update(name: String, value: String) {
        nameLabel.text = name
        valueLabel.text = value
    }

}

class PrivacyProtectionEncryptionHeaderCell: UITableViewCell {

    @IBOutlet weak var sectionLabel: UILabel!

    func update(section: String) {
        sectionLabel.text = section
    }

}

extension DisplayableCertificate {

    func toSections() -> [PrivacyProtectionEncryptionDetailController.Section] {
        var sections = [PrivacyProtectionEncryptionDetailController.Section]()

        if isError {
            sections.append(PrivacyProtectionEncryptionDetailController.Section(name: UserText.ppEncryptionCertError, rows: []))
            return sections
        }

        sections.append(PrivacyProtectionEncryptionDetailController.Section(name: UserText.ppEncryptionSubjectName, rows: buildIdentitySection()))

        if let publicKey = publicKey {
            sections.append(PrivacyProtectionEncryptionDetailController.Section(name: UserText.ppEncryptionPublicKey, rows: publicKey.toRows()))
        }

        var issuer: DisplayableCertificate! = self.issuer
        while issuer != nil {
            sections.append(PrivacyProtectionEncryptionDetailController.Section(name: issuer.commonName ?? UserText.ppEncryptionIssuer, rows: issuer.buildIdentitySection()))

            if let issuerKey = issuer.publicKey {
                sections.append(PrivacyProtectionEncryptionDetailController.Section(name: UserText.ppEncryptionPublicKey, rows: issuerKey.toRows()))
            }

            issuer = issuer.issuer
        }

        return sections
    }

    private func buildIdentitySection() -> [PrivacyProtectionEncryptionDetailController.Row] {
        var rows = [PrivacyProtectionEncryptionDetailController.Row]()

        rows.append(PrivacyProtectionEncryptionDetailController.Row(name: UserText.ppEncryptionSummary, value: summary ?? "" ))
        rows.append(PrivacyProtectionEncryptionDetailController.Row(name: UserText.ppEncryptionCommonName, value: commonName ?? "" ))

        for email in emails ?? [] {
            rows.append(PrivacyProtectionEncryptionDetailController.Row(name: UserText.ppEncryptionEmail, value: email))
        }

        if let issuer = issuer {
            rows.append(PrivacyProtectionEncryptionDetailController.Row(name: UserText.ppEncryptionIssuer, value: issuer.commonName ?? UserText.ppEncryptionUnknown))
        }

        return rows
    }



}

extension DisplayableKey {

    func toRows() -> [PrivacyProtectionEncryptionDetailController.Row] {
        var rows = [PrivacyProtectionEncryptionDetailController.Row]()

        rows.append(PrivacyProtectionEncryptionDetailController.Row(name: UserText.ppEncryptionAlgorithm, value: type ?? ""))
        if let bitSize = bitSize {
            rows.append(PrivacyProtectionEncryptionDetailController.Row(name: UserText.ppEncryptionKeySize, value: UserText.ppEncryptionBits.format(arguments: bitSize)))
        }

        if let effectiveSize = effectiveSize {
            rows.append(PrivacyProtectionEncryptionDetailController.Row(name: UserText.ppEncryptionEffectiveSize, value: UserText.ppEncryptionBits.format(arguments: effectiveSize)))
        }

        let usage = [
            canDecrypt ? UserText.ppEncryptionUsageDecrypt : "",
            canDerive ? UserText.ppEncryptionUsageDerive : "",
            canEncrypt ? UserText.ppEncryptionUsageEncrypt : "",
            canSign ? UserText.ppEncryptionUsageSign : "",
            canUnwrap ? UserText.ppEncryptionUsageUnwrap : "",
            canVerify ? UserText.ppEncryptionUsageVerify : "",
            canWrap ? UserText.ppEncryptionUsageWrap : "",
            ].filter({ $0.count > 0 })
        if usage.count > 0 {
            rows.append(PrivacyProtectionEncryptionDetailController.Row(name: UserText.ppEncryptionUsage, value: usage.joined(separator: ", ")))
        }

        if let isPermanent = isPermanent {
            rows.append(PrivacyProtectionEncryptionDetailController.Row(name: UserText.ppEncryptionPermanent,
                                                                        value: isPermanent ? UserText.ppEncryptionYes :  UserText.ppEncryptionNo))
        }

        if let keyId = keyId {
            rows.append(PrivacyProtectionEncryptionDetailController.Row(name: UserText.ppEncryptionId, value: keyId.hexString()))
        }

        if let externalRepresentation = externalRepresentation {
            rows.append(PrivacyProtectionEncryptionDetailController.Row(name: UserText.ppEncryptionKey, value: externalRepresentation.hexString()))
        }

        return rows
    }

}

