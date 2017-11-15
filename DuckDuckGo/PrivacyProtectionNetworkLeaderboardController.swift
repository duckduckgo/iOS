//
//  PrivacyProtectionNetworkLeaderboardController.swift
//  DuckDuckGo
//
//  Created by Christopher Brind on 15/11/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation
import UIKit

class PrivacyProtectionNetworkLeaderboardController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let leaderboard = NetworkLeaderboard.shared
        print("***", "NetworkLeaderboard:", leaderboard.percentOfSitesWithNetwork(), "%")
        for network in leaderboard.networksDetected() {
            print("***", network, " = ", leaderboard.percentOfSitesWithNetwork(named: network), "%")
        }
    }

}
