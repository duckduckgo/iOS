//
//  VPNWaitlistViewController.swift
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

import UIKit
import SwiftUI
import LinkPresentation
import Core
import Waitlist

final class VPNWaitlistViewController: UIViewController {

    private let viewModel: WaitlistViewModel

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.viewModel = WaitlistViewModel(waitlist: VPNWaitlist.shared)
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Network Protection Preview"

        addHostingControllerToViewHierarchy()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateViewState),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateViewState),
                                               name: WaitlistKeychainStore.inviteCodeDidChangeNotification,
                                               object: VPNWaitlist.identifier)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            await self.viewModel.updateViewState()
        }
    }

    @objc
    private func updateViewState() {
        Task {
            await self.viewModel.updateViewState()
        }
    }

    private func addHostingControllerToViewHierarchy() {
        let waitlistView = VPNWaitlistView().environmentObject(viewModel)
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

extension VPNWaitlistViewController: WaitlistViewModelDelegate {

    func waitlistViewModelDidAskToReceiveJoinedNotification(_ viewModel: WaitlistViewModel) async -> Bool {
        return await withCheckedContinuation { continuation in
            let alertController = UIAlertController(title: "Title",
                                                    message: "Message",
                                                    preferredStyle: .alert)
            alertController.overrideUserInterfaceStyle()

            alertController.addAction(title: UserText.waitlistNoThanks) {
                continuation.resume(returning: false)
            }
            let notifyMeAction = UIAlertAction(title: UserText.waitlistNotifyMe, style: .default) { _ in
                continuation.resume(returning: true)
            }

            alertController.addAction(notifyMeAction)
            alertController.preferredAction = notifyMeAction

            present(alertController, animated: true)
        }
    }

    func waitlistViewModelDidJoinQueueWithNotificationsAllowed(_ viewModel: WaitlistViewModel) {
        VPNWaitlist.shared.scheduleBackgroundRefreshTask()
    }

    func waitlistViewModel(_ viewModel: WaitlistViewModel, didTriggerCustomAction action: WaitlistViewModel.ViewCustomAction) {
        if action == .openMacBrowserWaitlist {
            let macWaitlistViewController = MacWaitlistViewController(nibName: nil, bundle: nil)
            navigationController?.popToRootViewController(animated: true)
            navigationController?.pushViewController(macWaitlistViewController, animated: true)
        }
    }

    func waitlistViewModelDidOpenInviteCodeShareSheet(_ viewModel: WaitlistViewModel, inviteCode: String, senderFrame: CGRect) {
        fatalError()
    }

    func waitlistViewModelDidOpenDownloadURLShareSheet(_ viewModel: WaitlistViewModel, senderFrame: CGRect) {
        fatalError()
    }

}
