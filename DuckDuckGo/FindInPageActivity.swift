//
//  FindInPageActivity.swift
//  DuckDuckGo
//
//  Created by Christopher Brind on 25/07/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import UIKit
import Core

class FindInPageActivity: UIActivity {

    weak var controller: TabViewController?

    override var activityTitle: String? {
        return UserText.findInPage
    }

    override var activityType: UIActivity.ActivityType? {
        return .findInPage
    }

    override var activityImage: UIImage {
        return UIImage(named: "sharesheet-findinpage") ?? #imageLiteral(resourceName: "LogoShare")
    }

    init(controller: TabViewController) {
        self.controller = controller
        super.init()
    }

    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }

    override var activityViewController: UIViewController? {
        controller?.requestFindInPage()
        activityDidFinish(true)
        return nil
    }

}

extension UIActivity.ActivityType {

     public static let findInPage = UIActivity.ActivityType("com.duckduckgo.find.in.page")

}
