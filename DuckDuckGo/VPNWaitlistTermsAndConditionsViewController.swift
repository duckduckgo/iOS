//
//  VPNWaitlistTermsAndConditionsViewController.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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

#if NETWORK_PROTECTION

import UIKit
import SwiftUI
import Core
import Waitlist

@available(iOS 15.0, *)
final class VPNWaitlistTermsAndConditionsViewController: UIViewController {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = UserText.netPNavTitle
        addHostingControllerToViewHierarchy()

        DailyPixel.fire(pixel: .networkProtectionWaitlistTermsDisplayed)
    }

    private func addHostingControllerToViewHierarchy() {
        let waitlistView = VPNWaitlistPrivacyPolicyView { _ in
            var termsAndConditionsStore = NetworkProtectionTermsAndConditionsUserDefaultsStore()
            termsAndConditionsStore.networkProtectionWaitlistTermsAndConditionsAccepted = true

            DailyPixel.fire(pixel: .networkProtectionWaitlistTermsAccepted)

            self.navigationController?.popToRootViewController(animated: true)
            let networkProtectionViewController = NetworkProtectionRootViewController()
            self.navigationController?.pushViewController(networkProtectionViewController, animated: true)
        }

        let waitlistViewController = UIHostingController(rootView: waitlistView)
        waitlistViewController.view.backgroundColor = UIColor(designSystemColor: .background)

        addChild(waitlistViewController)
        waitlistViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(waitlistViewController.view)
        waitlistViewController.didMove(toParent: self)

        NSLayoutConstraint.activate([
            waitlistViewController.view.widthAnchor.constraint(equalTo: view.widthAnchor),
            waitlistViewController.view.heightAnchor.constraint(equalTo: view.heightAnchor),
            waitlistViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            waitlistViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

}

#endif
