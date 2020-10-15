//
//  PrivacyProtectionOverviewController.swift
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

class PrivacyProtectionOverviewController: UITableViewController {
    
    private enum Cells: Int {
        case grade = 0
        case encryptionInfo
        case trackersInfo
        case practicesInfo
        case protection
        case gatheringData
        case leaderboard
    }
    
    let privacyPracticesImages: [PrivacyPractices.Summary: UIImage] = [
        .unknown: #imageLiteral(resourceName: "PP Icon Privacy Bad Off"),
        .poor: #imageLiteral(resourceName: "PP Icon Privacy Bad On"),
        .mixed: #imageLiteral(resourceName: "PP Icon Privacy Good Off"),
        .good: #imageLiteral(resourceName: "PP Icon Privacy Good On")
    ]
    
    @IBOutlet var margins: [NSLayoutConstraint]!
    
    @IBOutlet weak var encryptionCell: SummaryCell!
    @IBOutlet weak var trackersCell: SummaryCell!
    @IBOutlet weak var privacyPracticesCell: SummaryCell!
    
    @IBOutlet weak var privacyProtectionView: UIView!
    @IBOutlet weak var privacyProtectionSwitch: UISwitch!
    
    @IBOutlet weak var collectingDataInfo: UILabel!
    
    // Leaderboard
    @IBOutlet weak var firstPill: TrackerNetworkPillView!
    @IBOutlet weak var secondPill: TrackerNetworkPillView!
    @IBOutlet weak var thirdPill: TrackerNetworkPillView!

    var leaderboard = NetworkLeaderboard.shared
    
    fileprivate var popRecognizer: InteractivePopRecognizer!
    
    private var siteRating: SiteRating!
    private var protectionStore = AppDependencyProvider.shared.storageCache.current.protectionStore
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "PrivacyProtectionHeaderCell", bundle: nil),
                           forCellReuseIdentifier: "PPHeaderCell")
        
        initPopRecognizer()
        prepareUI()
        
        update()
        
        applyTheme(ThemeManager.shared.currentTheme)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let displayInfo = segue.destination as? PrivacyProtectionInfoDisplaying {
            displayInfo.using(siteRating: siteRating, protectionStore: protectionStore)
        }
        
        if let unprotectedSitesController = segue.destination as? UnprotectedSitesViewController {
            unprotectedSitesController.enforceLightTheme = true
            if isPad {
                unprotectedSitesController.showBackButton = true
            }
            Pixel.fire(pixel: .privacyDashboardManageProtection)
            return
        }
        
        if let navController = segue.destination as? UINavigationController,
            let brokenSiteScreen = navController.topViewController as? ReportBrokenSiteViewController {
            Pixel.fire(pixel: .privacyDashboardReportBrokenSite)
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                segue.destination.modalPresentationStyle = .formSheet
            }
            
            if let privacyProtectionScreen = parent as? PrivacyProtectionController {
                brokenSiteScreen.brokenSiteInfo = privacyProtectionScreen.privacyProtectionDelegate?.getCurrentWebsiteInfo()
            }
        }
    }

    private func update() {
        // not keen on this, but there seems to be a race condition when the site rating is updated and the controller hasn't be loaded yet
        guard isViewLoaded else { return }
        
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        updateEncryption()
        updateTrackers()
        updatePrivacyPractices()
        updateProtectionToggle()
    }
    
    private func prepareUI() {
        firstPill.didLoad()
        secondPill.didLoad()
        thirdPill.didLoad()
        
        collectingDataInfo.setAttributedTextString(UserText.ppNetworkLeaderboardGatheringData)
        tableView.tableFooterView = UIView()
    }
        
    private func updateEncryption() {
        
        encryptionCell.summaryLabel.text = siteRating.encryptedConnectionText()
        switch siteRating.encryptionType {
            
        case .encrypted:
            encryptionCell.summaryImage.image = #imageLiteral(resourceName: "PP Icon Connection On")
            
        case .forced:
            encryptionCell.summaryImage.image = #imageLiteral(resourceName: "PP Icon Connection On")
            
        case .mixed:
            encryptionCell.summaryImage.image = #imageLiteral(resourceName: "PP Icon Connection Off")
            
        case .unencrypted:
            encryptionCell.summaryImage.image = #imageLiteral(resourceName: "PP Icon Connection Bad")
            
        }
    }
    
    private var isProtecting: Bool {
        return protectionStore.isProtected(domain: siteRating.domain)
    }
    
    private func updateTrackers() {
        trackersCell.summaryLabel.text = siteRating.networksText(protectionStore: protectionStore)
        
        if isProtecting || siteRating.trackersDetected.count == 0 {
            trackersCell.summaryImage.image = #imageLiteral(resourceName: "PP Icon Major Networks On")
        } else {
            trackersCell.summaryImage.image = #imageLiteral(resourceName: "PP Icon Major Networks Bad")
        }
    }
    
    private func updatePrivacyPractices() {
        privacyPracticesCell.summaryLabel.text = siteRating.privacyPracticesText()
        privacyPracticesCell.summaryImage.image = privacyPracticesImages[siteRating.privacyPracticesSummary()]
    }
    
    private func updateProtectionToggle() {
        privacyProtectionSwitch.isOn = isProtecting
        privacyProtectionView.backgroundColor = isProtecting ? UIColor.ppGreen : UIColor.ppGray
    }
    
    @IBAction func protectionToggled(toggle: UISwitch) {
        guard let domain = siteRating.domain else { return }
        
        let isProtected = toggle.isOn
        let window = UIApplication.shared.keyWindow
        window?.hideAllToasts()
        
        if isProtected {
            protectionStore.enableProtection(forDomain: domain)
            
            window?.showBottomToast(UserText.toastProtectionEnabled.format(arguments: domain), duration: 1)
        } else {
            protectionStore.disableProtection(forDomain: domain)
            
            window?.showBottomToast(UserText.toastProtectionDisabled.format(arguments: domain), duration: 1)
        }
        Pixel.fire(pixel: isProtected ? .privacyDashboardProtectionDisabled : .privacyDashboardProtectionEnabled)
    }
    
    // see https://stackoverflow.com/a/41248703
    private func initPopRecognizer() {
        guard let controller = navigationController else { return }
        popRecognizer = InteractivePopRecognizer(controller: controller)
        controller.interactivePopGestureRecognizer?.delegate = popRecognizer
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case Cells.grade.rawValue:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PPHeaderCell", for: indexPath) as? PrivacyProtectionHeaderCell else {
                fatalError("Missing Header cell")
            }
            
            PrivacyProtectionHeaderConfigurator.configure(cell: cell, siteRating: siteRating, protectionStore: protectionStore)
            cell.backImage.isHidden = true
            
            return cell
        case Cells.leaderboard.rawValue:

            if leaderboard.shouldShow() {
                let networksDetected = leaderboard.networksDetected()
                let pagesVisited = leaderboard.pagesVisited()
                firstPill.update(network: networksDetected[0], pagesVisited: pagesVisited)
                secondPill.update(network: networksDetected[1], pagesVisited: pagesVisited)
                thirdPill.update(network: networksDetected[2], pagesVisited: pagesVisited)
            }
            
            return super.tableView(tableView, cellForRowAt: indexPath)
        default:
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case Cells.gatheringData.rawValue:
            if leaderboard.shouldShow() {
                return 0
            } else {
                return UITableView.automaticDimension
            }
        case Cells.leaderboard.rawValue:
            if leaderboard.shouldShow() {
                return UITableView.automaticDimension
            } else {
                return 0
            }
        default:
            return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case Cells.grade.rawValue:
            performSegue(withIdentifier: "ShowScore", sender: nil)
        default:
            break
        }
    }
}

