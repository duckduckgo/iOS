//
//  PrivacyProtectionPracticesController.swift
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

class PrivacyProtectionPracticesController: UIViewController {

    let privacyPracticesImages: [PrivacyPractices.Summary: UIImage] = [
        .unknown: #imageLiteral(resourceName: "PP Hero Privacy Bad Off"),
        .poor: #imageLiteral(resourceName: "PP Hero Privacy Bad On"),
        .mixed: #imageLiteral(resourceName: "PP Hero Privacy Good Off"),
        .good: #imageLiteral(resourceName: "PP Hero Privacy Good On")
    ]

    struct Row {

        let text: String
        let good: Bool

    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var domainLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!

    private var siteRating: SiteRating!
    private var protectionStore = AppDependencyProvider.shared.storageCache.current.protectionStore

    var rows = [Row]()

    override func viewDidLoad() {

        Pixel.fire(pixel: .privacyDashboardPrivacyPractices)
        
        initTable()
        initBackButton()
        update()
    }

    @IBAction func onBack() {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func onTapTOSDRLink() {
        LaunchTabNotification.postLaunchTabNotification(urlString: "https://tosdr.org")
        dismiss(animated: true)
    }

    func update() {
        guard isViewLoaded else { return }
        updateSubtitleLabel()
        updateImageIcon()
        updateDomainLabel()
        updateReasons()
    }

    private func updateSubtitleLabel() {
        subtitleLabel.text = siteRating.privacyPracticesText()?.uppercased()
    }

    private func updateImageIcon() {
        iconImage.image = privacyPracticesImages[siteRating.privacyPracticesSummary()]
    }

    private func updateDomainLabel() {
        domainLabel.text = siteRating.domain
    }

    private func updateReasons() {            
        let goodReasons = siteRating.privacyPractice.goodReasons
        let badReasons = siteRating.privacyPractice.badReasons
        let goodRows = goodReasons.map({ Row(text: $0.capitalizingFirstLetter(), good: true) })
        let badRows = badReasons.map({ Row(text: $0.capitalizingFirstLetter(), good: false) })
        rows = goodRows + badRows
    }

    private func initTable() {
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func initBackButton() {
        backButton.isHidden = !isPad
    }
}

extension PrivacyProtectionPracticesController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(1, rows.count)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard rows.count > 0 else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoPractices") as? PrivacyProtectionNoPracticesCell else {
                fatalError("Failed to dequeue cell PrivacyProtectionNoPracticesCell")
            }
            return cell
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? PrivacyProtectionPracticesCell else {
            fatalError("Failed to dequeue cell as PrivacyProtectionPracticesCell")
        }
        cell.update(row: rows[indexPath.row])
        return cell
    }

}

extension PrivacyProtectionPracticesController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if rows.count == 0 {
            return 250
        }

        return UITableView.automaticDimension
    }

}

extension PrivacyProtectionPracticesController: PrivacyProtectionInfoDisplaying {

    func using(siteRating: SiteRating, protectionStore: ContentBlockerProtectionStore) {
        self.siteRating = siteRating
        self.protectionStore = protectionStore
        update()
    }

}

class PrivacyProtectionPracticesCell: UITableViewCell {

    func update(row: PrivacyProtectionPracticesController.Row) {
        imageView?.image = row.good ? #imageLiteral(resourceName: "PP Icon Result Success") : #imageLiteral(resourceName: "PP Icon Result Fail")
        textLabel?.text = row.text
    }

}

class PrivacyProtectionNoPracticesCell: UITableViewCell {

    @IBOutlet weak var message: UILabel!

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
