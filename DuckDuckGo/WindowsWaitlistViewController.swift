//
//  WindowsWaitlistViewController.swift
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

final class WindowsWaitlistViewController: UIViewController {

    private let viewModel: WaitlistViewModel

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.viewModel = WaitlistViewModel(waitlist: .windowsBrowser)
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = UserText.windowsWaitlistTitle

        addHostingControllerToViewHierarchy()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateViewState),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateViewState),
                                               name: WindowsBrowserWaitlist.Notifications.inviteCodeChanged,
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
        let waitlistView = WindowsBrowserWaitlistView().environmentObject(viewModel)
        let waitlistViewController = UIHostingController(rootView: waitlistView)
        waitlistViewController.view.backgroundColor = UIColor(named: "WaitlistBackgroundColor")!

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

extension WindowsWaitlistViewController: WaitlistViewModelDelegate {

    func waitlistViewModelDidOpenInviteCodeShareSheet(_ viewModel: WaitlistViewModel, inviteCode: String, senderFrame: CGRect) {
        let linkMetadata = WindowsWaitlistLinkMetadata(inviteCode: inviteCode)
        let activityViewController = UIActivityViewController(activityItems: [linkMetadata], applicationActivities: nil)

        Pixel.fire(pixel: .windowsBrowserWaitlistDidPressShareButton)

        activityViewController.completionWithItemsHandler = { _, completed, _, _ in
            if completed {
                Pixel.fire(pixel: .windowsBrowserWaitlistDidPressShareButtonShared)
            } else {
                Pixel.fire(pixel: .windowsBrowserWaitlistDidPressShareButtonDismiss)
            }
        }

        if UIDevice.current.userInterfaceIdiom == .pad {
            activityViewController.popoverPresentationController?.sourceView = UIApplication.shared.windows.first
            activityViewController.popoverPresentationController?.permittedArrowDirections = .right
            activityViewController.popoverPresentationController?.sourceRect = senderFrame
        }

        present(activityViewController, animated: true, completion: nil)
    }

    func waitlistViewModelDidOpenDownloadURLShareSheet(_ viewModel: WaitlistViewModel, senderFrame: CGRect) {
        assertionFailure("Windows Waitlist is still active")
    }
}

private final class WindowsWaitlistLinkMetadata: NSObject, UIActivityItemSource {

    fileprivate let metadata: LPLinkMetadata = {
        let metadata = LPLinkMetadata()
        metadata.originalURL = AppUrls().macBrowserDownloadURL
        metadata.url = metadata.originalURL
        metadata.title = UserText.waitlistShareSheetTitle
        metadata.imageProvider = NSItemProvider(object: UIImage(named: "WaitlistShareSheetLogo")!)

        return metadata
    }()

    private let inviteCode: String

    init(inviteCode: String) {
        self.inviteCode = inviteCode
    }

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
        case .message, .mail:
            return UserText.windowsWaitlistShareSheetMessage(code: inviteCode)
        default:
            return self.metadata.originalURL as Any
        }
    }

}