extension PrivacyProtectionOverviewController: PrivacyProtectionInfoDisplaying {
    
    func using(siteRating: SiteRating, protectionStore: ContentBlockerProtectionStore) {
        self.siteRating = siteRating
        self.protectionStore = protectionStore
        update()
    }
    
}

class SummaryCell: UITableViewCell {
    
    @IBOutlet weak var summaryImage: UIImageView!
    @IBOutlet weak var summaryLabel: UILabel!
    
}

private class InteractivePopRecognizer: NSObject, UIGestureRecognizerDelegate {
    
    weak var navigationController: UINavigationController?
    
    init(controller: UINavigationController) {
        self.navigationController = controller
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController?.viewControllers.count ?? 0 > 1
    }
    
    // This is necessary because without it, subviews of your top controller can
    // cancel out your gesture recognizer on the edge.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension PrivacyProtectionOverviewController: Themable {

    func decorate(with theme: Theme) {
        setNeedsStatusBarAppearanceUpdate()
        decorateNavigationBar(with: theme)
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
    }
}

class TrackerNetworkPillView: UIView {

    @IBOutlet weak var networkImage: UIImageView!
    @IBOutlet weak var percentageLabel: UILabel!

    func didLoad() {
        layer.cornerRadius = frame.size.height / 2
    }

    func update(network: PPTrackerNetwork, pagesVisited: Int) {
        let percent = 100 * Int(network.detectedOnCount) / pagesVisited
        let percentText = "\(percent)%"
        let image = network.image

        networkImage.image = image
        percentageLabel.text = percentText
    }

}

fileprivate extension PPTrackerNetwork {

    var image: UIImage {
        let name = TrackerDataManager.shared.findEntity(byName: self.name ?? "")?.displayName ?? ""
        let imageName = "PP Pill \(name.lowercased())"
        return UIImage(named: imageName) ?? #imageLiteral(resourceName: "PP Pill Generic")
    }

}
