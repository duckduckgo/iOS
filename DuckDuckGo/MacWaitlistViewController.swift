//
//  MacWaitlistViewController.swift
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
import LinkPresentation
import Core
import Waitlist
import DesignResourcesKit

final class MacWaitlistViewController: UIViewController {
    
    private let viewModel: WaitlistViewModel
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.viewModel = WaitlistViewModel(waitlist: MacBrowserWaitlist.shared)
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = UserText.macBrowserTitle
        addHostingControllerToViewHierarchy()
    }
    
    private func addHostingControllerToViewHierarchy() {
        let waitlistView = MacBrowserWaitlistView().environmentObject(viewModel)
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

extension MacWaitlistViewController: WaitlistViewModelDelegate {
    func waitlistViewModelDidAskToReceiveJoinedNotification(_ viewModel: WaitlistViewModel) async -> Bool {
        assertionFailure("Mac Waitlist is removed")
        return true
    }

    func waitlistViewModelDidJoinQueueWithNotificationsAllowed(_ viewModel: WaitlistViewModel) {
        assertionFailure("Mac Waitlist is removed")
    }

    func waitlistViewModelDidOpenInviteCodeShareSheet(_ viewModel: WaitlistViewModel, inviteCode: String, senderFrame: CGRect) {
        assertionFailure("Mac Waitlist is removed")
    }

    func waitlistViewModelDidOpenDownloadURLShareSheet(_ viewModel: WaitlistViewModel, senderFrame: CGRect) {
        let linkMetadata = MacWaitlistLinkMetadata()
        let activityViewController = UIActivityViewController(activityItems: [linkMetadata], applicationActivities: nil)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            activityViewController.popoverPresentationController?.sourceView = UIApplication.shared.windows.first
            activityViewController.popoverPresentationController?.permittedArrowDirections = .right
            activityViewController.popoverPresentationController?.sourceRect = senderFrame
        }
        
        present(activityViewController, animated: true, completion: nil)
    }

    func waitlistViewModel(_ viewModel: WaitlistViewModel, didTriggerCustomAction action: WaitlistViewModel.ViewCustomAction) {
        if action == .openWindowsBrowserWaitlist {
            let windowsWaitlistViewController = WindowsWaitlistViewController(nibName: nil, bundle: nil)
            navigationController?.popToRootViewController(animated: true)
            navigationController?.pushViewController(windowsWaitlistViewController, animated: true)
        }
    }
}

private final class MacWaitlistLinkMetadata: NSObject, UIActivityItemSource {
    
    fileprivate let metadata: LPLinkMetadata = {
        let metadata = LPLinkMetadata()
        metadata.originalURL = MacBrowserWaitlist.downloadURL
        metadata.url = MacBrowserWaitlist.downloadURL
        metadata.title = UserText.macWaitlistShareSheetTitle
        metadata.imageProvider = NSItemProvider(object: UIImage(named: "WaitlistShareSheetLogo")!)

        return metadata
    }()
    
    func activityViewControllerLinkMetadata(_: UIActivityViewController) -> LPLinkMetadata? {
        return self.metadata
    }
    
    public func activityViewControllerPlaceholderItem(_: UIActivityViewController) -> Any {
        return self.metadata.originalURL as Any
    }

    public func activityViewController(_: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        guard let type = activityType else {
            return self.metadata.originalURL as Any
        }

        switch type {
        case .message, .mail: return UserText.macWaitlistShareSheetMessage
        default: return self.metadata.originalURL as Any
        }
    }
    
}
