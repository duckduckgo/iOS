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

class PrivacyProtectionNetworkLeaderboardController: UIViewController {

    @IBOutlet weak var heroIconImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var domainLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!

    @IBOutlet weak var inlineResetContainer: UIView!
    @IBOutlet weak var hoveringResetContainer: UIView!
    @IBOutlet weak var hoveringView: UIView!
    @IBOutlet weak var resetView: UIView!

    weak var contentBlocker: ContentBlockerConfigurationStore!
    weak var siteRating: SiteRating!

    let leaderboard = NetworkLeaderboard.shared
    var networksDetected = [String]()
    var data = [String: Int]()
    var drama = true

    override func viewDidLoad() {
        super.viewDidLoad()

        initHeroIcon()
        initResetButton()
        initDomainLabel()
        initDrama()
        update()
    }

    func update() {
        guard isViewLoaded else { return }

        initTable()
        initLeaderboard()
        tableView.reloadData()
        initMessageLabel()
        initResetView()
    }

    private func initResetView() {
        resetView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        resetView.translatesAutoresizingMaskIntoConstraints = true

        inlineResetContainer.isHidden = networksDetected.isEmpty
        hoveringView.isHidden = networksDetected.isEmpty

        if tableView.visibleCells.count >= networksDetected.count {
            dismissHoveringView()
        } else {
            resetView.removeFromSuperview()
            hoveringResetContainer.addSubview(resetView)
        }

    }

    private func initHeroIcon() {
        heroIconImage.image = siteRating.protecting(contentBlocker) ? #imageLiteral(resourceName: "PP Hero Leaderboard On") : #imageLiteral(resourceName: "PP Hero Leaderboard Off")
    }

    private func initTable() {
        tableView.dataSource = self
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
        let date = leaderboard.startDate ?? Date()
        let dateText = dateFormatter.string(from: date)

        let percent = "\(leaderboard.percentOfSitesWithNetwork())%"
        let message = UserText.ppNetworkLeaderboard.format(arguments: percent, dateText)

        guard let percentRange = message.range(of: percent) else { return }
        guard let dateRange = message.range(of: dateText) else { return }

        let percentNSRange = NSRange(percentRange, in: message)
        let dateNSRange = NSRange(dateRange, in: message)

        let attributedString = NSMutableAttributedString(string: message)
        attributedString.addAttribute(NSAttributedStringKey.kern, value: -0.18, range: dateNSRange)
        attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.ppRed, range: percentNSRange)

        messageLabel.attributedText = attributedString
    }

    private func initDomainLabel() {
        domainLabel.text = siteRating.domain
    }

    private func initResetButton() {
        resetButton.layer.cornerRadius = 4
    }

    private func dismissHoveringView() {
        hoveringView.isHidden = true
        resetView.removeFromSuperview()
        inlineResetContainer.addSubview(self.resetView)
    }

    @IBAction func onReset() {
        onDismiss()
        leaderboard.reset()
        update()
    }

    @IBAction func onBack() {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func onDismiss() {
        guard !hoveringView.isHidden else { return }
        UIView.animate(withDuration: 0.3, animations: {
            self.hoveringView.alpha = 0
        }, completion: { (completed) in
            self.dismissHoveringView()
        })
    }

}

extension PrivacyProtectionNetworkLeaderboardController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return networksDetected.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row + 1 >= networksDetected.count {
            onDismiss()
        }

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
        self.contentBlocker = contentBlocker
        update()
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
