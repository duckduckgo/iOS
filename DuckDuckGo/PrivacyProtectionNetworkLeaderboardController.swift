//
//  PrivacyProtectionNetworkLeaderboardController.swift
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
import UIKit
import Core
import BrowserServicesKit

class PrivacyProtectionNetworkLeaderboardController: UIViewController {

    @IBOutlet weak var heroIconImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var domainLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!

    @IBOutlet weak var inlineResetContainer: UIView!
    @IBOutlet weak var hoveringResetContainer: UIView!
    @IBOutlet weak var hoveringView: UIView!
    @IBOutlet weak var resetView: UIView!
    @IBOutlet weak var resetViewInfo: UILabel!

    private var privacyConfig: PrivacyConfiguration = ContentBlocking.shared.privacyConfigurationManager.privacyConfig
    private var siteRating: SiteRating!

    let leaderboard = NetworkLeaderboard.shared
    var networksDetected = [PPTrackerNetwork]()
    var pagesVisited = 0
    var pagesWithTrackers = 0
    var drama = true

    override func viewDidLoad() {
        super.viewDidLoad()

        Pixel.fire(pixel: .privacyDashboardGlobalStats)
        
        initHeroIcon()
        initResetButton()
        initDrama()
        initBackButton()
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

        resetViewInfo.setAttributedTextString(UserText.ppTopOffendersInfo)
    }

    private func initHeroIcon() {
        let resultImage = siteRating.trackerNetworksDetected > 0 ? #imageLiteral(resourceName: "PP Hero Leaderboard On") : #imageLiteral(resourceName: "PP Hero Leaderboard Bad")
        heroIconImage.image = siteRating.protecting(privacyConfig) ? resultImage : #imageLiteral(resourceName: "PP Hero Leaderboard Off")
    }

    private func initTable() {
        tableView.dataSource = self
    }

    private func initLeaderboard() {
        pagesVisited = leaderboard.pagesVisited()
        pagesWithTrackers = leaderboard.pagesWithTrackers()
        networksDetected = leaderboard.networksDetected()
    }

    private func initDrama() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.drama = false
            self?.tableView.reloadData()
        }
    }

    private func initBackButton() {
        backButton.isHidden = !AppWidthObserver.shared.isLargeWidth
    }

    private func initMessageLabel() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let date = leaderboard.startDate ?? Date()
        let dateText = dateFormatter.string(from: date)

        let percent = pagesVisited == 0 ? 0 : 100 * pagesWithTrackers / pagesVisited
        let percentText = "\(percent)"
        let message = UserText.ppNetworkLeaderboard.format(arguments: percentText, dateText)

        guard let percentRange = message.range(of: percentText) else { return }
        guard let dateRange = message.range(of: dateText) else { return }

        let percentNSRange = NSRange(percentRange, in: message)
        let dateNSRange = NSRange(dateRange, in: message)

        let attributedString = NSMutableAttributedString(string: message)
        attributedString.addAttribute(NSAttributedString.Key.kern, value: -0.18, range: dateNSRange)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.ppRed, range: percentNSRange)
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle(), range: .init(location: 0, length: message.count))

        messageLabel.attributedText = attributedString
    }

    private func paragraphStyle() -> NSParagraphStyle {
        let paragaphStyle = NSMutableParagraphStyle()
        paragaphStyle.lineHeightMultiple = 1.375
        return paragaphStyle
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
        }, completion: { (_) in
            self.dismissHoveringView()
        })
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let headerView = tableView.tableHeaderView else {
            return
        }
        
        let size = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        if headerView.frame.size.height != size.height {
            headerView.frame.size.height = size.height
            tableView.tableHeaderView = headerView
            tableView.layoutIfNeeded()
        }
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
        let percent = pagesVisited == 0 || drama ? 0 : 100 * Int(network.detectedOnCount) / pagesVisited

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? PrivacyProtectionNetworkLeaderboardCell else {
            fatalError("Failed to dequeue cell as PrivacyProtectionNetworkLeaderboardCell")
        }

        let currentTrackerData = ContentBlocking.shared.contentBlockingManager.currentMainRules?.trackerData
        let networkName = currentTrackerData?.findEntity(byName: network.name!)?.displayName ?? network.name!
        cell.update(network: networkName, percent: percent)
        return cell
    }

}

extension PrivacyProtectionNetworkLeaderboardController: PrivacyProtectionInfoDisplaying {

    func using(siteRating: SiteRating, config: PrivacyConfiguration) {
        self.siteRating = siteRating
        self.privacyConfig = config
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
