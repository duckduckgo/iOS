//
//  PrivacyProtectionErrorController.swift
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

protocol PrivacyProtectionErrorDelegate: class {

    func canTryAgain(controller: PrivacyProtectionErrorController) -> Bool

    func tryAgain(controller: PrivacyProtectionErrorController)

}

// TODO
class PrivacyProtectionErrorController: UITableViewController {
    
    private enum Cells: Int {
        case grade = 0
        case errorTitle
        case errorDetails
        case tryAgainButton
        case protection
        case gatheringData
        case leaderboard
    }

    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var buttonCell: UITableViewCell!

    var errorText: String?
    
    // Leaderboard
    @IBOutlet weak var firstPill: TrackerNetworkPillView!
    @IBOutlet weak var secondPill: TrackerNetworkPillView!
    @IBOutlet weak var thirdPill: TrackerNetworkPillView!

    var leaderboard = NetworkLeaderboard.shared

    private var protectionStore = AppDependencyProvider.shared.storageCache.current.protectionStore
    
    weak var delegate: PrivacyProtectionErrorDelegate?

    override func viewDidLoad() {
        button.layer.cornerRadius = 5
        errorLabel.text = errorText
        resetTryAgain()
        buttonCell.isHidden = !canRetry()
        applyTheme(ThemeManager.shared.currentTheme)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func onTapTryAgain() {
        activity.isHidden = false
        button.isEnabled = false
        delegate?.tryAgain(controller: self)
    }

    func resetTryAgain() {
        button.isEnabled = true
        activity?.isHidden = true
    }

    private func canRetry() -> Bool {
        return (delegate?.canTryAgain(controller: self) ?? false)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
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
        case Cells.tryAgainButton.rawValue:
            if canRetry() {
                return UITableView.automaticDimension
            } else {
                return 0
            }
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
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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

}

extension PrivacyProtectionErrorController: Themable {

    func decorate(with theme: Theme) {
        decorateNavigationBar(with: theme)
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
    }

}
