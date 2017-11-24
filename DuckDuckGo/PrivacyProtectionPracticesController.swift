//
//  PrivacyProtectionPracticesController.swift
//  DuckDuckGo
//
//  Created by Christopher Brind on 24/11/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import Core

class PrivacyProtectionPracticesController: UIViewController {

    struct Row {

        let text: String
        let good: Bool

    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var domainLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!

    weak var siteRating: SiteRating!
    weak var contentBlocker: ContentBlockerConfigurationStore!

    var rows = [Row]()

    override func viewDidLoad() {
        initTable()
        messageLabel.adjustPlainTextLineHeight(1.286)
        update()
    }

    @IBAction func onBack() {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func onTapTOSDRLink() {
    }

    func update() {
        guard isViewLoaded else { return }
        updateImageIcon()
        updateDomainLabel()
        updateReasons()
    }

    private func updateImageIcon() {
        let resultOn = siteRating.privacyPracticesSuccess() ? #imageLiteral(resourceName: "PP Hero Privacy Good On") : #imageLiteral(resourceName: "PP Hero Privacy Bad On")
        let resultOff = siteRating.privacyPracticesSuccess() ? #imageLiteral(resourceName: "PP Hero Privacy Good Off") : #imageLiteral(resourceName: "PP Hero Privacy Bad Off")
        iconImage.image = contentBlocker.enabled ? resultOn : resultOff
    }

    private func updateDomainLabel() {
        domainLabel.text = siteRating.domain
    }

    private func updateReasons() {
        let goodReasons = self.siteRating.termsOfService?.goodReasons ?? []
        let badReasons = self.siteRating.termsOfService?.badReasons ?? []
        let goodRows = goodReasons.map( { Row(text: $0.capitalizingFirstLetter(), good: true) })
        let badRows = badReasons.map( { Row(text: $0.capitalizingFirstLetter(), good: false) })
        rows = goodRows + badRows
    }

    private func initTable() {
        tableView.dataSource = self
        tableView.delegate = self
    }

}

extension PrivacyProtectionPracticesController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(rows.count, 1)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if 0 == rows.count {
            return tableView.dequeueReusableCell(withIdentifier: "None")!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! PrivacyProtectionPracticesCell
            cell.update(row: rows[indexPath.row])
            return cell
        }
    }

}

extension PrivacyProtectionPracticesController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if rows.count == 0 {
            return 144
        }

        return UITableViewAutomaticDimension
    }

}

extension PrivacyProtectionPracticesController: PrivacyProtectionInfoDisplaying {

    func using(siteRating: SiteRating, contentBlocker: ContentBlockerConfigurationStore) {
        self.siteRating = siteRating
        self.contentBlocker = contentBlocker
        update()
    }

}

class PrivacyProtectionPracticesCell: UITableViewCell {

    func update(row: PrivacyProtectionPracticesController.Row) {
        imageView?.image = row.good ? #imageLiteral(resourceName: "PP Icon Result Success") : #imageLiteral(resourceName: "PP Icon Result Fail")
        textLabel?.text = row.text
        textLabel?.adjustPlainTextLineHeight(21 / 16)
    }

}

// Credit: https://stackoverflow.com/a/26306372/73479
fileprivate extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
