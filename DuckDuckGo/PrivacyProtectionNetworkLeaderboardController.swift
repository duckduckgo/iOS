//
//  PrivacyProtectionNetworkLeaderboardController.swift
//  DuckDuckGo
//
//  Created by Christopher Brind on 15/11/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation
import UIKit
import Core

class PrivacyProtectionNetworkLeaderboardController: UITableViewController {

    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var domainLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!

    weak var siteRating: SiteRating!

    let leaderboard = NetworkLeaderboard.shared
    var networksDetected = [String]()
    var data = [String: Int]()
    var drama = true

    override func viewDidLoad() {
        super.viewDidLoad()

        initLeaderboard()
        initResetButton()
        initDomainLabel()
        initMessageLabel()
        initDrama()
    }

    private func initLeaderboard() {
        networksDetected = leaderboard.networksDetected()
        for network in networksDetected {
            data[network] = leaderboard.percentOfSitesWithNetwork(named: network)
        }

        networksDetected = networksDetected.sorted() { (left, right) -> Bool in
            return data[left]! > data[right]!
        }
    }

    private func initDrama() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.drama = false
            self?.tableView.reloadData()
        }
    }

    private func initMessageLabel() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium

        let percent = "\(NetworkLeaderboard.shared.percentOfSitesWithNetwork())%"
        let date = dateFormatter.string(from: Date())

        let message = UserText.ppNetworkLeaderboard.format(arguments: percent, date)

        guard let percentRange = message.range(of: percent) else { return }
        guard let dateRange = message.range(of: date) else { return }

        let percentNSRange = NSRange(percentRange, in: message)
        let dateNSRange = NSRange(dateRange, in: message)

        let attributedString = NSMutableAttributedString(string: message)
        attributedString.addAttribute(NSAttributedStringKey.kern, value: -0.18, range: percentNSRange)
        attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.ppRed, range: dateNSRange)

        messageLabel.attributedText = attributedString
    }

    private func initDomainLabel() {
        domainLabel.text = siteRating.domain
    }

    private func initResetButton() {
        resetButton.layer.cornerRadius = 4
    }

    @IBAction func onReset() {
        leaderboard.reset()
        initLeaderboard()
        initMessageLabel()
        tableView.reloadData()
    }

    @IBAction func onBack() {
        navigationController?.popViewController(animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return networksDetected.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let network = networksDetected[indexPath.row]
        let percent = drama ? 0 : leaderboard.percentOfSitesWithNetwork(named: network)

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! PrivacyProtectionNetworkLeaderboardCell
        cell.update(network: network, percent: percent)
        return cell
    }

}

extension PrivacyProtectionNetworkLeaderboardController: PrivacyProtectionInfoDisplaying {

    func using(siteRating: SiteRating, contentBlocker: ContentBlockerConfigurationStore) {
        self.siteRating = siteRating
    }

}

class PrivacyProtectionNetworkLeaderboardCell: UITableViewCell {

    @IBOutlet weak var networkLabel: UILabel!
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var percentLabel: UILabel!

    func update(network: String, percent: Int) {
        networkLabel.text = network
        percentLabel.text = "\(percent)%"
        progress.setProgress(Float(percent) / 100, animated: true)
    }

}
