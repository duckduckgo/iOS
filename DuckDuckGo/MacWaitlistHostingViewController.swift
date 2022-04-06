//
//  MacWaitlistHostingViewController.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
import SwiftUI

final class MacWaitlistViewController: UIViewController {
    
    private let viewModel: MacWaitlistViewModel
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.viewModel = MacWaitlistViewModel()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = UserText.macWaitlistTitle

        addHostingControllerToViewHierarchy()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateViewState),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateViewState),
                                               name: MacBrowserWaitlist.Notifications.inviteCodeChanged,
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.updateViewState()
    }
    
    @objc
    private func updateViewState() {
        viewModel.updateViewState()
    }
    
    private func addHostingControllerToViewHierarchy() {
        let waitlistView = MacBrowserWaitlistView().environmentObject(viewModel)
        let waitlistViewController = UIHostingController(rootView: waitlistView)
        waitlistViewController.view.backgroundColor = UIColor(named: "MacWaitlistBackgroundColor")!
        
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
