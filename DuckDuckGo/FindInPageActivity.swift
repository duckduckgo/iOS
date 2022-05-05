//
//  FindInPageActivity.swift
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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
