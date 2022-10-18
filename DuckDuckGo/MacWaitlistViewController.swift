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

final class MacWaitlistViewController: UIViewController {
    
    private let viewModel: MacWaitlistViewModel
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.viewModel = MacWaitlistViewModel()
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

extension MacWaitlistViewController: MacWaitlistViewModelDelegate {

    func macWaitlistViewModelDidOpenShareSheet(_ viewModel: MacWaitlistViewModel, senderFrame: CGRect) {
        let linkMetadata = MacWaitlistLinkMetadata()
        let activityViewController = UIActivityViewController(activityItems: [linkMetadata], applicationActivities: nil)
        
        Pixel.fire(pixel: .macBrowserWaitlistDidPressShareButton)
        
        activityViewController.completionWithItemsHandler = { _, completed, _, _ in
            if completed {
                Pixel.fire(pixel: .macBrowserWaitlistDidPressShareButtonShared)
            } else {
                Pixel.fire(pixel: .macBrowserWaitlistDidPressShareButtonDismiss)
            }
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            activityViewController.popoverPresentationController?.sourceView = UIApplication.shared.windows.first
            activityViewController.popoverPresentationController?.permittedArrowDirections = .right
            activityViewController.popoverPresentationController?.sourceRect = senderFrame
        }
        
        present(activityViewController, animated: true, completion: nil)
    }
    
}

private final class MacWaitlistLinkMetadata: NSObject, UIActivityItemSource {
    
    fileprivate let metadata: LPLinkMetadata = {
        let metadata = LPLinkMetadata()
        metadata.originalURL = AppUrls().macBrowserDownloadURL
        metadata.url = metadata.originalURL
        metadata.title = UserText.macWaitlistShareSheetTitle
        metadata.imageProvider = NSItemProvider(object: UIImage(named: "MacWaitlistShareSheetLogo")!)

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
        case .message, .mail: return UserText.macWaitlistShareSheetMessage()
        default: return self.metadata.originalURL as Any
        }
    }
    
}
